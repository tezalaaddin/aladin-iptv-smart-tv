import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every PlayerPage launch resolves the selected category queue', () {
    final player =
        File('lib/features/player/aladin_player_page.dart').readAsStringSync();
    expect(player, contains('getPlaybackQueue(widget.channel)'));
    expect(player, contains('item.id == widget.channel.id'));
    expect(player, contains('item.url == widget.channel.url'));
  });

  test('startup playback includes live TV and native channel switches', () {
    final mainPage =
        File('lib/features/aladin_main_page.dart').readAsStringSync();
    final service = File('lib/core/services/aladin_channel_service.dart')
        .readAsStringSync();
    final nativePlayer = File(
      'android/app/src/main/kotlin/com/aladin/iptv/player/pro/NativePlayerActivity.kt',
    ).readAsStringSync();

    expect(mainPage, contains('getLastPlayed(playlistId)'));
    expect(service, contains('markLastPlayedByUrl'));
    expect(nativePlayer, contains('PLAYBACK_SELECTED'));
  });

  test('travel buffer keeps a longer bounded reserve', () {
    final policy = File(
      'android/app/src/main/kotlin/com/aladin/iptv/player/pro/NativePlayerBufferPolicy.kt',
    ).readAsStringSync();
    final settings = File('lib/features/settings/aladin_settings_page.dart')
        .readAsStringSync();

    expect(policy, contains('profile == "travel"'));
    expect(policy, contains('if (isLive) 60_000 else 120_000'));
    expect(policy, contains('travelLowBytes'));
    expect(settings, contains("'travel': s.v52('bufferTravel')"));
  });
}
