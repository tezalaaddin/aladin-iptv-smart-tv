import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV input waits for an EditableText connection before showing IME', () {
    final dialog =
        File('lib/shared/widgets/aladin_input_dialog.dart').readAsStringSync();

    expect(dialog, contains('WidgetsBinding.instance.endOfFrame'));
    expect(dialog, contains('if (!mounted || !node.hasFocus) return'));
    expect(dialog, contains("invokeMethod<void>('TextInput.show')"));
    expect(dialog, contains('if (mounted && node.hasFocus)'));
  });

  test('dialog buttons cannot steal initial text field focus', () {
    final dialog =
        File('lib/shared/widgets/aladin_input_dialog.dart').readAsStringSync();

    expect(dialog, contains('autofocus: false'));
    expect(dialog, isNot(contains('autofocus: widget.isPrimary')));
    expect(dialog, contains('FocusScope.of(context).requestFocus(node)'));
  });

  test('settings navigation ignores keys while text is being edited', () {
    final settings = File('lib/features/settings/aladin_settings_page.dart')
        .readAsStringSync();

    expect(settings, contains('focusedContext.widget is EditableText'));
    expect(
        settings, contains('if (editingText) return KeyEventResult.ignored'));
  });
}
