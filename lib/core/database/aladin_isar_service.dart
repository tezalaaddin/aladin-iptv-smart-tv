import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/aladin_playlist_model.dart';
import '../models/aladin_category_model.dart';
import '../models/aladin_channel_model.dart';
import '../models/aladin_epg_model.dart';

class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  Isar? _isar;

  Isar get db {
    if (_isar == null) {
      throw StateError('IsarService not initialized. Call init() first.');
    }
    return _isar!;
  }

  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        PlaylistModelSchema,
        CategoryModelSchema,
        ChannelModelSchema,
        EpgProgramModelSchema,
      ],
      directory: dir.path,
      name: 'iptv_db',
    );
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
