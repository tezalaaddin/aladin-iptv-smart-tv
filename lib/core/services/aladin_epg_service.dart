import 'package:isar_community/isar.dart';
import '../database/aladin_isar_service.dart';
import '../models/aladin_epg_model.dart';
import 'aladin_epg_engine.dart';

/// EpgService — query layer only. Sync is handled by [AladinEpgEngine].
class EpgService {
  EpgService._();
  static final EpgService instance = EpgService._();

  Isar get _db => IsarService.instance.db;

  bool _isPaused = false;
  bool get isPaused => _isPaused;
  void pauseQueries() => _isPaused = true;
  void resumeQueries() => _isPaused = false;

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Returns the programme currently on air for a channel.
  Future<EpgProgramModel?> getNowPlaying(
    String channelId, {
    String? cleanName,
    String? channelName,
  }) async {
    if (_isPaused) return null;

    final normId = AladinEpgEngine.normalizeId(channelId);
    final now = DateTime.now();

    // Strategy 1: Search by exact channelId (tvg-id)
    var program = await _db.epgProgramModels
        .filter()
        .channelIdEqualTo(channelId)
        .and()
        .startTimeLessThan(now)
        .and()
        .endTimeGreaterThan(now)
        .findFirst();

    if (program != null) return program;

    // Strategy 2: Search by normalized channelId
    program = await _db.epgProgramModels
        .filter()
        .normalizedChannelIdEqualTo(normId)
        .and()
        .startTimeLessThan(now)
        .and()
        .endTimeGreaterThan(now)
        .findFirst();

    if (program != null) return program;

    // Strategy 3: Search by normalized clean name
    final effectiveClean = cleanName ?? channelName;
    if (effectiveClean != null) {
      final normName = AladinEpgEngine.normalizeId(effectiveClean);
      if (normName != normId) {
        program = await _db.epgProgramModels
            .filter()
            .normalizedChannelIdEqualTo(normName)
            .and()
            .startTimeLessThan(now)
            .and()
            .endTimeGreaterThan(now)
            .findFirst();
      }
    }

    return program;
  }

  /// Returns upcoming programmes for a channel, sorted by start time.
  Future<List<EpgProgramModel>> getUpcoming(
    String channelId, {
    String? cleanName,
    String? channelName,
    int limit = 8,
  }) async {
    if (_isPaused) return [];

    final normId = AladinEpgEngine.normalizeId(channelId);
    final now = DateTime.now();

    // Try finding by normalizedId first as it's the most common match
    var results = await _db.epgProgramModels
        .filter()
        .group((q) => q
            .channelIdEqualTo(channelId)
            .or()
            .normalizedChannelIdEqualTo(normId))
        .and()
        .startTimeGreaterThan(now)
        .sortByStartTime()
        .limit(limit)
        .findAll();

    if (results.isNotEmpty) return results;

    // Fallback to name-based normalized match
    final effectiveClean = cleanName ?? channelName;
    if (effectiveClean != null) {
      final normName = AladinEpgEngine.normalizeId(effectiveClean);
      if (normName != normId) {
        results = await _db.epgProgramModels
            .filter()
            .normalizedChannelIdEqualTo(normName)
            .and()
            .startTimeGreaterThan(now)
            .sortByStartTime()
            .limit(limit)
            .findAll();
      }
    }

    return results;
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<int> totalProgrammes() => _db.epgProgramModels.count();

  /// Returns all programmes for a channel, sorted by start time.
  Future<List<EpgProgramModel>> getPrograms(String channelId,
      {String? cleanName}) async {
    final normId = AladinEpgEngine.normalizeId(channelId);

    // Search by both channelId and normalizedId
    var results = await _db.epgProgramModels
        .filter()
        .group((q) => q
            .channelIdEqualTo(channelId)
            .or()
            .normalizedChannelIdEqualTo(normId))
        .sortByStartTime()
        .findAll();

    if (results.isEmpty && cleanName != null) {
      final normName = AladinEpgEngine.normalizeId(cleanName);
      results = await _db.epgProgramModels
          .filter()
          .normalizedChannelIdEqualTo(normName)
          .sortByStartTime()
          .findAll();
    }

    return results;
  }
}
