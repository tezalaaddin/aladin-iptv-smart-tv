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

  test('+49 TV safety and EPG surfaces are localized in all languages', () {
    const keys = [
      'parental',
      'largeText',
      'highContrast',
      'lockedContent',
      'manageLocked',
      'pinProtection',
      'hideLocked',
      'unlockDuration',
      'changePin',
      'lockNow',
      'enterPin',
      'unlock',
      'wrongPin',
      'epgGuide',
      'previousDay',
      'nextDay',
      'noProgram',
      'catchup',
      'fullGuide',
      'healthReport',
      'secureBackup',
      'restoreBackup',
      'serverLatency',
      'accountStatus',
      'subscriptionExpiry',
      'encryptedExport',
      'encryptedImport',
      'frameRate',
      'hideContent',
      'showHidden',
    ];
    for (final language in AppStrings.getLanguageNames().keys) {
      final strings = AppStrings.of(language);
      for (final key in keys) {
        expect(strings.v49(key), isNot(key), reason: '$language/$key');
        expect(strings.v49(key).trim(), isNotEmpty, reason: '$language/$key');
      }
    }
  });
}
