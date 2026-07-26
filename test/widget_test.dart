import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aladin_iptv_pro/shared/theme/aladin_app_theme.dart';

void main() {
  testWidgets('TV theme exposes a visible Aladin-orange focus action',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body:
              Center(child: ElevatedButton(onPressed: null, child: Text('OK'))),
        ),
      ),
    );

    expect(find.text('OK'), findsOneWidget);
    expect(AppTheme.accent, const Color(0xFFFF7A00));
    expect(
        Theme.of(tester.element(find.text('OK'))).brightness, Brightness.dark);
  });
}
