import 'package:aladin_iptv_pro/core/models/aladin_channel_model.dart';
import 'package:aladin_iptv_pro/core/utils/aladin_episode_deduplicator.dart';
import 'package:flutter_test/flutter_test.dart';

ChannelModel episode(int id, int season, int number, String url) =>
    ChannelModel()
      ..id = id
      ..playlistId = 1
      ..name = 'Series S${season}E$number'
      ..url = url
      ..contentType = 'series'
      ..season = season
      ..episode = number
      ..watchedSeconds = 0
      ..totalDurationSeconds = 0
      ..isFavorite = false;

void main() {
  test('logical duplicate episodes collapse into one ordered row', () {
    final result = deduplicateEpisodes([
      episode(1, 1, 2, 'https://one/2'),
      episode(2, 1, 1, 'https://one/1'),
      episode(3, 1, 1, 'https://duplicate/1'),
      episode(4, 2, 1, 'https://two/1'),
    ]);

    expect(result.map((item) => 'S${item.season}E${item.episode}'), [
      'S1E1',
      'S1E2',
      'S2E1',
    ]);
  });
}
