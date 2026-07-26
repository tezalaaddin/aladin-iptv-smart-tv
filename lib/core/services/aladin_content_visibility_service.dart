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

  String categoryKey(CategoryModel category) =>
      '${category.playlistId}:${category.contentType}:${category.name.trim().toLowerCase()}';
  String channelKey(ChannelModel channel) =>
      ParentalService.instance.channelKey(channel);

  bool isCategoryVisible(CategoryModel category) =>
      !_set('hidden_categories_v49').contains(categoryKey(category));
  bool isChannelVisible(ChannelModel channel) =>
      !_set('hidden_channels_v49').contains(channelKey(channel));

  Future<void> hideCategory(CategoryModel category) async {
    final values = _set('hidden_categories_v49')..add(categoryKey(category));
    await _save('hidden_categories_v49', values);
  }

  Future<void> hideChannel(ChannelModel channel) async {
    final values = _set('hidden_channels_v49')..add(channelKey(channel));
    await _save('hidden_channels_v49', values);
  }

  int get hiddenCount =>
      _set('hidden_categories_v49').length + _set('hidden_channels_v49').length;

  Future<void> showAll() async {
    await _save('hidden_categories_v49', {});
    await _save('hidden_channels_v49', {});
  }
}
