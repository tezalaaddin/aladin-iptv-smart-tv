import 'package:flutter_test/flutter_test.dart';
import 'package:aladin_iptv_pro/core/models/aladin_iptv_item.dart';
import 'package:aladin_iptv_pro/core/parsers/aladin_m3u_parser.dart';

void main() {
  test('M3U parser separates live, movie and series records', () async {
    const fixture = '''#EXTM3U
#EXTINF:-1 tvg-id="news.tr" group-title="Haber",TR: Haber HD
https://example.test/live/news.m3u8
#EXTINF:-1 group-title="Filmler",Örnek Film (2025)
https://example.test/movie/demo/movie.mp4
#EXTINF:-1 group-title="Diziler",Örnek Dizi S01E02
https://example.test/series/demo/episode.mp4
''';

    final items = await AladinM3UParser.aladinParseM3U(fixture);

    expect(items, hasLength(3));
    expect(items[0].aladinType, AladinItemType.tv);
    expect(items[0].aladinTvgId, 'news.tr');
    expect(items[0].aladinGroup, isNotEmpty);
    expect(items[1].aladinType, AladinItemType.movie);
    expect(items[2].aladinType, AladinItemType.series);
    expect(items[2].aladinSeasonNo, 1);
    expect(items[2].aladinEpisodeNo, 2);
  });
}
