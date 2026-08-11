import 'package:aladin_iptv_pro/core/platform/aladin_device_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('landscape phones never receive television navigation', () {
    final profile = AladinDeviceProfile.fromSize(const Size(844, 390));
    expect(profile.isPhone, isTrue);
    expect(profile.useTvNavigation, isFalse);
  });

  test('1080p and 720p television surfaces receive TV navigation', () {
    expect(
        AladinDeviceProfile.fromSize(const Size(1920, 1080),
                directionalNavigation: true)
            .isTelevision,
        isTrue);
    expect(
        AladinDeviceProfile.fromSize(const Size(1280, 720),
                directionalNavigation: true)
            .isTelevision,
        isTrue);
  });

  test('portrait tablet keeps compact navigation', () {
    final profile = AladinDeviceProfile.fromSize(const Size(800, 1280));
    expect(profile.isTablet, isTrue);
    expect(profile.useCompactNavigation, isTrue);
  });

  test('landscape tablet and car surfaces receive side navigation', () {
    final profile = AladinDeviceProfile.fromSize(const Size(1280, 720));
    expect(profile.isTablet, isTrue);
    expect(profile.useTvNavigation, isTrue);
    expect(profile.useCompactNavigation, isFalse);
  });
}
