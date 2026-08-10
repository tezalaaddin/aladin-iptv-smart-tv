import 'package:isar_community/isar.dart';
import '../database/aladin_isar_service.dart';
import '../models/aladin_epg_model.dart';
import 'aladin_epg_engine.dart';
import '../utils/aladin_async_limiter.dart';

class EpgNowNext {
  const EpgNowNext(this.now, this.next);
  final EpgProgramModel? now;
  final EpgProgramModel? next;
}

class _TimedEpgValue {
  const _TimedEpgValue(this.value, this.createdAt);
  final EpgNowNext value;
  final DateTime createdAt;
}

/// EpgService — query layer only. Sync is handled by [AladinEpgEngine].
class EpgService {
  EpgService._();
  static final EpgService instance = EpgService._();

  Isar get _db => IsarService.instance.db;

  bool _isPaused = false;
  final AladinAsyncLimiter _cardQueryLimiter = AladinAsyncLimiter(2);
  final Map<String, _TimedEpgValue> _nowNextCache = {};
  final Map<String, Future<EpgNowNext>> _pendingNowNext = {};
  bool get isPaused => _isPaused;
  void pauseQueries() => _isPaused = true;
  void resumeQueries() => _isPaused = false;

  Future<EpgNowNext> getNowAndNext(String channelId, {String? cleanName}) {
    final key =
        '${AladinEpgEngine.normalizeId(channelId)}|${AladinEpgEngine.normalizeId(cleanName ?? '')}';
    final cached = _nowNextCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.createdAt) <
            const Duration(minutes: 1)) {
      return Future.value(cached.value);
    }
    final pending = _pendingNowNext[key];
    if (pending != null) return pending;

    final future = _cardQueryLimiter.run(() async {
      final now = await getNowPlaying(channelId, cleanName: cleanName);
      final upcoming =
          await getUpcoming(channelId, cleanName: cleanName, limit: 1);
      final value = EpgNowNext(now, upcoming.isEmpty ? null : upcoming.first);
      _nowNextCache[key] = _TimedEpgValue(value, DateTime.now());
      if (_nowNextCache.length > 300) {
        _nowNextCache.remove(_nowNextCache.keys.first);
      }
      return value;
    });
    _pendingNowNext[key] = future;
    return future.whenComplete(() => _pendingNowNext.remove(key));
  }

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

  /// Loads a complete day window once and groups it for an EPG grid. This
  /// replaces one Isar query per visible channel on low-memory televisions.
  Future<Map<String, List<EpgProgramModel>>> getDayGrid(DateTime day) async {
    if (_isPaused) return {};
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final programs = await _db.epgProgramModels
        .filter()
        .startTimeLessThan(end)
        .and()
        .endTimeGreaterThan(start)
        .sortByStartTime()
        .findAll();
    final grouped = <String, List<EpgProgramModel>>{};
    for (final program in programs) {
      grouped.putIfAbsent(program.normalizedChannelId, () => []).add(program);
      final raw = AladinEpgEngine.normalizeId(program.channelId);
      if (raw != program.normalizedChannelId) {
        grouped.putIfAbsent(raw, () => []).add(program);
      }
    }
    return grouped;
  }
}
