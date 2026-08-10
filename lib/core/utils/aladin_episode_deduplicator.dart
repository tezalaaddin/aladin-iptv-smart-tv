import '../models/aladin_channel_model.dart';
import 'aladin_content_identity.dart';

/// Produces one stable playable row per logical episode.
/// Providers often repeat the same episode in multiple API pages or groups.
List<ChannelModel> deduplicateEpisodes(Iterable<ChannelModel> source) {
  final unique = <String, ChannelModel>{};
  for (final episode in source) {
    if (episode.url.trim().isEmpty) continue;
    final key = playableIdentity(episode);
    final existing = unique[key];
    if (existing == null ||
        episode.watchedSeconds > existing.watchedSeconds ||
        (existing.tmdbPoster == null && episode.tmdbPoster != null)) {
      unique[key] = episode;
    }
  }
  final result = unique.values.toList(growable: false);
  result.sort((left, right) {
    final seasonOrder = (left.season ?? 0).compareTo(right.season ?? 0);
    if (seasonOrder != 0) return seasonOrder;
    final episodeOrder = (left.episode ?? 0).compareTo(right.episode ?? 0);
    if (episodeOrder != 0) return episodeOrder;
    return left.name.compareTo(right.name);
  });
  return result;
}
