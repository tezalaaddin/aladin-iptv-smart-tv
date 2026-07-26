enum AladinItemType { tv, movie, series }

class AladinIPTVItem {
  final String aladinTitle;
  final String aladinRawName;
  final String aladinSeriesTitle;
  final String? aladinTvgId;
  final String? aladinYear;
  final String? aladinRating;
  final String aladinQuality;
  final String aladinGroup;
  final String aladinUrl;
  final String aladinLogo;
  final AladinItemType aladinType;
  final String aladinSeason;
  final String aladinEpisode;
  final Map<String, String>? aladinHeaders;
  final String? aladinKey;
  final String? aladinGroupRaw;
  final String? aladinGroupClean;
  final List<String>? aladinQualityTags;
  final String? aladinTypeReason;
  final String? aladinContainer;
  final int? aladinSeasonNo;
  final int? aladinEpisodeNo;
  final int? aladinLineIndex;

  /// Platform/source identifier extracted from channel name prefix.
  /// Examples: 'amazon', 'disney', 'hbo_max', 'mubi', 'tod', 'tabii',
  ///           'apple', 'netflix', 'vod', 'yerli', 'bollywood', 'marvel'
  final String? aladinPlatform;

  /// ISO country/language code extracted from live-TV channel name prefix.
  /// Examples: 'tr', 'en', 'ar', 'az', 'ku', 'de', 'fr'
  final String? aladinCountry;

  final String? aladinCatchupType;
  final int? aladinCatchupDays;

  const AladinIPTVItem({
    required this.aladinTitle,
    required this.aladinRawName,
    required this.aladinSeriesTitle,
    this.aladinTvgId,
    this.aladinYear,
    this.aladinRating,
    required this.aladinQuality,
    required this.aladinGroup,
    required this.aladinUrl,
    required this.aladinLogo,
    required this.aladinType,
    required this.aladinSeason,
    required this.aladinEpisode,
    this.aladinHeaders,
    this.aladinKey,
    this.aladinGroupRaw,
    this.aladinGroupClean,
    this.aladinQualityTags,
    this.aladinTypeReason,
    this.aladinContainer,
    this.aladinSeasonNo,
    this.aladinEpisodeNo,
    this.aladinLineIndex,
    this.aladinPlatform,
    this.aladinCountry,
    this.aladinCatchupType,
    this.aladinCatchupDays,
  });
}
