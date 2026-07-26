import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/aladin_channel_model.dart';
import '../models/aladin_category_model.dart';

class AladinXtreamParser {
  final String server, username, password;
  AladinXtreamParser({
    required this.server,
    required this.username,
    required this.password,
  });

  String get _base => '$server/player_api.php?username=$username&password=$password';

  Future<bool> validate() async {
    try {
      final r = await http.get(Uri.parse(_base)).timeout(const Duration(seconds: 12));
      if (r.statusCode != 200) return false;
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      return j['user_info'] != null;
    } catch (e) {
      debugPrint('[Xtream] validate error: $e');
      return false;
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  /// Kategorileri çeker ve ID -> İsim eşleşmesini içeren bir Map döndürür
  Future<Map<String, String>> fetchCategoryMap(String action) async {
    try {
      final r = await http.get(Uri.parse('$_base&action=$action')).timeout(const Duration(seconds: 15));
      final list = jsonDecode(r.body) as List<dynamic>;
      final map = <String, String>{};
      for (var e in list) {
        final m = e as Map<String, dynamic>;
        final id = m['category_id']?.toString();
        // İsimleri mutlaka trimliyoruz
        final name = m['category_name']?.toString().trim();
        if (id != null && name != null) {
          map[id] = name;
        }
      }
      return map;
    } catch (e) {
      debugPrint('[Xtream] fetchCategoryMap error: $e');
      return {};
    }
  }

  Future<List<CategoryModel>> fetchLiveCategories(int pid) => _cats('get_live_categories', 'tv', pid);
  Future<List<CategoryModel>> fetchVodCategories(int pid) => _cats('get_vod_categories', 'movie', pid);
  Future<List<CategoryModel>> fetchSeriesCategories(int pid) => _cats('get_series_categories', 'series', pid);

  Future<List<CategoryModel>> _cats(String action, String type, int pid) async {
    try {
      final r = await http.get(Uri.parse('$_base&action=$action')).timeout(const Duration(seconds: 15));
      final list = jsonDecode(r.body) as List<dynamic>;
      int order = 0;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        // Kategori listesi oluştururken de isimleri trimliyoruz
        final name = m['category_name']?.toString().trim() ?? 'Unknown';
        return CategoryModel()
          ..name = name
          ..contentType = type
          ..playlistId = pid
          ..channelCount = 0
          ..sortOrder = order++;
      }).toList();
    } catch (e) {
      debugPrint('[Xtream] _cats error: $e');
      return [];
    }
  }

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<List<ChannelModel>> fetchLiveStreams(int pid, Map<String, String> catMap) =>
      _streams('$_base&action=get_live_streams', 'tv', pid, catMap);

  Stream<List<ChannelModel>> fetchVodStreams(int pid, Map<String, String> catMap) =>
      _streams('$_base&action=get_vod_streams', 'movie', pid, catMap);

  Stream<List<ChannelModel>> fetchSeriesStreams(int pid, Map<String, String> catMap) =>
      _fetchSeries('$_base&action=get_series', pid, catMap);

  Stream<List<ChannelModel>> _streams(String url, String type, int pid, Map<String, String> catMap,
      {int batchSize = 200}) async* {
    try {
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 45));
      final list = jsonDecode(r.body) as List<dynamic>;
      int order = 0;
      final batch = <ChannelModel>[];

      for (final item in list) {
        final m = item as Map<String, dynamic>;
        final id = m['stream_id']?.toString() ?? '';
        final catId = m['category_id']?.toString();
        // catMap zaten trimli isimler içeriyor
        final catName = catMap[catId] ?? 'Diğer';

        final hasCatchup = m['tv_archive']?.toString() == '1' || m['catchup']?.toString() == '1';
        final catchupDays = int.tryParse(m['tv_archive_duration']?.toString() ?? '');

        final ext = m['container_extension']?.toString() ?? 'ts';
        final streamUrl = type == 'tv'
            ? '$server/live/$username/$password/$id.ts'
            : '$server/movie/$username/$password/$id.$ext';

        batch.add(ChannelModel()
          ..playlistId = pid
          ..name = (m['name']?.toString() ?? 'Unknown').trim()
          ..url = streamUrl
          ..logoUrl = m['stream_icon']?.toString()
          ..categoryName = catName
          ..groupTitle = catName
          ..tvgId = id
          ..contentType = type
          ..catchupDays = catchupDays
          ..catchupType = hasCatchup ? 'default' : null
          ..sortOrder = order++);

        if (batch.length >= batchSize) {
          yield List.of(batch);
          batch.clear();
        }
      }
      if (batch.isNotEmpty) yield batch;
    } catch (e) {
      debugPrint('[Xtream] _fetchSeries error: $e');
      yield [];
    }
  }

  Stream<List<ChannelModel>> _fetchSeries(String url, int pid, Map<String, String> catMap,
      {int batchSize = 200}) async* {
    try {
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 45));
      final list = jsonDecode(r.body) as List<dynamic>;
      int order = 0;
      final batch = <ChannelModel>[];

      for (final item in list) {
        final m = item as Map<String, dynamic>;
        final seriesId = m['series_id']?.toString() ?? '';
        final catId = m['category_id']?.toString();
        final catName = catMap[catId] ?? 'Diğer';
        final sName = (m['name']?.toString() ?? 'Unknown').trim();

        batch.add(ChannelModel()
          ..playlistId = pid
          ..name = sName
          ..url = '' 
          ..logoUrl = m['cover']?.toString() ?? m['stream_icon']?.toString()
          ..categoryName = catName
          ..groupTitle = catName
          ..tvgId = seriesId
          ..contentType = 'series'
          ..seriesName = sName
          ..sortOrder = order++);

        if (batch.length >= batchSize) {
          yield List.of(batch);
          batch.clear();
        }
      }
      if (batch.isNotEmpty) yield batch;
    } catch (e) {
      debugPrint('[Xtream] _fetchSeries error: $e');
      yield [];
    }
  }

  Future<List<ChannelModel>> fetchSeriesEpisodes(String seriesId, int pid, String categoryName) async {
    try {
      final r = await http.get(Uri.parse('$_base&action=get_series_info&series_id=$seriesId'))
          .timeout(const Duration(seconds: 20));
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final episodesMap = j['episodes'] as Map<String, dynamic>?;
      if (episodesMap == null) return [];

      final List<ChannelModel> results = [];
      final String? seriesMainPoster = j['info']?['cover']?.toString();

      episodesMap.forEach((seasonNum, episodesList) {
        for (var ep in (episodesList as List)) {
          final m = ep as Map<String, dynamic>;
          final id = m['id']?.toString() ?? '';
          final ext = m['container_extension']?.toString() ?? 'mp4';
          final epTitle = (m['title']?.toString() ?? m['name']?.toString() ?? 'Episode').trim();
          final epNumStr = m['episode']?.toString() ?? m['episode_num']?.toString() ?? '';
          
          final epPoster = m['info']?['movie_image']?.toString();

          results.add(ChannelModel()
            ..playlistId = pid
            ..name = epTitle
            ..url = '$server/series/$username/$password/$id.$ext'
            ..logoUrl = (epPoster != null && epPoster.isNotEmpty) ? epPoster : seriesMainPoster
            ..tmdbPoster = seriesMainPoster // Fallback olarak ana posteri de ekleyelim
            ..categoryName = categoryName.trim()
            ..contentType = 'series'
            ..seriesName = (j['info']?['name']?.toString() ?? '').trim()
            ..parentSeriesId = seriesId // Parent series ID'yi saklayalım
            ..season = int.tryParse(seasonNum)
            ..episode = int.tryParse(epNumStr)
            ..tvgId = id
            ..sortOrder = results.length);
        }
      });
      return results;
    } catch (e) {
      debugPrint('[Xtream] fetchSeriesEpisodes error: $e');
      return [];
    }
  }
}
