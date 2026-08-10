import 'package:aladin_iptv_pro/core/state/aladin_app_strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aladin_iptv_pro/features/help/aladin_help_page.dart';
import 'package:aladin_iptv_pro/shared/widgets/aladin_category_row.dart';

void main() {
  test('regional locale codes use the correct compact translation matrix', () {
    expect(AppStrings.of('tr-TR').v52('more'), 'Diğer');
    expect(AppStrings.of('de-DE').v52('more'), 'Mehr');
    expect(AppStrings.of('zh-CN').v52('more'), '更多');
  });

  test('all base language maps have the same keys as English', () {
    final englishKeys = AppStrings.of('en').allTranslations.keys.toSet();
    for (final language in AppStrings.getLanguageNames().keys) {
      final keys = AppStrings.of(language).allTranslations.keys.toSet();
      expect(keys.difference(englishKeys), isEmpty,
          reason: '$language has unexpected base keys');
      expect(englishKeys.difference(keys), isEmpty,
          reason: '$language is missing base keys');
      expect(AppStrings.of(language).allTranslations.values,
          everyElement(isNotEmpty),
          reason: '$language contains an empty translation');
    }
  });

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

  test('+50 dashboard, EPG and hidden-content surfaces are localized', () {
    const languages = ['tr', 'en', 'de', 'fr', 'es', 'ru', 'zh', 'ar'];
    const keys = [
      'noHiddenContent',
      'hiddenCategory',
      'hiddenChannel',
      'showAll',
      'mostWatched',
      'selectedGuideDay',
      'customizeDashboard',
      'watchNextStatus',
      'watchNextEnabled',
      'watchNextUnavailable',
    ];
    for (final language in languages) {
      final strings = AppStrings.of(language);
      for (final key in keys) {
        expect(strings.v50(key), isNot(key), reason: '$language:$key');
        expect(strings.v50(key).trim(), isNotEmpty, reason: '$language:$key');
      }
    }
  });

  test('+51 category navigation panel is localized in all languages', () {
    const languages = ['tr', 'en', 'de', 'fr', 'es', 'ru', 'zh', 'ar'];
    const keys = [
      'categories',
      'openCategories',
      'allCategories',
      'searchCategories',
      'items',
      'manageHidden',
      'pinHint',
    ];
    for (final language in languages) {
      final strings = AppStrings.of(language);
      for (final key in keys) {
        expect(strings.v51(key), isNot(key), reason: '$language:$key');
        expect(strings.v51(key).trim(), isNotEmpty, reason: '$language:$key');
      }
    }
  });

  test('+52 offline help center is complete in every supported language', () {
    for (final language in AladinHelpCatalog.supportedLanguages) {
      final labels = AladinHelpCatalog.labels(language);
      final topics = AladinHelpCatalog.topics(language);
      expect(labels.values.every((value) => value.trim().isNotEmpty), isTrue,
          reason: '$language labels');
      expect(topics.length, 14, reason: '$language topic count');
      for (final topic in topics) {
        expect(topic.title.trim(), isNotEmpty, reason: '$language title');
        expect(topic.summary.trim(), isNotEmpty, reason: '$language summary');
        expect(topic.steps.length, greaterThanOrEqualTo(3),
            reason: '$language:${topic.title}');
      }
    }
  });

  test('+52 settings and player diagnostics are localized', () {
    const languages = ['tr', 'en', 'de', 'fr', 'es', 'ru', 'zh', 'ar'];
    const keys = [
      'cardDensity',
      'cardCompact',
      'cardStandard',
      'cardLarge',
      'bufferEvents',
      'bufferDuration',
      'bufferedAhead',
      'lastPlaybackError',
      'none',
      'droppedFrames',
      'similarOptions',
      'play',
      'pause',
      'channelList',
      'playerTitle',
      'backToList',
      'cancel',
      'nextEpisodeStarting',
      'quickList',
      'channelFallback',
      'retry',
      'shutdownWarning',
      'more',
    ];
    for (final language in languages) {
      final strings = AppStrings.of(language);
      for (final key in keys) {
        expect(strings.v52(key), isNot(key), reason: '$language:$key');
        expect(strings.v52(key).trim(), isNotEmpty, reason: '$language:$key');
      }
    }
  });

  test('native player seek controls are localized in every language', () {
    for (final language in AppStrings.getLanguageNames().keys) {
      final strings = AppStrings.of(language);
      expect(strings.v52('rewind10'), isNot(anyOf('rewind10', isEmpty)));
      expect(strings.v52('forward30'), isNot(anyOf('forward30', isEmpty)));
    }
  });

  test('TV card density presets stay 16:9 and ordered by size', () {
    final compact = TvCardMetrics.fromPreference(null);
    final standard = TvCardMetrics.fromPreference('standard');
    final large = TvCardMetrics.fromPreference('large');

    expect(compact.width / compact.height, closeTo(16 / 9, 0.01));
    expect(standard.width / standard.height, closeTo(16 / 9, 0.01));
    expect(large.width / large.height, closeTo(16 / 9, 0.01));
    expect(compact.width, lessThan(standard.width));
    expect(standard.width, lessThan(large.width));
    expect(compact.rowHeight, lessThan(standard.rowHeight));
    expect(standard.rowHeight, lessThan(large.rowHeight));
  });
}
