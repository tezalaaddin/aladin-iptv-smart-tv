import 'dart:io';

import 'package:aladin_iptv_pro/shared/theme/aladin_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arabic compact navigation golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.live_tv),
                  title: Text('البث المباشر'),
                  subtitle: Text('اختر قناة للمشاهدة'),
                ),
                Spacer(),
                NavigationBar(destinations: [
                  NavigationDestination(
                      icon: Icon(Icons.home), label: 'الرئيسية'),
                  NavigationDestination(
                      icon: Icon(Icons.live_tv), label: 'مباشر'),
                  NavigationDestination(
                      icon: Icon(Icons.more_horiz), label: 'المزيد'),
                ]),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/arabic_compact_navigation.png'),
    );
  }, skip: Platform.environment['RUN_GOLDENS'] != '1');
}
