import 'package:aladin_iptv_pro/core/models/aladin_channel_model.dart';
import 'package:aladin_iptv_pro/core/utils/aladin_content_identity.dart';
import 'package:flutter_test/flutter_test.dart';

ChannelModel item({
  required int id,
  required String type,
  required String name,
  String? series,
  int? season,
  int? episode,
  String? year,
}) =>
    ChannelModel()
      ..id = id
      ..playlistId = 7
      ..categoryName = 'category'
      ..contentType = type
      ..name = name
      ..seriesName = series
      ..season = season
      ..episode = episode
      ..tmdbYear = year
      ..url = 'https://source/$id'
      ..isFavorite = true;

void main() {
  test('series favorites collapse to one representative across episodes', () {
    final result = deduplicateContent([
      item(
          id: 1,
          type: 'series',
          name: 'Our Sticky Love',
          series: 'Our Sticky Love',
          season: 1,
          episode: 1),
      item(
          id: 2,
          type: 'series',
          name: 'Our Sticky Love',
          series: 'Our Sticky Love',
          season: 1,
          episode: 6),
      item(
          id: 3,
          type: 'series',
          name: 'Our Sticky Love',
          series: 'Our Sticky Love',
          season: 1,
          episode: 7),
    ]);

    expect(result, hasLength(1));
    expect(result.single.episode, 7);
  });

  test('playback keeps episodes but removes duplicate episode sources', () {
    final result = deduplicateContent([
      item(
          id: 1,
          type: 'series',
          name: 'Show',
          series: 'Show',
          season: 1,
          episode: 1),
      item(
          id: 2,
          type: 'series',
          name: 'Show',
          series: 'Show',
          season: 1,
          episode: 1),
      item(
          id: 3,
          type: 'series',
          name: 'Show',
          series: 'Show',
          season: 1,
          episode: 2),
    ], playable: true);

    expect(result.map((entry) => entry.episode), [1, 2]);
  });

  test('quality and backup suffixes do not create duplicate channels', () {
    final result = deduplicateContent([
      item(id: 1, type: 'tv', name: 'TR: Sports HD'),
      item(id: 2, type: 'tv', name: 'TR Sports FHD (Yedek)'),
    ]);

    expect(result, hasLength(1));
  });

  test('same movie title from different years stays separate', () {
    final result = deduplicateContent([
      item(id: 1, type: 'movie', name: 'The Thing', year: '1982'),
      item(id: 2, type: 'movie', name: 'The Thing', year: '2011'),
    ]);

    expect(result, hasLength(2));
  });
}
