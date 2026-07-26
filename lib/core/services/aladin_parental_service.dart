import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/aladin_channel_model.dart';
import '../state/aladin_app_prefs.dart';

/// Central parental-control policy. Secrets never enter the preferences file.
class ParentalService {
  ParentalService._();
  static final ParentalService instance = ParentalService._();

  static const _secure = FlutterSecureStorage();
  static const _pinHashKey = 'parental_pin_hash_v2';
  static const _pinSaltKey = 'parental_pin_salt_v2';
  static const _legacyPinKey = 'parental_pin';
  static const _adultWords = <String>[
    'adult',
    'adults',
    'xxx',
    '18+',
    '+18',
    'erotic',
    'erotik',
    'porn',
  ];

  DateTime? _unlockedUntil;
  int _failedAttempts = 0;
  DateTime? _blockedUntil;

  bool get isEnabled =>
      AladinPrefs.instance.getBool('parental_enabled', def: false);
  bool get hideLockedContent =>
      AladinPrefs.instance.getBool('parental_hide_locked', def: true);
  int get sessionMinutes =>
      AladinPrefs.instance.getInt('parental_session_minutes', def: 15);
  bool get isSessionUnlocked =>
      _unlockedUntil != null && DateTime.now().isBefore(_unlockedUntil!);
  Duration? get remainingCooldown =>
      _blockedUntil != null && DateTime.now().isBefore(_blockedUntil!)
          ? _blockedUntil!.difference(DateTime.now())
          : null;

  Future<bool> hasPin() async => (await _secure.read(key: _pinHashKey)) != null;

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin:aladin-parental-v2')).toString();

  Future<void> setPin(String newPin) async {
    if (!RegExp(r'^\d{4,6}$').hasMatch(newPin)) {
      throw const FormatException('PIN 4-6 rakam olmalıdır.');
    }
    final random = Random.secure();
    final salt =
        base64Url.encode(List<int>.generate(24, (_) => random.nextInt(256)));
    await _secure.write(key: _pinSaltKey, value: salt);
    await _secure.write(key: _pinHashKey, value: _hash(newPin, salt));
    // Remove the old plaintext preference on upgrade.
    await AladinPrefs.instance.setString(_legacyPinKey, '');
    _failedAttempts = 0;
    _blockedUntil = null;
  }

  Future<bool> verifyPin(String pin, {bool openSession = true}) async {
    if (remainingCooldown != null) return false;
    final salt = await _secure.read(key: _pinSaltKey);
    final expected = await _secure.read(key: _pinHashKey);
    if (salt == null || expected == null) return false;
    final valid = _hash(pin, salt) == expected;
    if (valid) {
      _failedAttempts = 0;
      _blockedUntil = null;
      if (openSession) {
        _unlockedUntil = DateTime.now().add(Duration(minutes: sessionMinutes));
      }
      return true;
    }
    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _failedAttempts = 0;
      _blockedUntil = DateTime.now().add(const Duration(seconds: 30));
    }
    return false;
  }

  void lockSession() => _unlockedUntil = null;

  Future<void> setEnabled(bool enabled) async {
    await AladinPrefs.instance.setBool('parental_enabled', enabled);
    if (!enabled) lockSession();
  }

  Future<void> setHideLockedContent(bool hide) =>
      AladinPrefs.instance.setBool('parental_hide_locked', hide);

  Future<void> setSessionMinutes(int minutes) => AladinPrefs.instance.setInt(
      'parental_session_minutes',
      <int>[15, 30, 60].contains(minutes) ? minutes : 15);

  Set<String> _readSet(String key) {
    try {
      return (jsonDecode(AladinPrefs.instance.getString(key) ?? '[]') as List)
          .map((e) => e.toString())
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _writeSet(String key, Set<String> values) =>
      AladinPrefs.instance.setString(key, jsonEncode(values.toList()..sort()));

  String categoryKey(int playlistId, String categoryName) =>
      '$playlistId:${categoryName.trim().toLowerCase()}';
  String channelKey(ChannelModel channel) =>
      '${channel.playlistId}:${channel.id}';

  bool isAdultCategory(String categoryName) {
    final value = categoryName.toLowerCase();
    return _adultWords.any(value.contains);
  }

  bool isCategoryLocked(int playlistId, String categoryName) {
    if (!isEnabled) return false;
    return isAdultCategory(categoryName) ||
        _readSet('parental_locked_categories_v2')
            .contains(categoryKey(playlistId, categoryName));
  }

  bool isChannelLocked(ChannelModel channel) {
    if (!isEnabled) return false;
    return _readSet('parental_locked_channels_v2')
            .contains(channelKey(channel)) ||
        isCategoryLocked(channel.playlistId, channel.categoryName);
  }

  bool requiresUnlock(ChannelModel channel) =>
      isChannelLocked(channel) && !isSessionUnlocked;

  bool canExpose(ChannelModel channel) =>
      !isChannelLocked(channel) || isSessionUnlocked || !hideLockedContent;

  Future<bool> toggleCategoryLock(int playlistId, String categoryName) async {
    final values = _readSet('parental_locked_categories_v2');
    final key = categoryKey(playlistId, categoryName);
    final locked = !values.remove(key);
    if (locked) values.add(key);
    await _writeSet('parental_locked_categories_v2', values);
    return locked;
  }

  Future<bool> toggleChannelLock(ChannelModel channel) async {
    final values = _readSet('parental_locked_channels_v2');
    final key = channelKey(channel);
    final locked = !values.remove(key);
    if (locked) values.add(key);
    await _writeSet('parental_locked_channels_v2', values);
    return locked;
  }
}
