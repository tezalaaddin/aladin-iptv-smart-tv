import 'dart:convert';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TmdbService {
  TmdbService._();
  static final TmdbService instance = TmdbService._();

  static const _base = 'https://api.themoviedb.org/3';
  static const _imgBase = 'https://image.tmdb.org/t/p/w300';

  // API key'i build zamanında --dart-define=TMDB_API_KEY=xxxx olarak geçin.
  static const _apiKey = String.fromEnvironment('TMDB_API_KEY');

  // Hafıza içi LRU cache (maks 200 giriş)
  final LinkedHashMap<String, Map<String, dynamic>> _seriesCache =
      LinkedHashMap();
  final LinkedHashMap<String, Map<String, dynamic>> _movieCache =
      LinkedHashMap();

  void _putInCache(LinkedHashMap<String, Map<String, dynamic>> cache,
      String key, Map<String, dynamic> val) {
    if (cache.containsKey(key)) {
      cache.remove(key); // Re-insert to move to end (most recent)
    } else if (cache.length >= 200) {
      cache.remove(cache.keys.first); // Remove oldest
    }
    cache[key] = val;
  }

  Map<String, dynamic>? _getFromCache(
      LinkedHashMap<String, Map<String, dynamic>> cache, String key) {
    if (!cache.containsKey(key)) return null;
    final val = cache.remove(key);
    cache[key] = val!; // Move to end
    return val;
  }

  /// Başlıktaki playlist sıra numaralarını, kalite eklerini ve dizi sezon/bölüm bilgilerini temizler.
  String cleanTitle(String title) {
    var cleaned = title.replaceFirst(RegExp(r'^\d+[\.\-\)\s]+'), '').trim();

    // Kalite ve kaynak eklerini temizle
    final noise = [
      '1080p',
      '720p',
      '4k',
      'uhd',
      'fhd',
      'hd',
      'hevc',
      'x264',
      'x265',
      'bluray',
      'brrip',
      'web-dl',
      'webrip',
      'hdtv',
      'dual',
      'tr-en',
      'dublaj',
      'altyazili',
      'netflix',
      'amazon',
      'disney+',
      'hbo',
      'apple tv',
      'bt',
      'ita',
      'multi',
      'subs',
    ];

    for (var n in noise) {
      cleaned =
          cleaned.replaceAll(RegExp('\\b$n\\b', caseSensitive: false), '');
    }

    // Dizi sezon/bölüm ifadelerini temizle (S01 E02, Sezon 1 Bölüm 5 vb.)
    cleaned = cleaned.replaceAll(
        RegExp(r'\bS\d{1,2}\s?E\d{1,3}\b', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(
        RegExp(r'\b(Sezon|Season|Bölüm|Episode)\s?\d{1,3}\b',
            caseSensitive: false),
        '');

    // Gereksiz parantez ve köşeli parantez içlerini temizle
    cleaned = cleaned.replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), '');

    // Birden fazla boşluğu teke indir
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<Map<String, dynamic>?> searchMovie(String title,
      {String? year, String lang = 'tr'}) async {
    // ⚡ GUARD: API Key build zamanında tanımlanmamışsa özelliği kapat
    if (_apiKey.isEmpty) {
      return null;
    }

    final clean = cleanTitle(title);
    final cached = _getFromCache(_movieCache, clean);
    if (cached != null) return cached;

    try {
      final q = Uri.encodeQueryComponent(clean);
      final url =
          '$_base/search/movie?api_key=$_apiKey&query=$q&language=$lang-${lang.toUpperCase()}';

      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>;
      if (results.isEmpty) return null;

      Map<String, dynamic>? bestMatch;

      if (year != null && year.isNotEmpty) {
        for (final item in results) {
          final rDate = item['release_date'] as String?;
          final rYear = rDate?.split('-').firstOrNull;
          if (rYear == year) {
            bestMatch = item as Map<String, dynamic>;
            break;
          }
        }
      }

      bestMatch ??= results.first as Map<String, dynamic>;

      final data = {
        'tmdbId': bestMatch['id']?.toString(),
        'imdbRating': bestMatch['vote_average'] != null
            ? (bestMatch['vote_average'] as num).toStringAsFixed(1)
            : null,
        'poster': bestMatch['poster_path'] != null
            ? '$_imgBase${bestMatch['poster_path']}'
            : null,
        'overview': bestMatch['overview'],
        'year': (bestMatch['release_date'] as String?)?.split('-').firstOrNull,
      };

      _putInCache(_movieCache, clean, data);
      return data;
    } catch (e) {
      debugPrint('[TMDB] searchMovie error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> searchSeries(String title,
      {String? year, String lang = 'tr'}) async {
    // ⚡ GUARD: API Key build zamanında tanımlanmamışsa özelliği kapat
    if (_apiKey.isEmpty) {
      return null;
    }

    final clean = cleanTitle(title);

    // Cache check
    final cached = _getFromCache(_seriesCache, clean);
    if (cached != null) return cached;

    try {
      final q = Uri.encodeQueryComponent(clean);
      final url =
          '$_base/search/tv?api_key=$_apiKey&query=$q&language=$lang-${lang.toUpperCase()}';

      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>;
      if (results.isEmpty) return null;

      Map<String, dynamic>? bestMatch;

      if (year != null && year.isNotEmpty) {
        for (final item in results) {
          final rDate = item['first_air_date'] as String?;
          final rYear = rDate?.split('-').firstOrNull;
          if (rYear == year) {
            bestMatch = item as Map<String, dynamic>;
            break;
          }
        }
      }

      bestMatch ??= results.first as Map<String, dynamic>;

      final data = {
        'tmdbId': bestMatch['id']?.toString(),
        'imdbRating': bestMatch['vote_average'] != null
            ? (bestMatch['vote_average'] as num).toStringAsFixed(1)
            : null,
        'poster': bestMatch['poster_path'] != null
            ? '$_imgBase${bestMatch['poster_path']}'
            : null,
        'overview': bestMatch['overview'],
        'year':
            (bestMatch['first_air_date'] as String?)?.split('-').firstOrNull,
      };

      // Save to cache
      _putInCache(_seriesCache, clean, data);
      return data;
    } catch (e) {
      debugPrint('[TMDB] searchSeries error: $e');
      return null;
    }
  }
}
