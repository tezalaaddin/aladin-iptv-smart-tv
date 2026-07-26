import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/aladin_iptv_item.dart';

/// AladinM3UParser — High-performance isolate-based M3U parser.
///
/// Extracts per-channel: type, title, IMDb rating, year, quality,
/// group, logo, URL, season/episode, stream headers, container format,
/// stream platform (Amazon/Disney/HBO…) and country code (tr/ar/az…).
///
/// Runs heavy regex work inside a Flutter [compute] isolate to keep UI
/// completely smooth even with 60 000+ channel playlists.
class AladinM3UParser {
  // ── Platform prefix map (VOD sources) ────────────────────────────────────

  static const _kPlatformPrefixes = <String, String>{
    // Streaming platforms
    'AMZN': 'amazon', 'AMAZON': 'amazon',
    'MAX': 'hbo_max', 'HBO': 'hbo_max',
    'MUBI': 'mubi',
    'TOD': 'tod',
    'DP': 'disney', 'DSNP': 'disney', 'DISNEY': 'disney',
    'T': 'tabii', 'TABII': 'tabii',
    'A': 'apple',
    'SERI': 'seribox',
    'NF': 'netflix', 'NETFLIX': 'netflix',
    'GAIN': 'gain',
    'BLUTV': 'blutv', 'BLU': 'blutv',
    'EXXEN': 'exxen',
    'TVP': 'tvp',
    // Content categories
    'D': 'vod', // general dubbed VOD
    'Y': 'yerli', // Turkish domestic films
    'B': 'documentary',
    'W': 'western',
    'BW': 'bollywood',
    'HA': 'action',
    'YA': 'yesil_cam', // classic Turkish cinema
    'MAR': 'marvel',
    'GG': 'actor_vod',
    'IS': 'actor_vod',
  };

  // ── Country prefix map (live TV) ─────────────────────────────────────────

  static const _kCountryPrefixes = <String, String>{
    'TR': 'tr',
    'TUR': 'tr',
    'EN': 'en',
    'UK': 'en',
    'GB': 'en',
    'AR': 'ar',
    'AZ': 'az',
    'KURD': 'ku',
    'RU': 'ru',
    'DE': 'de',
    'FR': 'fr',
    'ES': 'es',
    'IT': 'it',
    'PL': 'pl',
    'NL': 'nl',
    'PT': 'pt',
  };

  // ── Public API ────────────────────────────────────────────────────────────

  /// Parse raw M3U string content → list of [AladinIPTVItem].
  /// Runs in a separate isolate via [compute] to keep UI responsive.
  static Future<List<AladinIPTVItem>> aladinParseM3U(String content) async {
    final List<Map<String, dynamic>> raw = await compute(
      _aladinParseTaskMap,
      content,
    );
    return raw.map(_mapToItem).toList(growable: false);
  }

  // ── Core parse (runs in isolate) ──────────────────────────────────────────

  static List<Map<String, dynamic>> _aladinParseTaskMap(String content) {
    final playlist = <Map<String, dynamic>>[];
    final lines = const LineSplitter().convert(content);

    // Compile regex once
    final qRegex = RegExp(
      r'(HEVC|(?:50|60)\s?FPS|4K|UHD|FHD|1080P|HD\+|HD|720P|SD)',
      caseSensitive: false,
    );
    final imdbRegex = RegExp(
      r'(?:IMDb|IMDB)\s*[:\]\-]?\s*(\d{1,2}(?:[.,]\d{1,2})?)',
      caseSensitive: false,
    );
    final yearRegex = RegExp(r'[\(\[\{]\s*(19\d{2}|20\d{2})\s*[\)\]\}]');
    final seRegex =
        RegExp(r'\bS(\d{1,2})\s*E(\d{1,3})\b', caseSensitive: false);
    final diziStartRx = RegExp(r'^\s*DIZI\b', caseSensitive: false);
    final diziPfxRx = RegExp(
      r'^\s*DIZI\s+[A-ZÇĞİÖŞÜ]+\s*:\s*',
      caseSensitive: false,
    );
    final dateRx = RegExp(r'\b(\d{2}\.\d{2}\.\d{4})\b');
    final tvgNameRx = RegExp(r'tvg-name="(.*?)"', caseSensitive: false);
    final tvgIdRx = RegExp(r'tvg-id="(.*?)"', caseSensitive: false);
    final logoRx = RegExp(r'tvg-logo="(.*?)"', caseSensitive: false);
    final groupRx = RegExp(r'group-title="(.*?)"', caseSensitive: false);
    final catchupRx = RegExp(r'catchup="([^"]*)"', caseSensitive: false);
    final catchupDaysRx = RegExp(r'catchup-days="(\d+)"', caseSensitive: false);
    final vlcOptRx = RegExp(r'^#EXTVLCOPT:(.*)$', caseSensitive: false);
    final videoExtRx = RegExp(
      r'\.(mkv|mp4|avi|mov|wmv|flv|mpg|mpeg|m4v)$',
      caseSensitive: false,
    );
    final uaAttrRx = RegExp(r'http-user-agent="([^"]*)"', caseSensitive: false);
    final refAttrRx = RegExp(r'http-referrer="([^"]*)"', caseSensitive: false);
    // Prefix pattern: up to 6 uppercase/lowercase chars before | or :
    final prefixRx = RegExp(r'^([A-ZÇĞİÖŞÜa-zçğışöü]{1,6})\s*[|:]\s*');

    for (int i = 0; i < lines.length; i++) {
      final extinf = lines[i].trim();
      if (!extinf.startsWith('#EXTINF:')) continue;

      final scan = _scanUrlAndOptions(
        lines: lines,
        startIndex: i + 1,
        vlcOptRx: vlcOptRx,
      );
      final url = scan.url;
      if (url.isEmpty || !url.startsWith('http')) continue;

      // Display name (after last comma)
      final commaIdx = extinf.lastIndexOf(',');
      final rawNameOriginal =
          commaIdx >= 0 ? extinf.substring(commaIdx + 1).trim() : '';

      // tvg-name attribute
      final tvgNameAttr = tvgNameRx.firstMatch(extinf)?.group(1)?.trim() ?? '';
      final tvgIdAttr = tvgIdRx.firstMatch(extinf)?.group(1)?.trim();

      // aladinRawName: prefer tvg-name, fall back to display name
      final aladinRawName =
          tvgNameAttr.isNotEmpty ? tvgNameAttr : rawNameOriginal;

      // Hybrid metadata source
      final metaSource = '$tvgNameAttr | $rawNameOriginal';

      if (_isSeparator(rawNameOriginal)) continue;

      final logo = logoRx.firstMatch(extinf)?.group(1) ?? '';
      final groupRaw = groupRx.firstMatch(extinf)?.group(1) ?? 'Genel';
      final catchupType = catchupRx.firstMatch(extinf)?.group(1);
      final catchupDaysStr = catchupDaysRx.firstMatch(extinf)?.group(1);
      final catchupDays = int.tryParse(catchupDaysStr ?? '');

      final group = _normalizeGroup(groupRaw);
      final lowerUrl = url.toLowerCase();

      // ── Platform / country prefix extraction ───────────────────────────────
      String? platform;
      String? country;
      final prefixSrc = tvgNameAttr.isNotEmpty ? tvgNameAttr : rawNameOriginal;
      final pfxMatch = prefixRx.firstMatch(prefixSrc);
      if (pfxMatch != null) {
        final pfx = pfxMatch.group(1)!.toUpperCase();
        if (_kPlatformPrefixes.containsKey(pfx)) {
          platform = _kPlatformPrefixes[pfx];
        } else if (_kCountryPrefixes.containsKey(pfx)) {
          country = _kCountryPrefixes[pfx];
        }
      }

      // ── Content type detection ─────────────────────────────────────────────
      final seMatch = seRegex.firstMatch(metaSource);
      final isDizi = diziStartRx.hasMatch(metaSource);
      final looksSeries =
          lowerUrl.contains('/series/') || seMatch != null || isDizi;
      final looksMovie =
          lowerUrl.contains('/movie/') || videoExtRx.hasMatch(lowerUrl);

      AladinItemType type = AladinItemType.tv;
      String typeReason = 'default-tv';
      String sNum = '', eNum = '', sTitle = '';
      int? sNo, eNo;

      if (looksSeries) {
        type = AladinItemType.series;
        if (isDizi) {
          typeReason = 'prefix:DIZI';
          var show = rawNameOriginal.replaceFirst(diziPfxRx, '').trim();
          final dm = dateRx.firstMatch(show);
          if (dm != null) {
            eNum = dm.group(1)!;
            sNum = eNum.split('.').last;
            show = show.replaceAll(eNum, '').trim();
          }
          sTitle = show.replaceAll(RegExp(r'[\(\)\[\]\{\}]'), '').trim();
        } else if (seMatch != null) {
          typeReason = 'pattern:SxxExx';
          sNum = seMatch.group(1)!;
          eNum = seMatch.group(2)!;
          sNo = int.tryParse(sNum);
          eNo = int.tryParse(eNum);
          sTitle = rawNameOriginal.split(seMatch.group(0)!).first.trim();
        } else {
          typeReason = 'url:/series/';
        }
      } else if (looksMovie) {
        type = AladinItemType.movie;
        typeReason = lowerUrl.contains('/movie/') ? 'url:/movie/' : 'ext:video';
      }

      // ── IMDb ──────────────────────────────────────────────────────────────
      final imdbM = imdbRegex.firstMatch(metaSource);
      String? rating = imdbM?.group(1)?.replaceAll(',', '.');
      if (rating != null && (double.tryParse(rating) ?? 0) <= 0) rating = null;

      // ── Year ──────────────────────────────────────────────────────────────
      final yMatches = yearRegex.allMatches(metaSource).toList();
      final year = yMatches.isNotEmpty ? yMatches.last.group(1) : null;

      // ── Quality ───────────────────────────────────────────────────────────
      final qTags = qRegex
          .allMatches(metaSource)
          .map((m) => _normalizeQualityToken(m.group(0)!))
          .toSet();
      final quality = _buildOrderedQualityString(qTags);

      // ── Title ─────────────────────────────────────────────────────────────
      final title = (isDizi && sTitle.isNotEmpty)
          ? sTitle
          : _cleanTitle(rawNameOriginal, qRegex, imdbRegex, yearRegex);

      // ── Headers ───────────────────────────────────────────────────────────
      final Map<String, String>? headers = _buildHeaders(
        extinf: extinf,
        vlcHeaders: scan.headers,
        uaRx: uaAttrRx,
        refRx: refAttrRx,
      );

      // ── Dedup key ─────────────────────────────────────────────────────────
      final key = '${type.name}|$url|$sTitle|$sNum|$eNum';

      playlist.add({
        'aladinTitle': title,
        'aladinRawName': aladinRawName,
        'aladinSeriesTitle': sTitle,
        'aladinTvgId': tvgIdAttr,
        'aladinYear': year,
        'aladinRating': rating,
        'aladinQuality': quality,
        'aladinGroup': group,
        'aladinGroupRaw': groupRaw,
        'aladinUrl': url,
        'aladinLogo': logo,
        'aladinType': type.name,
        'aladinSeason': sNum,
        'aladinEpisode': eNum,
        'aladinSeasonNo': sNo,
        'aladinEpisodeNo': eNo,
        'aladinTypeReason': typeReason,
        'aladinContainer': _detectContainer(lowerUrl),
        'aladinKey': key,
        'aladinHeaders': headers,
        'aladinLineIndex': i,
        'aladinQualityTags': qTags.toList(),
        'aladinPlatform': platform,
        'aladinCountry': country,
        'aladinCatchupType': catchupType,
        'aladinCatchupDays': catchupDays,
      });
    }
    return playlist;
  }

  // ── URL + VLC option scanner ──────────────────────────────────────────────

  static _AladinScanResult _scanUrlAndOptions({
    required List<String> lines,
    required int startIndex,
    required RegExp vlcOptRx,
  }) {
    final headers = <String, String>{};
    for (int j = startIndex; j < lines.length; j++) {
      final l = lines[j].trim();
      if (l.startsWith('#EXTINF:')) break;
      if (l.startsWith('http')) {
        return _AladinScanResult(url: l, headers: headers);
      }
      final vlc = vlcOptRx.firstMatch(l);
      if (vlc != null) {
        final opt = vlc.group(1)!;
        if (opt.startsWith('http-user-agent=')) {
          headers['User-Agent'] = opt.substring('http-user-agent='.length);
        } else if (opt.startsWith('http-referrer=')) {
          headers['Referer'] = opt.substring('http-referrer='.length);
        }
      }
    }
    return _AladinScanResult(url: '', headers: headers);
  }

  static Map<String, String>? _buildHeaders({
    required String extinf,
    required Map<String, String> vlcHeaders,
    required RegExp uaRx,
    required RegExp refRx,
  }) {
    final h = Map<String, String>.from(vlcHeaders);
    final ua = uaRx.firstMatch(extinf)?.group(1);
    final ref = refRx.firstMatch(extinf)?.group(1);
    if (ua != null) h['User-Agent'] = ua;
    if (ref != null) h['Referer'] = ref;
    return h.isEmpty ? null : h;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _normalizeQualityToken(String t) {
    t = t.toUpperCase().trim();
    if (t.contains('50FPS')) return '50FPS';
    if (t.contains('60FPS')) return '60FPS';
    return t.replaceAll(' ', '');
  }

  static String _buildOrderedQualityString(Set<String> tags) {
    if (tags.isEmpty) return '';
    const order = [
      'HEVC',
      '4K',
      'UHD',
      'FHD',
      '1080P',
      'HD+',
      'HD',
      '720P',
      'SD',
      '60FPS',
      '50FPS'
    ];
    return order.where(tags.contains).join(' ');
  }

  /// Strip quality tags, IMDb, year, prefix, and cleanup whitespace.
  static String _cleanTitle(String r, RegExp q, RegExp im, RegExp y) {
    const suffixes = [
      'NF',
      'AMZN',
      'DSNP',
      'TVP',
      'YERLI',
      'HBO',
      'MAX',
      'APLUS',
      'PRMR',
      'APPLE',
      'MUBI',
      'GAIN',
      'BLUTV',
      'EXXEN',
      'DISNEY',
    ];
    var s = r;
    s = s.replaceAll(im, '');
    s = s.replaceAll(y, '');
    s = s.replaceAll(q, '');
    // Country/platform prefix: "TR |", "AMZN |", "D |" etc.
    s = s.replaceAll(RegExp(r'^[A-ZÇĞİÖŞÜa-z]{1,6}\s*[|:]\s*'), '');
    s = s.replaceAll(RegExp(r'^#+\s*'), '');
    s = s.replaceAll(RegExp(r'^►\s*'), '');
    // Trailing platform tags
    for (final sfx in suffixes) {
      s = s.replaceAll(RegExp('\\s+$sfx\\s*\$'), '');
    }
    // Trailing parenthetical: "(Yayin 1)", "(50 FPS)"
    s = s.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '');
    // Remaining empty brackets
    s = s.replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), '');
    s = s.replaceAll(RegExp(r'[._]'), ' ');
    s = s.replaceAll('#', '');
    return s.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  }

  static bool _isSeparator(String n) =>
      n.trim().isEmpty ||
      n.contains('####') ||
      n.contains('****') ||
      RegExp(r'^[#\*\-_= ]{3,}$').hasMatch(n);

  static String _normalizeGroup(String r) =>
      r.replaceAll(RegExp(r'\s{2,}'), ' ').trim();

  static String _detectContainer(String u) =>
      RegExp(r'\.(m3u8|mpd|mkv|mp4|avi|mov|wmv|flv|mpg|mpeg|m4v)$')
          .firstMatch(u.split('?').first)
          ?.group(1) ??
      '';

  // ── Model mapper ──────────────────────────────────────────────────────────

  static AladinIPTVItem _mapToItem(Map<String, dynamic> m) {
    final rawHeaders = m['aladinHeaders'];
    Map<String, String>? headers;
    if (rawHeaders is Map) {
      headers = rawHeaders.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    final rawQTags = m['aladinQualityTags'];
    List<String>? qTags;
    if (rawQTags is List) {
      qTags = rawQTags.map((e) => e.toString()).toList();
    }
    return AladinIPTVItem(
      aladinTitle: m['aladinTitle']?.toString() ?? '',
      aladinRawName: m['aladinRawName']?.toString() ?? '',
      aladinSeriesTitle: m['aladinSeriesTitle']?.toString() ?? '',
      aladinTvgId: m['aladinTvgId']?.toString(),
      aladinYear: m['aladinYear']?.toString(),
      aladinRating: m['aladinRating']?.toString(),
      aladinQuality: m['aladinQuality']?.toString() ?? '',
      aladinGroup: m['aladinGroup']?.toString() ?? 'Genel',
      aladinGroupRaw: m['aladinGroupRaw']?.toString(),
      aladinUrl: m['aladinUrl']?.toString() ?? '',
      aladinLogo: m['aladinLogo']?.toString() ?? '',
      aladinType: AladinItemType.values.byName(
        m['aladinType']?.toString() ?? 'tv',
      ),
      aladinSeason: m['aladinSeason']?.toString() ?? '',
      aladinEpisode: m['aladinEpisode']?.toString() ?? '',
      aladinSeasonNo: m['aladinSeasonNo'] as int?,
      aladinEpisodeNo: m['aladinEpisodeNo'] as int?,
      aladinTypeReason: m['aladinTypeReason']?.toString(),
      aladinContainer: m['aladinContainer']?.toString(),
      aladinKey: m['aladinKey']?.toString(),
      aladinHeaders: headers,
      aladinQualityTags: qTags,
      aladinLineIndex: m['aladinLineIndex'] as int?,
      aladinPlatform: m['aladinPlatform']?.toString(),
      aladinCountry: m['aladinCountry']?.toString(),
      aladinCatchupType: m['aladinCatchupType']?.toString(),
      aladinCatchupDays: m['aladinCatchupDays'] as int?,
    );
  }
}

class _AladinScanResult {
  final String url;
  final Map<String, String> headers;
  const _AladinScanResult({required this.url, this.headers = const {}});
}
