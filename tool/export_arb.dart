import 'dart:convert';
import 'dart:io';

import '../lib/core/state/aladin_app_strings.dart';

/// Exports the legacy base localization maps as deterministic ARB seed files.
///
/// The application continues using AppStrings until every v49-v52 call site is
/// migrated. Keeping this exporter in the repository makes that migration
/// reviewable and prevents translators from starting with incomplete maps.
void main(List<String> arguments) {
  final output = Directory(
    arguments.isEmpty ? 'lib/l10n/generated_seed' : arguments.first,
  )..createSync(recursive: true);

  final englishKeys = AppStrings.of('en').allTranslations.keys.toSet();
  for (final language in AppStrings.getLanguageNames().keys) {
    final translations = AppStrings.of(language).allTranslations;
    final missing = englishKeys.difference(translations.keys.toSet());
    final unexpected = translations.keys.toSet().difference(englishKeys);
    if (missing.isNotEmpty || unexpected.isNotEmpty) {
      stderr.writeln(
        '$language key mismatch; missing=$missing unexpected=$unexpected',
      );
      exitCode = 2;
      return;
    }

    final arb = <String, String>{'@@locale': language};
    for (final key in translations.keys.toList()..sort()) {
      arb[key] = translations[key]!;
    }
    final file = File('${output.path}/app_$language.arb');
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(arb),
      flush: true,
    );
    stdout.writeln('${file.path}: ${translations.length} keys');
  }
}
