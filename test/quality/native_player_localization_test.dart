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
      'diag_good',
      'diag_weak',
      'diag_problem',
    ];
    for (final key in requiredKeys) {
      expect(source, contains('t("$key"'), reason: key);
    }
  });

  test('native player exposes a D-pad panel and visible media state', () {
    final activity = File(
      'android/app/src/main/kotlin/com/aladin/iptv/player/pro/NativePlayerActivity.kt',
    ).readAsStringSync();
    final panel = File(
      'android/app/src/main/kotlin/com/aladin/iptv/player/pro/NativePlayerControlPanel.kt',
    ).readAsStringSync();
    final landscape = File(
      'android/app/src/main/res/layout/activity_player.xml',
    ).readAsStringSync();
    final portrait = File(
      'android/app/src/main/res/layout-port/activity_player.xml',
    ).readAsStringSync();

    expect(activity, contains('NativePlayerControlPanel(this).show'));
    expect(activity, contains('updateMediaStateLabel()'));
    expect(panel, contains('first?.requestFocus()'));
    expect(panel, contains('ScrollView(context)'));
    expect(landscape, contains('@+id/tv_media_state'));
    expect(portrait, contains('@+id/tv_media_state'));
  });

  test('native player seek bar has a touch handle and seek preview', () {
    final activity = File(
      'android/app/src/main/kotlin/com/aladin/iptv/player/pro/NativePlayerActivity.kt',
    ).readAsStringSync();
    final landscape = File(
      'android/app/src/main/res/layout/activity_player.xml',
    ).readAsStringSync();
    final portrait = File(
      'android/app/src/main/res/layout-port/activity_player.xml',
    ).readAsStringSync();

    expect(activity, contains('updateTouchSeekPreview'));
    expect(activity, contains('touchSeekAllowed'));
    expect(landscape, contains('@drawable/player_seek_thumb'));
    expect(landscape, contains('@+id/tv_seek_preview'));
    expect(portrait, contains('@drawable/player_seek_thumb'));
    expect(portrait, contains('@+id/tv_seek_preview'));
  });
}
