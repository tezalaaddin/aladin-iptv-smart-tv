import 'dart:convert';

import '../models/aladin_channel_model.dart';
import '../state/aladin_app_prefs.dart';

class FavoriteCollectionService {
  FavoriteCollectionService._();
  static final instance = FavoriteCollectionService._();
  static const _key = 'favorite_collections_v1';

  Map<String, List<int>> get collections {
    try {
      final raw = jsonDecode(AladinPrefs.instance.getString(_key) ?? '{}')
          as Map<String, dynamic>;
      return raw.map((name, ids) => MapEntry(
          name, (ids as List).map((id) => (id as num).toInt()).toList()));
    } catch (_) {
      return {};
    }
  }

  Future<void> add(String name, ChannelModel channel) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final data = collections;
    final ids = data.putIfAbsent(clean, () => <int>[]);
    if (!ids.contains(channel.id)) ids.add(channel.id);
    await _save(data);
  }

  Future<void> remove(String name, int channelId) async {
    final data = collections;
    data[name]?.remove(channelId);
    await _save(data);
  }

  Future<void> delete(String name) async {
    final data = collections..remove(name);
    await _save(data);
  }

  Future<void> _save(Map<String, List<int>> data) =>
      AladinPrefs.instance.setString(_key, jsonEncode(data));
}
