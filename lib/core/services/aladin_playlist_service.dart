import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar_community/isar.dart';
import '../di/aladin_di.dart';
import '../database/aladin_isar_service.dart';
import '../models/aladin_category_model.dart';
import '../models/aladin_channel_model.dart';
import '../parsers/aladin_import_bridge.dart';
import '../parsers/aladin_xtream_parser.dart';
import '../models/aladin_playlist_model.dart';
import 'aladin_channel_service.dart';
import '../state/aladin_app_prefs.dart';

enum ImportProgress { idle, downloading, parsing, saving, done, error }

typedef ProgressCallback = void Function(ImportProgress status, int count);

class PlaylistService {
  PlaylistService._();
  static final PlaylistService instance = PlaylistService._();

  Isar get _db => sl<IsarService>().db;
  static const _secure = FlutterSecureStorage();

  // ── Secure Storage Helpers ────────────────────────────────────────────────

  Future<void> _savePass(int id, String pass) =>
      _secure.write(key: 'xtream_pass_$id', value: pass);

  Future<String?> getPass(int id) => _secure.read(key: 'xtream_pass_$id');

  Future<void> _deletePass(int id) => _secure.delete(key: 'xtream_pass_$id');

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<List<PlaylistModel>> getAll() async {
    final list = await _db.playlistModels.where().findAll();
    return list.reversed.toList();
  }

  Future<PlaylistModel?> getById(int id) => _db.playlistModels.get(id);

  Future<PlaylistModel?> findByUrl(String url) =>
      _db.playlistModels.filter().urlEqualTo(url).findFirst();

  Future<void> saveStub(PlaylistModel p) async =>
      _db.writeTxn(() => _db.playlistModels.put(p));

  Future<void> rename(int id, String name) async {
    await _db.writeTxn(() async {
      final p = await _db.playlistModels.get(id);
      if (p != null) {
        p.name = name;
        await _db.playlistModels.put(p);
      }
    });
  }

  Future<void> delete(int id) async {
    await _deletePass(id);
    await _db.writeTxn(() async {
      await _db.channelModels.filter().playlistIdEqualTo(id).deleteAll();
      await _db.categoryModels.filter().playlistIdEqualTo(id).deleteAll();
      await _db.playlistModels.delete(id);
    });
  }

  // ── Backup / Export (PRO FEATURE) ─────────────────────────────────────────

  /// Credentials are excluded by default. A UI must obtain explicit consent
  /// before calling this with [includeSecrets] enabled.
  Future<String> exportBackup({bool includeSecrets = false}) async {
    final list = await getAll();
    final List<Map<String, dynamic>> data = [];

    for (final p in list) {
      final map = {
        'name': p.name,
        'url': p.url,
        'type': p.type,
        'server': p.xtreamServer,
        'user': p.xtreamUsername,
      };
      if (p.type == 'xtream' && includeSecrets) {
        map['pass'] = await getPass(p.id);
      }
      data.add(map);
    }
    return jsonEncode(data);
  }

  Future<void> importBackup(String json) async {
    final List<dynamic> data = jsonDecode(json);
    for (final item in data) {
      final map = item as Map<String, dynamic>;
      if (map['type'] == 'xtream') {
        final password = map['pass'] as String?;
        if (password == null || password.isEmpty) {
          throw const FormatException(
              'Bu yedek Xtream şifresi içermiyor; hesap bilgilerini yeniden girin.');
        }
        await importXtream(
          server: map['server'],
          username: map['user'],
          password: password,
          name: map['name'],
        );
      } else {
        await importM3U(
          url: map['url'],
          name: map['name'],
          isLocalFile: map['type'] == 'local',
        );
      }
    }
  }

  /// Full local-state backup without credentials or the parental PIN.
  Future<String> exportAppBackup() async {
    final playlists = await getAll();
    final playlistData = <Map<String, dynamic>>[];
    for (final playlist in playlists) {
      final channels = await _db.channelModels
          .filter()
          .playlistIdEqualTo(playlist.id)
          .findAll();
      playlistData.add({
        'name': playlist.name,
        'url': playlist.url,
        'type': playlist.type,
        'server': playlist.xtreamServer,
        'user': playlist.xtreamUsername,
        'state': channels
            .where((c) => c.isFavorite || c.watchedSeconds > 0)
            .map((c) => {
                  'url': c.url,
                  'favorite': c.isFavorite,
                  'watched': c.watchedSeconds,
                  'duration': c.totalDurationSeconds,
                })
            .toList(),
      });
    }
    final prefs = AladinPrefs.instance;
    return jsonEncode({
      'format': 'aladin-backup-v2',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'playlists': playlistData,
      'settings': {
        'decoderMode': prefs.getString('decoderMode'),
        'preferredQuality': prefs.getString('preferredQuality'),
        'shuffle_on_launch': prefs.shuffleOnLaunch,
        'auto_play_last': prefs.getBool('auto_play_last'),
        'parental_enabled': prefs.getBool('parental_enabled'),
        'parental_hide_locked':
            prefs.getBool('parental_hide_locked', def: true),
        'parental_session_minutes':
            prefs.getInt('parental_session_minutes', def: 15),
        'parental_locked_categories_v2':
            prefs.getString('parental_locked_categories_v2'),
        'parental_locked_channels_v2':
            prefs.getString('parental_locked_channels_v2'),
      },
    });
  }

  Future<void> importAppBackup(String raw) async {
    final root = jsonDecode(raw);
    if (root is List) return importBackup(raw);
    if (root is! Map || root['format'] != 'aladin-backup-v2') {
      throw const FormatException('Desteklenmeyen yedek biçimi.');
    }
    final settings = Map<String, dynamic>.from(root['settings'] ?? const {});
    for (final key in [
      'decoderMode',
      'preferredQuality',
      'parental_locked_categories_v2',
      'parental_locked_channels_v2'
    ]) {
      final value = settings[key];
      if (value is String) await AladinPrefs.instance.setString(key, value);
    }
    for (final key in [
      'shuffle_on_launch',
      'auto_play_last',
      'parental_enabled',
      'parental_hide_locked'
    ]) {
      final value = settings[key];
      if (value is bool) await AladinPrefs.instance.setBool(key, value);
    }
    final minutes = settings['parental_session_minutes'];
    if (minutes is num) {
      await AladinPrefs.instance
          .setInt('parental_session_minutes', minutes.toInt());
    }
    for (final item in (root['playlists'] as List? ?? const [])) {
      final data = Map<String, dynamic>.from(item as Map);
      final existing = await findByUrl(data['url']?.toString() ?? '');
      if (existing == null) continue; // Credentials are intentionally absent.
      for (final stateRaw in (data['state'] as List? ?? const [])) {
        final state = Map<String, dynamic>.from(stateRaw as Map);
        final channel = await _db.channelModels
            .filter()
            .playlistIdEqualTo(existing.id)
            .and()
            .urlEqualTo(state['url']?.toString() ?? '')
            .findFirst();
        if (channel == null) continue;
        channel.isFavorite = state['favorite'] == true;
        channel.watchedSeconds = (state['watched'] as num?)?.toInt() ?? 0;
        channel.totalDurationSeconds =
            (state['duration'] as num?)?.toInt() ?? 0;
        await _db.writeTxn(() => _db.channelModels.put(channel));
      }
    }
    await AladinPrefs.instance.flush();
  }

  /// Local, non-invasive playlist health report. Streams are not opened, so
  /// running this never starts hundreds of network connections on a TV.
  Future<Map<String, int>> getHealthReport(int playlistId) async {
    final channels = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .findAll();
    final urls = <String>{};
    var emptyUrl = 0;
    var duplicates = 0;
    var missingArtwork = 0;
    var missingEpgId = 0;
    for (final channel in channels) {
      final url = channel.url.trim();
      if (url.isEmpty) {
        if (channel.contentType != 'series') emptyUrl++;
      } else if (!urls.add(url)) {
        duplicates++;
      }
      if ((channel.logoUrl ?? channel.tmdbPoster ?? '').trim().isEmpty) {
        missingArtwork++;
      }
      if (channel.contentType == 'tv' && (channel.tvgId ?? '').trim().isEmpty) {
        missingEpgId++;
      }
    }
    return {
      'total': channels.length,
      'emptyUrl': emptyUrl,
      'duplicates': duplicates,
      'missingArtwork': missingArtwork,
      'missingEpgId': missingEpgId,
    };
  }

  Future<Map<String, dynamic>?> getXtreamHealth(PlaylistModel playlist) async {
    if (playlist.type != 'xtream' ||
        playlist.xtreamServer == null ||
        playlist.xtreamUsername == null) return null;
    final password = await getPass(playlist.id);
    if (password == null) return null;
    final watch = Stopwatch()..start();
    final info = await AladinXtreamParser(
      server: playlist.xtreamServer!,
      username: playlist.xtreamUsername!,
      password: password,
    ).fetchAccountInfo();
    watch.stop();
    if (info == null)
      return {'latencyMs': watch.elapsedMilliseconds, 'status': 'Ulaşılamıyor'};
    final expirySeconds = int.tryParse(info['exp_date']?.toString() ?? '');
    return {
      'latencyMs': watch.elapsedMilliseconds,
      'status': info['status']?.toString() ?? 'Bilinmiyor',
      'activeConnections': info['active_cons']?.toString() ?? '-',
      'maxConnections': info['max_connections']?.toString() ?? '-',
      'expiry': expirySeconds == null
          ? 'Belirtilmemiş'
          : DateTime.fromMillisecondsSinceEpoch(expirySeconds * 1000)
              .toLocal()
              .toString()
              .split(' ')
              .first,
    };
  }

  // ── Import M3U ────────────────────────────────────────────────────────────

  Future<PlaylistModel> importM3U({
    required String url,
    required String name,
    bool isLocalFile = false,
    ProgressCallback? onProgress,
  }) async {
    if (!isLocalFile) {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        throw Exception('İnternet bağlantısı yok');
      }
    }
    onProgress?.call(ImportProgress.downloading, 0);

    final existing = await findByUrl(url);
    final playlist = existing ?? PlaylistModel();
    playlist
      ..url = url
      ..name = name
      ..type = isLocalFile ? 'local' : 'm3u'
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..lastUpdated = DateTime.now();

    late int playlistId;
    await _db.writeTxn(() async {
      playlistId = await _db.playlistModels.put(playlist);
    });

    if (existing != null) {
      await _db.writeTxn(() async {
        await _db.channelModels
            .filter()
            .playlistIdEqualTo(playlistId)
            .deleteAll();
        await _db.categoryModels
            .filter()
            .playlistIdEqualTo(playlistId)
            .deleteAll();
      });
    }

    onProgress?.call(ImportProgress.parsing, 0);

    final categoryAccumulator = AladinCategoryAccumulator(playlistId);
    int tv = 0, movie = 0, series = 0, total = 0;

    final stream = isLocalFile
        ? AladinImportBridge.instance.importFromFile(
            url,
            playlistId,
            onProgress: (c) => onProgress?.call(ImportProgress.saving, c),
          )
        : AladinImportBridge.instance.importFromUrl(
            url,
            playlistId,
            onProgress: (c) => onProgress?.call(ImportProgress.saving, c),
          );

    await for (final batch in stream) {
      await _db.writeTxn(() => _db.channelModels.putAll(batch));
      categoryAccumulator.addAll(batch);
      total += batch.length;
      for (final ch in batch) {
        if (ch.contentType == 'tv') {
          tv++;
        } else if (ch.contentType == 'movie') {
          movie++;
        } else {
          series++;
        }
      }
      onProgress?.call(ImportProgress.saving, total);
    }

    final cats = categoryAccumulator.build();
    await _db.writeTxn(() => _db.categoryModels.putAll(cats));

    await _db.writeTxn(() async {
      final p = await _db.playlistModels.get(playlistId);
      if (p != null) {
        p.totalCount = total;
        p.tvCount = tv;
        p.movieCount = movie;
        p.seriesCount = series;
        await _db.playlistModels.put(p);
      }
    });

    onProgress?.call(ImportProgress.done, total);

    // ⚡ PRO FEATURE: Sync to Android TV Global Search
    await ChannelService.instance.syncSearchData(playlistId);

    return (await _db.playlistModels.get(playlistId))!;
  }

  // ── Refresh Playlist ──────────────────────────────────────────────────────

  Future<void> refreshPlaylist(int playlistId,
      {ProgressCallback? onProgress}) async {
    final p = await _db.playlistModels.get(playlistId);
    if (p == null) return;

    if (p.type == 'xtream') {
      final pass = await getPass(p.id);
      if (pass == null) throw Exception('Şifre bulunamadı');

      await importXtream(
        server: p.xtreamServer!,
        username: p.xtreamUsername!,
        password: pass,
        name: p.name,
        onProgress: onProgress,
      );
    } else {
      await importM3U(
        url: p.url,
        name: p.name,
        isLocalFile: p.type == 'local',
        onProgress: onProgress,
      );
    }
  }

  // ── Import Xtream ─────────────────────────────────────────────────────────

  Future<PlaylistModel> importXtream({
    required String server,
    required String username,
    required String password,
    required String name,
    ProgressCallback? onProgress,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      throw Exception('İnternet bağlantısı yok');
    }

    final parser = AladinXtreamParser(
      server: server,
      username: username,
      password: password,
    );
    if (!await parser.validate()) {
      throw Exception('Geçersiz Xtream kimlik bilgileri');
    }

    final url = '$server::$username';
    final existing = await findByUrl(url);
    final playlist = existing ?? PlaylistModel();
    playlist
      ..url = url
      ..name = name
      ..type = 'xtream'
      ..xtreamServer = server
      ..xtreamUsername = username
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..lastUpdated = DateTime.now();

    late int playlistId;
    await _db.writeTxn(() async {
      playlistId = await _db.playlistModels.put(playlist);
    });

    await _savePass(playlistId, password);

    if (existing != null) {
      await _db.writeTxn(() async {
        await _db.channelModels
            .filter()
            .playlistIdEqualTo(playlistId)
            .deleteAll();
        await _db.categoryModels
            .filter()
            .playlistIdEqualTo(playlistId)
            .deleteAll();
      });
    }

    onProgress?.call(ImportProgress.parsing, 0);

    // Kategori Maplerini ve Modellerini çek
    final liveCatMap = await parser.fetchCategoryMap('get_live_categories');
    final vodCatMap = await parser.fetchCategoryMap('get_vod_categories');
    final seriesCatMap = await parser.fetchCategoryMap('get_series_categories');

    final liveCats = await parser.fetchLiveCategories(playlistId);
    final vodCats = await parser.fetchVodCategories(playlistId);
    final seriesCats = await parser.fetchSeriesCategories(playlistId);

    await _db.writeTxn(
      () => _db.categoryModels.putAll([...liveCats, ...vodCats, ...seriesCats]),
    );

    int total = 0, tv = 0, movie = 0, series = 0;

    Future<void> imp(Stream<List<ChannelModel>> st) async {
      await for (final batch in st) {
        await _db.writeTxn(() => _db.channelModels.putAll(batch));
        total += batch.length;
        for (final ch in batch) {
          if (ch.contentType == 'tv') {
            tv++;
          } else if (ch.contentType == 'movie') {
            movie++;
          } else {
            series++;
          }
        }
        onProgress?.call(ImportProgress.saving, total);
      }
    }

    await imp(parser.fetchLiveStreams(playlistId, liveCatMap));
    await imp(parser.fetchVodStreams(playlistId, vodCatMap));
    await imp(parser.fetchSeriesStreams(playlistId, seriesCatMap));

    // Kanal sayılarını veritabanından hesaplayarak güncelle
    await ChannelService.instance.updateCategoryCountsForPlaylist(playlistId);

    await _db.writeTxn(() async {
      final p = await _db.playlistModels.get(playlistId);
      if (p != null) {
        p.totalCount = total;
        p.tvCount = tv;
        p.movieCount = movie;
        p.seriesCount = series;
        await _db.playlistModels.put(p);
      }
    });

    onProgress?.call(ImportProgress.done, total);

    // ⚡ PRO FEATURE: Sync to Android TV Global Search
    await ChannelService.instance.syncSearchData(playlistId);

    return (await _db.playlistModels.get(playlistId))!;
  }
}
