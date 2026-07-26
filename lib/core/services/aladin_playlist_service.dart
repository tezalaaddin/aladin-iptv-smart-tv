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

  Future<String> exportBackup() async {
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
      if (p.type == 'xtream') {
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
        await importXtream(
          server: map['server'],
          username: map['user'],
          password: map['pass'],
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

    final allChannels = <ChannelModel>[];
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
      allChannels.addAll(batch);
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

    final cats = AladinImportBridge.buildCategories(allChannels, playlistId);
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

  Future<void> refreshPlaylist(int playlistId, {ProgressCallback? onProgress}) async {
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
