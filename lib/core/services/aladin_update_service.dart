import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  /// GitHub Releases API üzerinden sürüm kontrolü yapar.
  /// Play Store scraping yerine bu yöntem çok daha güvenilirdir.
  static const _githubRepo = 'tezalaaddin/aladin-iptv-smart-tv';
  static const _apiUrl = 'https://api.github.com/repos/$_githubRepo/releases/latest';

  Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final response = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = (data['tag_name'] as String).replaceAll(RegExp(r'[^0-9.]'), '');
        final downloadUrl = data['html_url'] as String;

        if (_isVersionGreater(latestVersion, currentVersion)) {
          return {
            'hasUpdate': true,
            'version': latestVersion,
            'url': downloadUrl,
          };
        }
      }
    } catch (e) {
      debugPrint('[UpdateService] Check failed: $e');
    }
    return {'hasUpdate': false};
  }

  bool _isVersionGreater(String newVersion, String currentVersion) {
    List<int> newV = newVersion.split('.').map(int.parse).toList();
    List<int> currV = currentVersion.split('.').map(int.parse).toList();
    
    for (var i = 0; i < newV.length; i++) {
      if (i >= currV.length) return true;
      if (newV[i] > currV[i]) return true;
      if (newV[i] < currV[i]) return false;
    }
    return false;
  }
}
