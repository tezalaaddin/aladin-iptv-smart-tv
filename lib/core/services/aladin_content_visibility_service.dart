import 'dart:convert';

import '../models/aladin_category_model.dart';
import '../models/aladin_channel_model.dart';
import '../state/aladin_app_prefs.dart';
import 'aladin_parental_service.dart';

class ContentVisibilityService {
  ContentVisibilityService._();
  static final instance = ContentVisibilityService._();

  Set<String> _set(String key) {
    try {
      return (jsonDecode(AladinPrefs.instance.getString(key) ?? '[]') as List)
          .map((e) => '$e')
          .toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _save(String key, Set<String> values) =>
      AladinPrefs.instance.setString(key, jsonEncode(values.toList()..sort()));

  Map<String, String> _labels() {
    try {
      return Map<String, String>.from(jsonDecode(
          AladinPrefs.instance.getString('hidden_labels_v50') ?? '{}'));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveLabels(Map<String, String> labels) =>
      AladinPrefs.instance.setString('hidden_labels_v50', jsonEncode(labels));

  String categoryKey(CategoryModel category) =>
      '${category.playlistId}:${category.contentType}:${category.name.trim().toLowerCase()}';
  String channelKey(ChannelModel channel) =>
      ParentalService.instance.channelKey(channel);

  bool isCategoryVisible(CategoryModel category) =>
      !_set('hidden_categories_v49').contains(categoryKey(category));
  bool isChannelVisible(ChannelModel channel) =>
      !_set('hidden_channels_v49').contains(channelKey(channel));

  Future<void> hideCategory(CategoryModel category) async {
    final key = categoryKey(category);
    final values = _set('hidden_categories_v49')..add(key);
    await _save('hidden_categories_v49', values);
    await _saveLabels(_labels()..[key] = category.name);
  }

  Future<void> hideChannel(ChannelModel channel) async {
    final key = channelKey(channel);
    final values = _set('hidden_channels_v49')..add(key);
    await _save('hidden_channels_v49', values);
    await _saveLabels(_labels()..[key] = channel.name);
  }

  List<HiddenContentEntry> get hiddenEntries {
    final labels = _labels();
    return [
      ..._set('hidden_categories_v49').map((key) => HiddenContentEntry(
          key: key,
          name: labels[key] ?? key.split(':').last,
          isCategory: true)),
      ..._set('hidden_channels_v49').map((key) => HiddenContentEntry(
          key: key,
          name: labels[key] ?? 'Eski gizli kanal',
          isCategory: false)),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> show(HiddenContentEntry entry) async {
    final prefKey =
        entry.isCategory ? 'hidden_categories_v49' : 'hidden_channels_v49';
    await _save(prefKey, _set(prefKey)..remove(entry.key));
    final labels = _labels()..remove(entry.key);
    await _saveLabels(labels);
  }

  int get hiddenCount =>
      _set('hidden_categories_v49').length + _set('hidden_channels_v49').length;

  Future<void> showAll() async {
    await _save('hidden_categories_v49', {});
    await _save('hidden_channels_v49', {});
    await _saveLabels({});
  }
}

class HiddenContentEntry {
  final String key;
  final String name;
  final bool isCategory;
  const HiddenContentEntry(
      {required this.key, required this.name, required this.isCategory});
}
