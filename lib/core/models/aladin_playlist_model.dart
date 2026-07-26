import 'package:isar_community/isar.dart';

part 'aladin_playlist_model.g.dart';

@collection
class PlaylistModel {
  Id id = Isar.autoIncrement;

  /// Unique identifier — used for duplicate detection
  @Index(unique: true, replace: true)
  late String url;

  late String name;
  late String type; // 'm3u' | 'xtream' | 'local'

  int totalCount = 0;
  int tvCount = 0;
  int movieCount = 0;
  int seriesCount = 0;

  // Xtream fields
  String? xtreamServer;
  String? xtreamUsername;
  // REMOVED: Plaintext password. Use flutter_secure_storage.
  // String? xtreamPassword;

  late DateTime createdAt;
  late DateTime lastUpdated;

  bool isActive = false;
}
