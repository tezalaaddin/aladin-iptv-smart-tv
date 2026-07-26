import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/aladin_channel_model.dart';
import '../state/aladin_app_prefs.dart';

/// Central parental-control policy. Secrets never enter the preferences file.
class ParentalService {
  ParentalService._();
  static final ParentalService instance = ParentalService._();

  static const _secure = FlutterSecureStorage();
  static const _pinHashKey = 'parental_pin_hash_v3';
  static const _pinSaltKey = 'parental_pin_salt_v3';
  static const _pinIterationsKey = 'parental_pin_iterations_v3';
  static const _failedAttemptsKey = 'parental_failed_attempts_v3';
  static const _blockedUntilKey = 'parental_blocked_until_v3';
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

  Future<bool> hasPin() async =>
      (await _secure.read(key: _pinHashKey)) != null ||
      (await _secure.read(key: 'parental_pin_hash_v2')) != null;

  Future<String> _derive(String pin, String salt, int iterations) => compute(
        _pbkdf2Worker,
        {'pin': pin, 'salt': salt, 'iterations': iterations},
      );

  Future<void> _loadThrottle() async {
    _failedAttempts =
        int.tryParse(await _secure.read(key: _failedAttemptsKey) ?? '0') ?? 0;
    final millis =
        int.tryParse(await _secure.read(key: _blockedUntilKey) ?? '0');
    _blockedUntil = millis == null || millis <= 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> _saveThrottle() async {
    await _secure.write(
        key: _failedAttemptsKey, value: _failedAttempts.toString());
    await _secure.write(
        key: _blockedUntilKey,
        value: (_blockedUntil?.millisecondsSinceEpoch ?? 0).toString());
  }

  Future<void> setPin(String newPin) async {
    if (!RegExp(r'^\d{4,6}$').hasMatch(newPin)) {
      throw const FormatException('PIN 4-6 rakam olmalıdır.');
    }
    final random = Random.secure();
    final salt =
        base64Url.encode(List<int>.generate(24, (_) => random.nextInt(256)));
    const iterations = 60000;
    await _secure.write(key: _pinSaltKey, value: salt);
    await _secure.write(
        key: _pinHashKey, value: await _derive(newPin, salt, iterations));
    await _secure.write(key: _pinIterationsKey, value: iterations.toString());
    await _secure.delete(key: 'parental_pin_hash_v2');
    await _secure.delete(key: 'parental_pin_salt_v2');
    // Remove the old plaintext preference on upgrade.
    await AladinPrefs.instance.setString(_legacyPinKey, '');
    _failedAttempts = 0;
    _blockedUntil = null;
    await _saveThrottle();
  }

  Future<bool> verifyPin(String pin, {bool openSession = true}) async {
    await _loadThrottle();
    if (remainingCooldown != null) return false;
    final salt = await _secure.read(key: _pinSaltKey);
    final expected = await _secure.read(key: _pinHashKey);
    bool valid = false;
    if (salt != null && expected != null) {
      final iterations =
          int.tryParse(await _secure.read(key: _pinIterationsKey) ?? '') ??
              60000;
      valid =
          _constantTimeEquals(await _derive(pin, salt, iterations), expected);
    } else {
      final oldSalt = await _secure.read(key: 'parental_pin_salt_v2');
      final oldExpected = await _secure.read(key: 'parental_pin_hash_v2');
      if (oldSalt != null && oldExpected != null) {
        final oldHash = sha256
            .convert(utf8.encode('$oldSalt:$pin:aladin-parental-v2'))
            .toString();
        valid = _constantTimeEquals(oldHash, oldExpected);
        if (valid) await setPin(pin);
      }
    }
    if (valid) {
      _failedAttempts = 0;
      _blockedUntil = null;
      await _saveThrottle();
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
    await _saveThrottle();
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
  String channelKey(ChannelModel channel) {
    final identity = channel.tvgId?.trim().isNotEmpty == true
        ? 'tvg:${channel.tvgId!.trim().toLowerCase()}'
        : channel.url.trim().isNotEmpty
            ? 'url:${channel.url.trim()}'
            : 'name:${channel.contentType}:${channel.name.trim().toLowerCase()}';
    return 'v3:${sha256.convert(utf8.encode(identity))}';
  }

  String _legacyChannelKey(ChannelModel channel) =>
      '${channel.playlistId}:${channel.id}';

  Future<int> migrateLegacyChannelLocks(Iterable<ChannelModel> channels) async {
    final legacy = _readSet('parental_locked_channels_v2');
    if (legacy.isEmpty) return 0;
    final stable = _readSet('parental_locked_channels_v3');
    var migrated = 0;
    for (final channel in channels) {
      if (legacy.remove(_legacyChannelKey(channel))) {
        final key = channelKey(channel);
        stable.add(key);
        await _saveChannelLabel(key, channel);
        migrated++;
      }
    }
    await _writeSet('parental_locked_channels_v3', stable);
    await _writeSet('parental_locked_channels_v2', legacy);
    return migrated;
  }

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
    return _readSet('parental_locked_channels_v3')
            .contains(channelKey(channel)) ||
        _readSet('parental_locked_channels_v2')
            .contains(_legacyChannelKey(channel)) ||
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
    final values = _readSet('parental_locked_channels_v3');
    final key = channelKey(channel);
    final locked = !values.remove(key);
    if (locked) {
      values.add(key);
      await _saveChannelLabel(key, channel);
    } else {
      await _removeChannelLabel(key);
    }
    await _writeSet('parental_locked_channels_v3', values);
    return locked;
  }

  Map<String, Map<String, String>> _channelLabels() {
    try {
      final decoded = jsonDecode(
          AladinPrefs.instance.getString('parental_channel_labels_v3') ?? '{}');
      return (decoded as Map<String, dynamic>).map((key, value) => MapEntry(
          key,
          Map<String, String>.from(
              (value as Map).map((k, v) => MapEntry('$k', '$v')))));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveChannelLabel(String key, ChannelModel channel) async {
    final labels = _channelLabels();
    labels[key] = {
      'name': channel.name,
      'category': channel.categoryName,
      'type': channel.contentType,
    };
    await AladinPrefs.instance
        .setString('parental_channel_labels_v3', jsonEncode(labels));
  }

  Future<void> _removeChannelLabel(String key) async {
    final labels = _channelLabels()..remove(key);
    await AladinPrefs.instance
        .setString('parental_channel_labels_v3', jsonEncode(labels));
  }

  List<LockedContentEntry> get lockedContent {
    final labels = _channelLabels();
    final result = <LockedContentEntry>[];
    for (final key in _readSet('parental_locked_channels_v3')) {
      final label = labels[key];
      result.add(LockedContentEntry(
        key: key,
        name: label?['name'] ?? 'Kilitli içerik',
        subtitle: label?['category'] ?? label?['type'] ?? '',
        isCategory: false,
      ));
    }
    for (final key in _readSet('parental_locked_categories_v2')) {
      final separator = key.indexOf(':');
      result.add(LockedContentEntry(
        key: key,
        name: separator >= 0 ? key.substring(separator + 1) : key,
        subtitle: 'Kategori',
        isCategory: true,
      ));
    }
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  Future<void> unlockEntry(LockedContentEntry entry) async {
    final storageKey = entry.isCategory
        ? 'parental_locked_categories_v2'
        : 'parental_locked_channels_v3';
    final values = _readSet(storageKey)..remove(entry.key);
    await _writeSet(storageKey, values);
    if (!entry.isCategory) await _removeChannelLabel(entry.key);
  }
}

class LockedContentEntry {
  final String key;
  final String name;
  final String subtitle;
  final bool isCategory;

  const LockedContentEntry({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.isCategory,
  });
}

bool _constantTimeEquals(String left, String right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var i = 0; i < left.length; i++) {
    difference |= left.codeUnitAt(i) ^ right.codeUnitAt(i);
  }
  return difference == 0;
}

String _pbkdf2Worker(Map<String, Object> input) {
  final pin = utf8.encode(input['pin']! as String);
  final salt = base64Url.decode(input['salt']! as String);
  final iterations = input['iterations']! as int;
  final hmac = Hmac(sha256, pin);
  final block = Uint8List(salt.length + 4)..setAll(0, salt);
  block[block.length - 1] = 1;
  var u = hmac.convert(block).bytes;
  final result = List<int>.from(u);
  for (var round = 1; round < iterations; round++) {
    u = hmac.convert(u).bytes;
    for (var i = 0; i < result.length; i++) {
      result[i] ^= u[i];
    }
  }
  return base64Url.encode(result);
}
