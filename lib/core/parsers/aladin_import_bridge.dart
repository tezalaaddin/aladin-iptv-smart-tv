import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/aladin_iptv_item.dart';
import '../models/aladin_channel_model.dart';
import '../models/aladin_category_model.dart';
import 'aladin_m3u_parser.dart';

/// AladinImportBridge — Orchestration layer between M3U source and Isar.
///
/// Responsibilities:
///   • Download or read M3U content (URL / local file)
///   • Delegate parsing to [AladinM3UParser] (runs in isolate)
///   • Convert [AladinIPTVItem] → [ChannelModel] with all metadata
///   • Yield [ChannelModel] batches for incremental Isar writes
///   • Build [CategoryModel] list preserving M3U order
class AladinImportBridge {
  AladinImportBridge._();
  static final AladinImportBridge instance = AladinImportBridge._();

  // ── Download + parse from URL ─────────────────────────────────────────────

  /// Yields batches of [ChannelModel] ready to be saved to Isar.
  Stream<List<ChannelModel>> importFromUrl(
    String url,
    int playlistId, {
    int batchSize = 200,
    void Function(int parsed)? onProgress,
  }) async* {
    final content = await _downloadContent(url);
    yield* _parseAndConvert(
      content,
      playlistId,
      batchSize: batchSize,
      onProgress: onProgress,
    );
  }

  // ── Read + parse from local file ──────────────────────────────────────────

  Stream<List<ChannelModel>> importFromFile(
    String filePath,
    int playlistId, {
    int batchSize = 200,
    void Function(int parsed)? onProgress,
  }) async* {
    final file = File(filePath);
    if (!file.existsSync()) throw Exception('Dosya bulunamadı: $filePath');
    final bytes = await file.readAsBytes();
    final content = _decodeBytes(bytes);
    yield* _parseAndConvert(
      content,
      playlistId,
      batchSize: batchSize,
      onProgress: onProgress,
    );
  }

  // ── Core pipeline ─────────────────────────────────────────────────────────

  Stream<List<ChannelModel>> _parseAndConvert(
    String content,
    int playlistId, {
    required int batchSize,
    void Function(int)? onProgress,
  }) async* {
    // Parse in isolate (non-blocking)
    final items = await AladinM3UParser.aladinParseM3U(content);

    final batch = <ChannelModel>[];
    int order = 0;

    for (final item in items) {
      batch.add(_toChannelModel(item, playlistId, order++));
      if (batch.length >= batchSize) {
        onProgress?.call(order);
        yield List.of(batch);
        batch.clear();
      }
    }
    if (batch.isNotEmpty) {
      onProgress?.call(order);
      yield batch;
    }
  }

  // ── AladinIPTVItem → ChannelModel ─────────────────────────────────────────

  ChannelModel _toChannelModel(AladinIPTVItem item, int playlistId, int order) {
    // Quality badge: first token only (e.g. "HEVC", "4K", "FHD", "HD")
    final qualityBadge = item.aladinQuality.isNotEmpty
        ? item.aladinQuality.split(' ').first
        : null;

    // Category: use the normalized group from parser
    final categoryName =
        item.aladinGroup.isNotEmpty ? item.aladinGroup : 'Diğer';

    // Content type string
    final contentType = switch (item.aladinType) {
      AladinItemType.movie => 'movie',
      AladinItemType.series => 'series',
      _ => 'tv',
    };

    // Season / episode
    final season = item.aladinSeasonNo ?? int.tryParse(item.aladinSeason);
    final episode = item.aladinEpisodeNo ?? int.tryParse(item.aladinEpisode);

    // Series name
    final seriesName = item.aladinSeriesTitle.isNotEmpty
        ? item.aladinSeriesTitle
        : (item.aladinType == AladinItemType.series ? item.aladinTitle : null);

    // Display name: cleaned title is primary
    final name =
        item.aladinTitle.isNotEmpty ? item.aladinTitle : item.aladinRawName;

    // Country: parser-extracted prefix takes priority, else null
    final country = item.aladinCountry;

    return ChannelModel()
      ..playlistId = playlistId
      ..name = name.isNotEmpty ? name : 'Unknown'
      ..url = item.aladinUrl
      ..tvgId = item.aladinTvgId
      // tvgName stores the raw name (with prefix) for reference & fallback matching
      ..tvgName = item.aladinRawName.isNotEmpty ? item.aladinRawName : null
      ..logoUrl = item.aladinLogo.isNotEmpty ? item.aladinLogo : null
      ..groupTitle = item.aladinGroupRaw ?? item.aladinGroup
      ..categoryName = categoryName
      ..contentType = contentType
      ..quality = qualityBadge
      ..season = season
      ..episode = episode
      ..seriesName = seriesName
      ..imdbRating = item.aladinRating
      ..tmdbYear = item.aladinYear
      ..country = country
      ..streamPlatform = item.aladinPlatform
      ..catchupType = item.aladinCatchupType
      ..catchupDays = item.aladinCatchupDays
      ..sortOrder = order
      ..streamHeaders = _encodeHeaders(item.aladinHeaders);
  }

  // ── Header encoder ────────────────────────────────────────────────────────

  static String? _encodeHeaders(Map<String, String>? h) {
    if (h == null || h.isEmpty) return null;
    return h.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  // ── Category builder ──────────────────────────────────────────────────────

  /// Build [CategoryModel] list preserving M3U order (first-seen = lowest sortOrder).
  static List<CategoryModel> buildCategories(
    Iterable<ChannelModel> channels,
    int playlistId,
  ) {
    final seen = <String, int>{}; // "categoryName__contentType" → order
    final counts = <String, int>{};
    final seriesInCat =
        <String, Set<String>>{}; // categoryName -> Set of seriesNames
    int order = 0;

    for (final ch in channels) {
      final key = '${ch.categoryName}__${ch.contentType}';
      if (!seen.containsKey(key)) {
        seen[key] = order++;
      }

      if (ch.contentType == 'series') {
        final seriesKey =
            ch.seriesName?.trim().toLowerCase() ?? ch.name.trim().toLowerCase();
        seriesInCat.putIfAbsent(ch.categoryName, () => {}).add(seriesKey);
      } else {
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    return seen.entries.map((e) {
      final parts = e.key.split('__');
      final catName = parts[0];
      final contentType = parts[1];

      int count = 0;
      if (contentType == 'series') {
        count = seriesInCat[catName]?.length ?? 0;
      } else {
        count = counts[e.key] ?? 0;
      }

      return CategoryModel()
        ..name = catName
        ..contentType = contentType
        ..playlistId = playlistId
        ..channelCount = count
        ..sortOrder = e.value;
    }).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // ── Download helpers ──────────────────────────────────────────────────────

  static Future<String> _downloadContent(String url) async {
    var uri = Uri.parse(url);
    http.Response? response;

    for (int hop = 0; hop < 5; hop++) {
      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
              'AppleWebKit/537.36 (KHTML, like Gecko) '
              'Chrome/120.0.0.0 Safari/537.36',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: 45));

      if (res.statusCode >= 300 && res.statusCode < 400) {
        final loc = res.headers['location'];
        if (loc == null) break;
        uri = Uri.parse(loc);
        continue;
      }
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode} — $url');
      }
      response = res;
      break;
    }

    if (response == null) throw Exception('Redirect döngüsü — $url');
    return _decodeBytes(response.bodyBytes);
  }

  static String _decodeBytes(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      try {
        return latin1.decode(bytes);
      } catch (_) {
        return String.fromCharCodes(bytes);
      }
    }
  }
}

/// Incremental category counter used during imports so the importer never has
/// to retain every [ChannelModel] in memory.
class AladinCategoryAccumulator {
  final int playlistId;
  final Map<String, int> _order = {};
  final Map<String, int> _counts = {};
  final Map<String, Set<String>> _series = {};

  AladinCategoryAccumulator(this.playlistId);

  void addAll(Iterable<ChannelModel> channels) {
    for (final ch in channels) {
      final key = '${ch.categoryName}__${ch.contentType}';
      _order.putIfAbsent(key, () => _order.length);
      if (ch.contentType == 'series') {
        final name = (ch.seriesName ?? ch.name).trim().toLowerCase();
        _series.putIfAbsent(key, () => <String>{}).add(name);
      } else {
        _counts[key] = (_counts[key] ?? 0) + 1;
      }
    }
  }

  List<CategoryModel> build() => _order.entries.map((entry) {
        final separator = entry.key.lastIndexOf('__');
        return CategoryModel()
          ..name = entry.key.substring(0, separator)
          ..contentType = entry.key.substring(separator + 2)
          ..playlistId = playlistId
          ..channelCount = _series[entry.key]?.length ?? _counts[entry.key] ?? 0
          ..sortOrder = entry.value;
      }).toList();
}
