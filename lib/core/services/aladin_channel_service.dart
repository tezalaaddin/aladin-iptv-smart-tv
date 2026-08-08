import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:fuzzy/fuzzy.dart';
import '../database/aladin_isar_service.dart';
import '../models/aladin_channel_model.dart';
import '../models/aladin_category_model.dart';
import '../state/aladin_app_prefs.dart';
import 'aladin_parental_service.dart';
import 'aladin_content_visibility_service.dart';

class ChannelService {
  ChannelService._();
  static final ChannelService instance = ChannelService._();
  Isar get _db => IsarService.instance.db;

  static const _exoChannel = MethodChannel('aladin/exoplayer');

  Future<int> migrateParentalLocks() async {
    final channels = await _db.channelModels.where().findAll();
    return ParentalService.instance.migrateLegacyChannelLocks(channels);
  }

  Future<void> recordPlay(ChannelModel channel) async {
    final key = ParentalService.instance.channelKey(channel);
    Map<String, dynamic> counts;
    try {
      counts = Map<String, dynamic>.from(jsonDecode(
          AladinPrefs.instance.getString('channel_play_counts_v49') ?? '{}'));
    } catch (_) {
      counts = {};
    }
    counts[key] = ((counts[key] as num?)?.toInt() ?? 0) + 1;
    await AladinPrefs.instance
        .setString('channel_play_counts_v49', jsonEncode(counts));
  }

  Future<List<ChannelModel>> getMostWatched(int playlistId,
      {int limit = 15}) async {
    Map<String, dynamic> counts;
    try {
      counts = Map<String, dynamic>.from(jsonDecode(
          AladinPrefs.instance.getString('channel_watch_seconds_v50') ?? '{}'));
    } catch (_) {
      return [];
    }
    final candidates = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .lastWatchedIsNotNull()
        .limit(500)
        .findAll();
    candidates.removeWhere((channel) =>
        !ParentalService.instance.canExpose(channel) ||
        !ContentVisibilityService.instance.isChannelVisible(channel));
    candidates.sort((a, b) {
      final aCount =
          (counts[ParentalService.instance.channelKey(a)] as num?)?.toInt() ??
              0;
      final bCount =
          (counts[ParentalService.instance.channelKey(b)] as num?)?.toInt() ??
              0;
      return bCount.compareTo(aCount);
    });
    return candidates
        .where((channel) =>
            ((counts[ParentalService.instance.channelKey(channel)] as num?)
                    ?.toInt() ??
                0) >=
            120)
        .take(limit)
        .toList();
  }

  Future<void> recordWatchDurationByUrl(String url, int seconds) async {
    if (seconds <= 0) return;
    final channel = await getByUrl(url);
    if (channel == null) return;
    final key = ParentalService.instance.channelKey(channel);
    Map<String, dynamic> totals;
    try {
      totals = Map<String, dynamic>.from(jsonDecode(
          AladinPrefs.instance.getString('channel_watch_seconds_v50') ?? '{}'));
    } catch (_) {
      totals = {};
    }
    totals[key] = ((totals[key] as num?)?.toInt() ?? 0) + seconds.clamp(0, 300);
    await AladinPrefs.instance
        .setString('channel_watch_seconds_v50', jsonEncode(totals));
  }

  // ── System Sync (Android TV Search & Watch Next) ──────────────────────────

  /// Syncs the top N channels to the Android TV Global Search database
  Future<void> syncSearchData(int playlistId) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Get a representative sample of channels (e.g., first 500)
      final items = await _db.channelModels
          .filter()
          .playlistIdEqualTo(playlistId)
          .limit(1000)
          .findAll();

      final data = items
          .where((item) => !ParentalService.instance.isChannelLocked(item))
          .map((e) => {
                'id': e.id.toString(),
                'name': e.name,
                'category': e.categoryName,
                'logo': e.logoUrl ?? '',
              })
          .toList();

      final blockedIds = <String>[];
      var offset = 0;
      const batchSize = 1000;
      while (true) {
        final batch = await _db.channelModels
            .filter()
            .playlistIdEqualTo(playlistId)
            .offset(offset)
            .limit(batchSize)
            .findAll();
        for (final item in batch) {
          if (ParentalService.instance.isChannelLocked(item)) {
            blockedIds.add(item.id.toString());
          }
        }
        if (batch.length < batchSize) break;
        offset += batchSize;
      }

      try {
        await _exoChannel.invokeMethod('syncSearchData', {
          'items': data,
          'blockedIds': blockedIds,
        });
      } catch (e) {
        debugPrint('[ChannelService] syncSearchData error: $e');
      }
    }
  }

  /// Adds an item to the Android TV "Watch Next" home screen channel
  Future<void> addToWatchNext(ChannelModel ch) async {
    if (ParentalService.instance.isChannelLocked(ch)) return;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _exoChannel.invokeMethod('addToWatchNext', {
          'title': ch.name,
          'description': ch.tmdbOverview ?? ch.categoryName,
          'poster': ch.tmdbPoster ?? ch.logoUrl ?? '',
          'channelId': ch.id.toString(),
          'contentType': ch.contentType,
          'positionMs': ch.watchedSeconds * 1000,
          'durationMs': ch.totalDurationSeconds * 1000,
        });
      } catch (e) {
        debugPrint('[ChannelService] addToWatchNext error: $e');
      }
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  int _seedFor(String scope) {
    var hash = 2166136261;
    for (final unit in scope.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
    }
    return (AladinPrefs.instance.launchShuffleSeed ^ hash) & 0x7fffffff;
  }

  bool _shouldShuffle(String type) =>
      AladinPrefs.instance.shuffleOnLaunch &&
      (type == 'movie' || type == 'series');

  Future<List<CategoryModel>> getCategories(
      {required int playlistId, required String contentType}) async {
    final items = await _db.categoryModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .contentTypeEqualTo(contentType)
        .sortBySortOrder()
        .findAll();
    items.removeWhere((category) => category.channelCount <= 0);
    items.removeWhere((category) =>
        !ContentVisibilityService.instance.isCategoryVisible(category));
    if (ParentalService.instance.hideLockedContent) {
      items.removeWhere((category) =>
          ParentalService.instance.isCategoryLocked(playlistId, category.name));
    }
    if (_shouldShuffle(contentType)) {
      items.shuffle(Random(_seedFor('categories:$playlistId:$contentType')));
    }
    return items;
  }

  // ── Channels per category (paginated) ─────────────────────────────────────

  Future<List<ChannelModel>> getChannelsByCategory(
      {required int playlistId,
      required String categoryName,
      required String contentType,
      int offset = 0,
      int limit = 100}) async {
    // Special handling for series: group by seriesName (or name) to avoid duplicate entries for episodes
    if (contentType == 'series') {
      // Optimization: Try to get only "main" records first (url is empty or episode 1/null)
      final reps = await _db.channelModels
          .filter()
          .playlistIdEqualTo(playlistId)
          .and()
          .categoryNameEqualTo(categoryName.trim())
          .and()
          .contentTypeEqualTo('series')
          .group((q) =>
              q.urlEqualTo('').or().episodeEqualTo(1).or().episodeIsNull())
          .sortBySortOrder()
          .offset(offset)
          .limit(limit)
          .findAll();

      if (reps.isNotEmpty) {
        if (_shouldShuffle(contentType)) {
          reps.shuffle(Random(_seedFor(
              'content:$playlistId:$contentType:${categoryName.trim()}:$offset')));
        }
        return reps
            .where(ParentalService.instance.canExpose)
            .where(ContentVisibilityService.instance.isChannelVisible)
            .toList();
      }

      // Fallback if no "main" records found (e.g. strange M3U)
      final all = await _db.channelModels
          .filter()
          .playlistIdEqualTo(playlistId)
          .and()
          .categoryNameEqualTo(categoryName.trim())
          .and()
          .contentTypeEqualTo('series')
          .sortBySortOrder()
          .findAll();

      final seen = <String>{};
      final results = <ChannelModel>[];
      for (final ch in all) {
        final key = ch.seriesName?.trim() ?? ch.name.trim();
        if (seen.add(key.toLowerCase())) {
          results.add(ch);
        }
      }

      if (_shouldShuffle(contentType)) {
        results.shuffle(Random(_seedFor(
            'content:$playlistId:$contentType:${categoryName.trim()}')));
      }

      if (offset >= results.length) return [];
      int end = offset + limit;
      if (end > results.length) end = results.length;
      return results
          .sublist(offset, end)
          .where(ParentalService.instance.canExpose)
          .where(ContentVisibilityService.instance.isChannelVisible)
          .toList();
    }

    final items = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .categoryNameEqualTo(categoryName.trim())
        .and()
        .contentTypeEqualTo(contentType)
        .sortBySortOrder()
        .offset(offset)
        .limit(limit)
        .findAll();
    if (_shouldShuffle(contentType)) {
      items.shuffle(Random(_seedFor(
          'content:$playlistId:$contentType:${categoryName.trim()}:$offset')));
    }
    return items
        .where(ParentalService.instance.canExpose)
        .where(ContentVisibilityService.instance.isChannelVisible)
        .toList();
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  Future<List<ChannelModel>> getFavorites(int playlistId) async {
    final items = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .isFavoriteEqualTo(true)
        .findAll();
    return items.where(ParentalService.instance.canExpose).toList();
  }

  Future<void> toggleFavorite(int channelId) async {
    await _db.writeTxn(() async {
      final ch = await _db.channelModels.get(channelId);
      if (ch != null) {
        ch.isFavorite = !ch.isFavorite;
        await _db.channelModels.put(ch);
      }
    });
  }

  Future<void> setFavoriteByUrl(String url, bool isFavorite) async {
    await _db.writeTxn(() async {
      final matches =
          await _db.channelModels.filter().urlEqualTo(url).findAll();
      for (final ch in matches) {
        ch.isFavorite = isFavorite;
        await _db.channelModels.put(ch);
      }
    });
  }

  // ── Recent ─────────────────────────────────────────────────────────────────

  Future<List<ChannelModel>> getRecent(int playlistId, {int limit = 20}) async {
    final items = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .lastWatchedIsNotNull()
        .sortByLastWatchedDesc()
        .limit(limit)
        .findAll();
    return items.where(ParentalService.instance.canExpose).toList();
  }

  Future<ChannelModel?> getLastWatched(int playlistId) => _db.channelModels
      .filter()
      .playlistIdEqualTo(playlistId)
      .lastWatchedIsNotNull()
      .sortByLastWatchedDesc()
      .findFirst();

  /// The latest unfinished VOD episode/movie that can safely resume.
  /// Live channels and completed items are deliberately excluded.
  Future<ChannelModel?> getLastResumable(int playlistId) async {
    final candidates = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .lastWatchedIsNotNull()
        .sortByLastWatchedDesc()
        .limit(30)
        .findAll();
    for (final ch in candidates) {
      if (!ParentalService.instance.canExpose(ch)) continue;
      if (ch.contentType == 'tv' || ch.url.trim().isEmpty) continue;
      if (ch.watchedSeconds <= 0 || ch.totalDurationSeconds <= 0) continue;
      final progress = ch.watchedSeconds / ch.totalDurationSeconds;
      if (progress >= 0.03 && progress <= 0.90) return ch;
    }
    return null;
  }

  Future<void> updateWatched(int channelId, int seconds) async {
    await _db.writeTxn(() async {
      final ch = await _db.channelModels.get(channelId);
      if (ch != null) {
        if (seconds <= 0) {
          ch.lastWatched = null;
          ch.watchedSeconds = 0;
          ch.totalDurationSeconds = 0;
        } else {
          ch.lastWatched = DateTime.now();
          ch.watchedSeconds = seconds;
        }
        await _db.channelModels.put(ch);
      }
    });
  }

  Future<void> updateProgressByUrl(
      String url, int seconds, int totalSeconds) async {
    if (totalSeconds <= 0) return;

    await _db.writeTxn(() async {
      final matches =
          await _db.channelModels.filter().urlEqualTo(url).findAll();
      for (final ch in matches) {
        final percent = (seconds / totalSeconds) * 100;

        // Kullanıcı isteği: %3 - %90 arası izleme takibi
        if (percent >= 3 && percent <= 90) {
          ch.lastWatched = DateTime.now();
          ch.watchedSeconds = seconds;
          ch.totalDurationSeconds = totalSeconds;
        } else if (percent > 90) {
          // %90 geçildiyse bitmiş say ama ilerleme çubuğu için süreyi koru
          ch.lastWatched = DateTime.now();
          ch.watchedSeconds = totalSeconds;
          ch.totalDurationSeconds = totalSeconds;
        }
        await _db.channelModels.put(ch);

        // ⚡ PRO FEATURE: Sync to Android TV "Watch Next"
        if (ch.contentType != 'tv') {
          addToWatchNext(ch);
        }
      }
    });
  }

  /// Dizi ana sayfası için her dizinin izleme oranını hesaplar (Bellek Optimize)
  Future<Map<String, double>> getSeriesProgressMap(int playlistId) async {
    // Sadece izlenen dizi bölümlerini çekiyoruz.
    final watchedSeries = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .contentTypeEqualTo('series')
        .and()
        .watchedSecondsGreaterThan(299) // 5 dk ve üzeri izlenenler
        .limit(2000) // Bellek koruması
        .findAll();

    final stats = <String, List<double>>{};
    for (final ch in watchedSeries) {
      if (ch.url.isEmpty || ch.totalDurationSeconds <= 0) continue;
      final key = ch.seriesName?.trim() ?? ch.name.trim();
      final progress =
          (ch.watchedSeconds / ch.totalDurationSeconds).clamp(0.0, 1.0);
      stats.putIfAbsent(key, () => []).add(progress);
    }

    return stats.map((key, progresses) {
      // Dizinin ortalama ilerlemesini dön
      final avg = progresses.reduce((a, b) => a + b) / progresses.length;
      return MapEntry(key, avg);
    });
  }

  /// Returns items that are partially watched (between 3% and 90%)
  /// UPDATED: Only one entry per Series (the latest one)
  Future<List<ChannelModel>> getContinueWatching(int playlistId,
      {int limit = 20}) async {
    final allRecent = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .lastWatchedIsNotNull()
        .and()
        .watchedSecondsGreaterThan(0)
        .and()
        .totalDurationSecondsGreaterThan(0)
        .sortByLastWatchedDesc()
        .findAll();

    final results = <ChannelModel>[];
    final seenSeries = <String>{};

    for (final ch in allRecent) {
      if (results.length >= limit) break;

      // 1. %3 - %90 Filtresi
      final percent = (ch.watchedSeconds / ch.totalDurationSeconds) * 100;
      if (percent < 3 || percent > 90) continue;

      // 2. Dizi Tekilleştirme (Sadece en son izlenen bölüm)
      if (ch.contentType == 'series') {
        final seriesKey =
            ch.seriesName?.trim().toLowerCase() ?? ch.name.trim().toLowerCase();
        if (seenSeries.contains(seriesKey))
          continue; // Daha yenisi zaten eklendi
        seenSeries.add(seriesKey);
      }

      if (ParentalService.instance.canExpose(ch)) results.add(ch);
    }

    return results;
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  Future<ChannelModel?> getById(int id) => _db.channelModels.get(id);

  Future<ChannelModel?> getByUrl(String url) =>
      _db.channelModels.filter().urlEqualTo(url).findFirst();

  /// Builds the bounded playback context for an item opened outside a normal
  /// category screen (for example, Search). This keeps remote up/down
  /// navigation useful without loading an entire large IPTV category into RAM.
  Future<List<ChannelModel>> getPlaybackQueue(ChannelModel selected,
      {int radius = 50}) async {
    if (selected.url.trim().isEmpty) return [selected];

    if (selected.contentType == 'series') {
      final seriesName = selected.seriesName?.trim();
      if (seriesName != null && seriesName.isNotEmpty) {
        final episodes =
            await getSeriesEpisodes(selected.playlistId, seriesName);
        final playable = episodes
            .where((item) => item.url.trim().isNotEmpty)
            .where(ParentalService.instance.canExpose)
            .where(ContentVisibilityService.instance.isChannelVisible)
            .toList(growable: false);
        if (playable.any((item) => item.id == selected.id)) return playable;
      }
    }

    final before = await _db.channelModels
        .filter()
        .playlistIdEqualTo(selected.playlistId)
        .and()
        .categoryNameEqualTo(selected.categoryName.trim())
        .and()
        .contentTypeEqualTo(selected.contentType)
        .and()
        .sortOrderLessThan(selected.sortOrder)
        .sortBySortOrderDesc()
        .limit(radius)
        .findAll();
    final after = await _db.channelModels
        .filter()
        .playlistIdEqualTo(selected.playlistId)
        .and()
        .categoryNameEqualTo(selected.categoryName.trim())
        .and()
        .contentTypeEqualTo(selected.contentType)
        .and()
        .sortOrderGreaterThan(selected.sortOrder)
        .sortBySortOrder()
        .limit(radius)
        .findAll();

    return <ChannelModel>[...before.reversed, selected, ...after]
        .where((item) => item.url.trim().isNotEmpty)
        .where(ParentalService.instance.canExpose)
        .where(ContentVisibilityService.instance.isChannelVisible)
        .toList(growable: false);
  }

  Future<List<ChannelModel>> search(
      {required int playlistId, required String query, int limit = 50}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final items = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .nameContains(trimmed, caseSensitive: false)
        .limit(limit)
        .findAll();
    return items.where(ParentalService.instance.canExpose).toList();
  }

  /// ⚡ PRO FEATURE: Fuzzy search for "Similar results"
  Future<List<ChannelModel>> searchSimilar(
      {required int playlistId, required String query, int limit = 10}) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    // Strategy:
    // 1. Get first word of the query to filter results from DB
    // 2. Perform fuzzy match on this smaller subset (more likely to contain matches)
    final firstWord = trimmed.split(' ').first;

    final subset = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .group((q) => q.nameContains(firstWord, caseSensitive: false))
        .limit(1000)
        .findAll();

    if (subset.isEmpty) return [];

    final fuse = Fuzzy<ChannelModel>(
      subset.where(ParentalService.instance.canExpose).toList(),
      options: FuzzyOptions(
        findAllMatches: true,
        threshold: 0.5,
        keys: [
          WeightedKey(
            name: 'name',
            getter: (ch) => ch.name,
            weight: 1.0,
          ),
        ],
      ),
    );

    final results = fuse.search(trimmed);
    return results.map((r) => r.item).take(limit).toList();
  }

  // ── Series helpers ─────────────────────────────────────────────────────────

  Future<List<ChannelModel>> getSeriesRepresentatives(int playlistId) async {
    // Proactive optimization for memory: get empty URL or Episode 1/null records
    final reps = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .contentTypeEqualTo('series')
        .group(
            (q) => q.urlEqualTo('').or().episodeEqualTo(1).or().episodeIsNull())
        .sortBySortOrder()
        .findAll();

    if (reps.isNotEmpty) return reps;

    // ⚡ PERFORMANS: Last resort fallback'e limit ekleyerek RAM çökmesini engelle
    final all = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .contentTypeEqualTo('series')
        .sortBySortOrder()
        .limit(2000) // Emniyet kemeri: Maksimum 2000 kayıt çek
        .findAll();

    final seen = <String>{};
    final results = <ChannelModel>[];
    for (final ch in all) {
      final key = ch.seriesName?.trim() ?? ch.name.trim();
      if (seen.add(key.toLowerCase())) results.add(ch);
    }
    return results;
  }

  Future<List<ChannelModel>> getSeriesEpisodes(
      int playlistId, String sName) async {
    final trimmed = sName.trim();
    return _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .contentTypeEqualTo('series')
        .and()
        .group((q) => q.seriesNameEqualTo(trimmed).or().nameEqualTo(trimmed))
        .sortBySeason()
        .thenByEpisode()
        .findAll();
  }

  Future<List<ChannelModel>> getEpisodes({
    required int playlistId,
    required String seriesName,
    int? season,
  }) async {
    final trimmed = seriesName.trim();
    var query = _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .contentTypeEqualTo('series')
        .and()
        .group((q) => q.seriesNameEqualTo(trimmed).or().nameEqualTo(trimmed));

    if (season != null) {
      query = query.and().seasonEqualTo(season);
    }

    return query.sortBySeason().thenByEpisode().findAll();
  }

  Future<List<ChannelModel>> getRecentlyAdded(int playlistId,
      {int limit = 20}) async {
    // Read a bounded newest window, then deduplicate series without collapsing
    // every movie whose seriesName is null into a single result.
    final total =
        await _db.channelModels.filter().playlistIdEqualTo(playlistId).count();
    if (total == 0) return [];
    final candidates = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .offset(max(0, total - limit * 8))
        .limit(limit * 8)
        .findAll();
    return _dedupeForShelf(candidates.reversed, limit);
  }

  Future<List<ChannelModel>> getHomeShelf(int playlistId, String contentType,
      {int limit = 20}) async {
    final query = _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .contentTypeEqualTo(contentType);
    final total = await query.count();
    if (total == 0) return [];
    final fetchLimit = min(total, limit * (contentType == 'series' ? 12 : 4));
    final maxOffset = max(0, total - fetchLimit);
    final offset = maxOffset == 0
        ? 0
        : _seedFor('home:$playlistId:$contentType') % (maxOffset + 1);
    final candidates = await query.offset(offset).limit(fetchLimit).findAll();
    candidates.shuffle(Random(_seedFor('home-items:$playlistId:$contentType')));
    return _dedupeForShelf(candidates, limit);
  }

  List<ChannelModel> _dedupeForShelf(
      Iterable<ChannelModel> candidates, int limit) {
    final seen = <String>{};
    final result = <ChannelModel>[];
    for (final ch in candidates) {
      final seriesName = ch.seriesName?.trim();
      final key = ch.contentType == 'series'
          ? 'series:${(seriesName?.isNotEmpty == true ? seriesName! : ch.name).toLowerCase()}'
          : 'id:${ch.id}';
      if (seen.add(key)) result.add(ch);
      if (result.length >= limit) break;
    }
    return result;
  }

  Future<List<ChannelModel>> getRandomDiscovery(int playlistId,
      {int limit = 20}) async {
    final total =
        await _db.channelModels.filter().playlistIdEqualTo(playlistId).count();
    if (total == 0) return [];

    final fetchLimit = limit * 5;
    final randomOffset = (total > fetchLimit)
        ? (DateTime.now().microsecondsSinceEpoch % (total - fetchLimit))
        : 0;

    final all = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .offset(randomOffset)
        .limit(fetchLimit)
        .findAll();

    final seenSeries = <String>{};
    final filtered = <ChannelModel>[];
    for (final ch in all) {
      if (ch.contentType == 'series') {
        final key = (ch.seriesName?.trim().isNotEmpty == true
                ? ch.seriesName!
                : ch.name)
            .toLowerCase();
        if (seenSeries.add(key)) {
          filtered.add(ch);
        }
      } else {
        filtered.add(ch);
      }
      if (filtered.length >= limit) break;
    }
    return filtered;
  }

  Future<void> saveChannels(List<ChannelModel> channels) async {
    await _db.writeTxn(() => _db.channelModels.putAll(channels));
  }

  /// Optimized category count update
  Future<void> updateCategoryCountsForPlaylist(int playlistId) async {
    final cats = await _db.categoryModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .findAll();
    if (cats.isEmpty) return;

    final Map<int, int> finalCounts = {};
    final Map<String, Set<String>> seriesUniqueNames = {};
    final Map<String, int> tvMovieCounts = {};

    // ⚡ BATCH PROCESSING: Tüm kanalları tek tek sorgulamak yerine batch'lerle çekip hafızada sayıyoruz.
    // Bu, 100+ kategori olan listelerde N+1 sorununu çözer.
    int offset = 0;
    const batchSize = 2000;
    bool hasMore = true;

    while (hasMore) {
      final batch = await _db.channelModels
          .filter()
          .playlistIdEqualTo(playlistId)
          .offset(offset)
          .limit(batchSize)
          .findAll();

      for (var ch in batch) {
        final catKey = ch.categoryName;
        if (ch.contentType == 'series') {
          final sName = (ch.seriesName?.trim().isNotEmpty == true
                  ? ch.seriesName!
                  : ch.name)
              .toLowerCase();
          seriesUniqueNames.putIfAbsent(catKey, () => {}).add(sName);
        } else {
          tvMovieCounts[catKey] = (tvMovieCounts[catKey] ?? 0) + 1;
        }
      }

      offset += batchSize;
      if (batch.length < batchSize) hasMore = false;
    }

    // Kategorilere sonuçları eşle
    for (var cat in cats) {
      if (cat.contentType == 'series') {
        finalCounts[cat.id] = seriesUniqueNames[cat.name]?.length ?? 0;
      } else {
        finalCounts[cat.id] = tvMovieCounts[cat.name] ?? 0;
      }
    }

    await _db.writeTxn(() async {
      for (var cat in cats) {
        cat.channelCount = finalCounts[cat.id] ?? 0;
        await _db.categoryModels.put(cat);
      }
    });
  }

  // ── TMDB ───────────────────────────────────────────────────────────────────

  Future<void> saveTmdbMeta({
    required int channelId,
    String? tmdbId,
    String? imdbRating,
    String? poster,
    String? overview,
    String? year,
    bool applyToAllEpisodes = false,
  }) async {
    await _db.writeTxn(() async {
      final ch = await _db.channelModels.get(channelId);
      if (ch == null) return;

      ch.tmdbId = tmdbId ?? ch.tmdbId;
      ch.imdbRating = imdbRating ?? ch.imdbRating;
      ch.tmdbPoster = poster ?? ch.tmdbPoster;
      ch.tmdbOverview = overview ?? ch.tmdbOverview;
      ch.tmdbYear = year ?? ch.tmdbYear;
      await _db.channelModels.put(ch);

      if (applyToAllEpisodes && ch.contentType == 'series') {
        final seriesName = ch.seriesName ?? ch.name;
        final episodes = await _db.channelModels
            .filter()
            .playlistIdEqualTo(ch.playlistId)
            .and()
            .contentTypeEqualTo('series')
            .and()
            .group((q) => q
                .seriesNameEqualTo(seriesName.trim())
                .or()
                .nameEqualTo(seriesName.trim()))
            .findAll();

        for (final ep in episodes) {
          if (ep.id == ch.id) continue;
          ep.tmdbId = tmdbId ?? ep.tmdbId;
          ep.imdbRating = imdbRating ?? ep.imdbRating;
          ep.tmdbPoster = poster ?? ep.tmdbPoster;
          ep.tmdbOverview = overview ?? ep.tmdbOverview;
          ep.tmdbYear = year ?? ep.tmdbYear;
          await _db.channelModels.put(ep);
        }
      }
    });
  }
}
