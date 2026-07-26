import 'package:flutter_test/flutter_test.dart';
import 'package:aladin_iptv_pro/core/services/aladin_update_service.dart';

void main() {
  final service = UpdateService.instance;

  test('semantic version has priority over build number', () {
    expect(service.isRemoteVersionGreater('2.3.2', '2.3.1', 1, 1047), isTrue);
    expect(
        service.isRemoteVersionGreater('2.3.0', '2.3.1', 9999, 1047), isFalse);
  });

  test('release suffix compares with normalized Android versionCode', () {
    expect(service.isRemoteVersionGreater('2.3.1', '2.3.1', 48, 1047), isTrue);
    expect(service.isRemoteVersionGreater('2.3.1', '2.3.1', 47, 2047), isFalse);
    expect(
        service.isRemoteVersionGreater('2.3.1', '2.3.1', null, 1047), isFalse);
  });
}
