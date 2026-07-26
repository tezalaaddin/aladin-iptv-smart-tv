import 'package:isar_community/isar.dart';

part 'aladin_channel_model.g.dart';

@collection
class ChannelModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int playlistId;

  @Index()
  late String categoryName;

  @Index()
  late String contentType; // 'tv' | 'movie' | 'series'

  late String name;
  late String url;

  String? logoUrl;
  String? groupTitle;
  String? tvgId;
  String? tvgName;
  String? language;
  String? country;

  /// First quality token e.g. "HD", "FHD", "4K", "HEVC 4K"
  String? quality;

  // Series
  @Index()
  String? seriesName;
  String? parentSeriesId; // Xtream series_id for episodes
  int? season;
  int? episode;

  // TMDB / IMDB cached metadata
  String? tmdbId;
  String? imdbRating;
  String? tmdbPoster;
  String? tmdbOverview;
  String? tmdbYear;

  // Stream headers (#EXTVLCOPT) — stored as "Key: Value\n..." pairs
  String? streamHeaders;

  /// Platform/source identifier parsed from M3U channel name prefix.
  /// Values: 'amazon' | 'disney' | 'hbo_max' | 'mubi' | 'tod' | 'tabii' |
  ///         'apple' | 'netflix' | 'seribox' | 'vod' | 'yerli' |
  ///         'bollywood' | 'marvel' | 'documentary' | 'western' |
  ///         'yesil_cam' | 'action' | 'actor_vod' | null (live TV or unknown)
  String? streamPlatform;

  /// Logo URL sourced from EPG sync.
  /// Used as fallback when [logoUrl] (M3U logo) fails to load.
  String? epgLogoUrl;

  @Index()
  int sortOrder = 0;

  @Index()
  bool isFavorite = false;

  int? catchupDays;
  String? catchupType;

  @Index()
  DateTime? lastWatched;

  int watchedSeconds = 0;
  int totalDurationSeconds = 0;

  /// Xtream dizi bölümlerinin en son API'den çekildiği zaman.
  /// null → bölümler hiç çekilmedi.
  /// 24 saatten eski ise yeniden çekilmesi önerilir.
  DateTime? episodesFetchedAt;

  /// Bölümlerin yeniden çekilmesi gerekip gerekmediğini kontrol eder (24 saat eşiği).
  bool get shouldRefetchEpisodes {
    if (episodesFetchedAt == null) return true;
    return DateTime.now().difference(episodesFetchedAt!).inHours >= 24;
  }
}
