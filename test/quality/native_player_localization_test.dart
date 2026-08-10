import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native player visible controls are populated by runtime localization',
      () {
    final source = File(
      'android/app/src/main/kotlin/com/aladin/iptv/player/pro/NativePlayerActivity.kt',
    ).readAsStringSync();
    const requiredKeys = [
      'play',
      'pause',
      'channel_list',
      'player_title',
      'back_to_list',
      'cancel',
      'next_episode_starting',
      'quick_list',
      'channel_fallback',
    ];
    for (final key in requiredKeys) {
      expect(source, contains('t("$key"'), reason: key);
    }
  });
}
