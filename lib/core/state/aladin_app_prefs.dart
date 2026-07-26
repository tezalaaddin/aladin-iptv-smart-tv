import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight key-value prefs stored as JSON in app documents dir.
/// Optimized with write debouncing for TV performance.
class AladinPrefs {
  AladinPrefs._();
  static final AladinPrefs instance = AladinPrefs._();

  Map<String, dynamic> _cache = {};
  bool _loaded = false;
  Timer? _saveTimer;
  int _launchShuffleSeed = 0;

  int get launchShuffleSeed => _launchShuffleSeed;
  bool get shuffleOnLaunch => getBool('shuffle_on_launch');

  /// Creates one stable seed for this process. Lists stay stable while the app
  /// is open, but receive a new order after the next cold launch.
  void beginLaunchSession() {
    _launchShuffleSeed = shuffleOnLaunch
        ? DateTime.now().microsecondsSinceEpoch & 0x7fffffff
        : 0;
  }

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/aladin_prefs.json');
  }

  Future<void> load() async {
    if (_loaded) return;
    try {
      final f = await _file;
      if (await f.exists()) {
        final raw = await f.readAsString();
        _cache =
            Map<String, dynamic>.from((raw.isNotEmpty) ? jsonDecode(raw) : {});
        await _migrate();
      }
    } catch (e) {
      debugPrint('[Prefs] load error: $e');
    }
    _loaded = true;
  }

  static const _kCurrentVersion = 1;

  Future<void> _migrate() async {
    final oldVer = getInt('prefs_version', def: 0);
    if (oldVer >= _kCurrentVersion) return;

    // Add migration steps here if needed in future versions
    // Example: if (oldVer < 1) { ... }

    await setInt('prefs_version', _kCurrentVersion);
    await flush();
  }

  /// Debounced save to minimize disk I/O
  void _saveDebounced() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _save();
    });
  }

  Future<void> _save() async {
    try {
      final f = await _file;
      await f.writeAsString(jsonEncode(_cache));
    } catch (_) {}
  }

  String? getString(String key) => _cache[key]?.toString();
  Future<void> setString(String key, String val) async {
    if (_cache[key] == val) return;
    _cache[key] = val;
    _saveDebounced();
  }

  bool getBool(String key, {bool def = false}) => _cache[key] as bool? ?? def;
  Future<void> setBool(String key, bool val) async {
    if (_cache[key] == val) return;
    _cache[key] = val;
    _saveDebounced();
    if (key == 'shuffle_on_launch') beginLaunchSession();
  }

  int getInt(String key, {int def = 0}) =>
      (_cache[key] as num?)?.toInt() ?? def;
  Future<void> setInt(String key, int val) async {
    if (_cache[key] == val) return;
    _cache[key] = val;
    _saveDebounced();
  }

  /// Force immediate save (useful on app exit)
  Future<void> flush() async {
    _saveTimer?.cancel();
    await _save();
  }
}
