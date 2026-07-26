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
  static const _apiUrl =
      'https://api.github.com/repos/$_githubRepo/releases/latest';
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.aladin.iptv.player.pro';

  Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final response = await http.get(Uri.parse(_apiUrl), headers: const {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'aladin-iptv-player-update-check',
      }).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tag = data['tag_name']?.toString() ?? '';
        final parsed = _parseVersion(tag);
        if (parsed == null) {
          return {'hasUpdate': false, 'error': true};
        }

        if (isRemoteVersionGreater(
          parsed.version,
          currentVersion,
          parsed.build,
          currentBuild,
        )) {
          return {
            'hasUpdate': true,
            'version': parsed.version,
            'build': parsed.build,
            'url': playStoreUrl,
            'releaseUrl': data['html_url']?.toString(),
          };
        }
        return {'hasUpdate': false, 'error': false};
      }
      debugPrint('[UpdateService] GitHub status: ${response.statusCode}');
      return {'hasUpdate': false, 'error': true};
    } catch (e) {
      debugPrint('[UpdateService] Check failed: $e');
      return {'hasUpdate': false, 'error': true};
    }
  }

  ({String version, int? build})? _parseVersion(String tag) {
    final match = RegExp(r'(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?').firstMatch(tag);
    if (match == null) return null;
    return (
      version: '${match[1]}.${match[2]}.${match[3]}',
      build: int.tryParse(match[4] ?? ''),
    );
  }

  @visibleForTesting
  bool isRemoteVersionGreater(String newVersion, String currentVersion,
      int? newBuild, int currentBuild) {
    final newV = newVersion.split('.').map(int.parse).toList();
    final currV = currentVersion.split('.').map(int.parse).toList();
    final count = newV.length > currV.length ? newV.length : currV.length;
    for (var i = 0; i < count; i++) {
      final next = i < newV.length ? newV[i] : 0;
      final current = i < currV.length ? currV[i] : 0;
      if (next > current) return true;
      if (next < current) return false;
    }
    if (newBuild == null) return false;
    final normalizedNewBuild = newBuild >= 1000 ? newBuild % 1000 : newBuild;
    final normalizedCurrentBuild =
        currentBuild >= 1000 ? currentBuild % 1000 : currentBuild;
    return normalizedNewBuild > normalizedCurrentBuild;
  }
}
