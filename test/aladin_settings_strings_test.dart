import 'package:aladin_iptv_pro/core/state/aladin_app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new playback settings are localized in every supported language', () {
    for (final language in AppStrings.getLanguageNames().keys) {
      final strings = AppStrings.of(language);
      expect(strings.autoPlayStartup, isNot('autoPlayStartup'));
      expect(strings.shuffleLaunch, isNot('shuffleLaunch'));
      expect(strings.softwareLowMemory, isNot('softwareLowMemory'));
      expect(strings.qualityAdaptiveHint, isNot('qualityAdaptiveHint'));
    }
  });
}
