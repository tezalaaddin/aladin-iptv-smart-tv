import '../models/aladin_channel_model.dart';

String _normalized(String? value) => (value ?? '')
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'\b(4k|uhd|fhd|hd|sd|hevc|h265|h264)\b'), ' ')
    .replaceAll(RegExp(r'\b(yedek|backup|alternatif|alternative)\b'), ' ')
    .replaceAll(
        RegExp(
            r'[^a-z0-9\u00c0-\u024f\u0400-\u04ff\u0600-\u06ff\u4e00-\u9fff]+'),
        ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Stable identity for user-facing content. Series episodes intentionally share
/// one identity so Favorites and shelves show a series only once.
String contentIdentity(ChannelModel item) {
  final prefix = '${item.playlistId}:${item.contentType}';
  if (item.contentType == 'series') {
    final series = _normalized(
        item.seriesName?.isNotEmpty == true ? item.seriesName : item.name);
    return '$prefix:title:$series:${_normalized(item.tmdbYear)}';
  }
  if (item.contentType == 'movie') {
    return '$prefix:title:${_normalized(item.name)}:${_normalized(item.tmdbYear)}';
  }
  return '$prefix:name:${_normalized(item.tvgName?.isNotEmpty == true ? item.tvgName : item.name)}';
}

/// Identity for a playable row. Unlike [contentIdentity], episodes remain
/// separate while duplicate URLs for the same logical episode collapse.
String playableIdentity(ChannelModel item) {
  if (item.contentType == 'series' &&
      item.season != null &&
      item.episode != null) {
    return '${contentIdentity(item)}:s${item.season}:e${item.episode}';
  }
  return contentIdentity(item);
}

List<ChannelModel> deduplicateContent(
  Iterable<ChannelModel> source, {
  bool playable = false,
}) {
  final unique = <String, ChannelModel>{};
  for (final item in source) {
    final key = playable ? playableIdentity(item) : contentIdentity(item);
    final current = unique[key];
    if (current == null || _prefer(item, current)) unique[key] = item;
  }
  return unique.values.toList(growable: false);
}

bool _prefer(ChannelModel candidate, ChannelModel current) {
  final candidateWatched = candidate.lastWatched?.millisecondsSinceEpoch ?? 0;
  final currentWatched = current.lastWatched?.millisecondsSinceEpoch ?? 0;
  if (candidateWatched != currentWatched)
    return candidateWatched > currentWatched;
  if (candidate.watchedSeconds != current.watchedSeconds) {
    return candidate.watchedSeconds > current.watchedSeconds;
  }
  final candidateMetadata = _metadataScore(candidate);
  final currentMetadata = _metadataScore(current);
  if (candidateMetadata != currentMetadata)
    return candidateMetadata > currentMetadata;
  if (candidate.contentType == 'series') {
    final candidateOrder =
        (candidate.season ?? 0) * 100000 + (candidate.episode ?? 0);
    final currentOrder =
        (current.season ?? 0) * 100000 + (current.episode ?? 0);
    if (candidateOrder != currentOrder) return candidateOrder > currentOrder;
  }
  return candidate.id > current.id;
}

int _metadataScore(ChannelModel item) {
  var score = item.url.trim().isNotEmpty ? 1 : 0;
  if ((item.logoUrl ?? '').trim().isNotEmpty) score++;
  if ((item.tmdbPoster ?? '').trim().isNotEmpty) score += 2;
  if ((item.tmdbOverview ?? '').trim().isNotEmpty) score++;
  if ((item.tmdbId ?? '').trim().isNotEmpty) score++;
  return score;
}
