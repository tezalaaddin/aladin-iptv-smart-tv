import 'package:aladin_iptv_pro/core/platform/aladin_device_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('layout classification remains deterministic under soak load', () {
    const surfaces = [
      Size(390, 844),
      Size(844, 390),
      Size(1280, 720),
      Size(1920, 1080),
      Size(800, 1280),
    ];
    for (var cycle = 0; cycle < 10000; cycle++) {
      final profile = AladinDeviceProfile.fromSize(
        surfaces[cycle % surfaces.length],
        directionalNavigation: cycle.isEven,
      );
      expect(profile.size.isEmpty, isFalse);
      if (profile.isTelevision) {
        expect(profile.orientation, Orientation.landscape);
      }
    }
  });
}
