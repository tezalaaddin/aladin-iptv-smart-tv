import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:fuzzy/fuzzy.dart';
import '../database/aladin_isar_service.dart';
import '../models/aladin_channel_model.dart';
import '../models/aladin_category_model.dart';

class ChannelService {
  ChannelService._();
  static final ChannelService instance = ChannelService._();
  Isar get _db => IsarService.instance.db;

  static const _exoChannel = MethodChannel('aladin/exoplayer');

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

      final data = items.map((e) => {
        'id': e.id.toString(),
        'name': e.name,
        'category': e.categoryName,
        'logo': e.logoUrl ?? '',
        'url': e.url,
      }).toList();

      try {
        await _exoChannel.invokeMethod('syncSearchData', {'items': data});
      } catch (e) {
        debugPrint('[ChannelService] syncSearchData error: $e');
      }
    }
  }

  /// Adds an item to the Android TV "Watch Next" home screen channel
  Future<void> addToWatchNext(ChannelModel ch) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _exoChannel.invokeMethod('addToWatchNext', {
          'title': ch.name,
          'description': ch.tmdbOverview ?? ch.categoryName,
          'poster': ch.tmdbPoster ?? ch.logoUrl ?? '',
          'url': ch.url,
          'contentType': ch.contentType,
        });
      } catch (e) {
        debugPrint('[ChannelService] addToWatchNext error: $e');
      }
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories(
          {required int playlistId, required String contentType}) =>
      _db.categoryModels
          .filter()
          .playlistIdEqualTo(playlistId)
          .and()
          .contentTypeEqualTo(contentType)
          .sortBySortOrder()
          .findAll();

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
          .group((q) => q.urlEqualTo('').or().episodeEqualTo(1).or().episodeIsNull())
          .sortBySortOrder()
          .offset(offset)
          .limit(limit)
          .findAll();

      if (reps.isNotEmpty) return reps;

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

      if (offset >= results.length) return [];
      int end = offset + limit;
      if (end > results.length) end = results.length;
      return results.sublist(offset, end);
    }

    return _db.channelModels
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
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  Future<List<ChannelModel>> getFavorites(int playlistId) => _db.channelModels
      .filter()
      .playlistIdEqualTo(playlistId)
      .and()
      .isFavoriteEqualTo(true)
      .findAll();

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
      final matches = await _db.channelModels.filter().urlEqualTo(url).findAll();
      for (final ch in matches) {
        ch.isFavorite = isFavorite;
        await _db.channelModels.put(ch);
      }
    });
  }

  // ── Recent ─────────────────────────────────────────────────────────────────

  Future<List<ChannelModel>> getRecent(int playlistId, {int limit = 20}) =>
      _db.channelModels
          .filter()
          .playlistIdEqualTo(playlistId)
          .lastWatchedIsNotNull()
          .sortByLastWatchedDesc()
          .limit(limit)
          .findAll();

  Future<ChannelModel?> getLastWatched(int playlistId) =>
      _db.channelModels
          .filter()
          .playlistIdEqualTo(playlistId)
          .lastWatchedIsNotNull()
          .sortByLastWatchedDesc()
          .findFirst();

  Future<void> updateWatched(int channelId, int seconds) async {
    await _db.writeTxn(() async {
      final ch = await _db.channelModels.get(channelId);
      if (ch != null) {
        ch.lastWatched = DateTime.now();
        ch.watchedSeconds = seconds;
        await _db.channelModels.put(ch);
      }
    });
  }

  Future<void> updateProgressByUrl(String url, int seconds, int totalSeconds) async {
    if (totalSeconds <= 0) return;
    
    await _db.writeTxn(() async {
      final matches = await _db.channelModels.filter().urlEqualTo(url).findAll();
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
      final progress = (ch.watchedSeconds / ch.totalDurationSeconds).clamp(0.0, 1.0);
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
  Future<List<ChannelModel>> getContinueWatching(int playlistId, {int limit = 20}) async {
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
        final seriesKey = ch.seriesName?.trim().toLowerCase() ?? ch.name.trim().toLowerCase();
        if (seenSeries.contains(seriesKey)) continue; // Daha yenisi zaten eklendi
        seenSeries.add(seriesKey);
      }

      results.add(ch);
    }

    return results;
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  Future<ChannelModel?> getById(int id) => _db.channelModels.get(id);

  Future<ChannelModel?> getByUrl(String url) =>
      _db.channelModels.filter().urlEqualTo(url).findFirst();

  Future<List<ChannelModel>> search(
      {required int playlistId, required String query, int limit = 50}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];
    
    return _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .nameContains(trimmed, caseSensitive: false)
        .limit(limit)
        .findAll();
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
      subset,
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
        .group((q) => q.urlEqualTo('').or().episodeEqualTo(1).or().episodeIsNull())
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

  Future<List<ChannelModel>> getSeriesEpisodes(int playlistId, String sName) async {
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

  Future<List<ChannelModel>> getRecentlyAdded(int playlistId, {int limit = 20}) async {
    // ⚡ PRO OPTIMIZATION: Use Isar's native distinctBy for deduplication
    final results = await _db.channelModels
        .where()
        .playlistIdEqualTo(playlistId)
        .distinctBySeriesName()
        .limit(limit)
        .findAll();

    return results;
  }

  Future<List<ChannelModel>> getRandomDiscovery(int playlistId, {int limit = 20}) async {
    final total = await _db.channelModels.filter().playlistIdEqualTo(playlistId).count();
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
        final key = (ch.seriesName?.trim().isNotEmpty == true ? ch.seriesName! : ch.name).toLowerCase();
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
    final cats = await _db.categoryModels.filter().playlistIdEqualTo(playlistId).findAll();
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
          final sName = (ch.seriesName?.trim().isNotEmpty == true ? ch.seriesName! : ch.name).toLowerCase();
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
            .group((q) => q.seriesNameEqualTo(seriesName.trim()).or().nameEqualTo(seriesName.trim()))
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
