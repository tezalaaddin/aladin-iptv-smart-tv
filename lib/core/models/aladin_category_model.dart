import 'package:isar_community/isar.dart';

part 'aladin_category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('playlistId')])
  late String name;

  @Index()
  late int playlistId;

  /// 'tv' | 'movie' | 'series'
  late String contentType;

  int channelCount = 0;
  int sortOrder = 0;
}
