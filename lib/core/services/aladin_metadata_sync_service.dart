import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import '../database/aladin_isar_service.dart';
import '../models/aladin_channel_model.dart';
import 'aladin_tmdb_service.dart';
import 'aladin_channel_service.dart';

class MetadataSyncService extends ChangeNotifier {
  MetadataSyncService._();
  static final MetadataSyncService instance = MetadataSyncService._();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  double _progress = 0;
  double get progress => _progress;

  int _syncedCount = 0;
  int _totalToSync = 0;

  Isar get _db => IsarService.instance.db;

  /// Starts the sync process for a playlist.
  /// Optimized to process only first 500 missing items to avoid OOM.
  Future<void> startSync(int playlistId, {String lang = 'tr'}) async {
    if (_isSyncing) return;

    // Find items with missing metadata - Limit to 500 items per batch
    final missingItems = await _db.channelModels
        .filter()
        .playlistIdEqualTo(playlistId)
        .and()
        .group((q) =>
            q.contentTypeEqualTo('movie').or().contentTypeEqualTo('series'))
        .and()
        .group((q) => q
            .imdbRatingIsNull()
            .or()
            .imdbRatingEqualTo('0')
            .or()
            .tmdbPosterIsNull())
        .limit(500)
        .findAll();

    if (missingItems.isEmpty) return;

    _isSyncing = true;
    _progress = 0;
    _syncedCount = 0;
    _totalToSync = missingItems.length;
    notifyListeners();

    _syncQueue(missingItems, lang: lang);
  }

  int _consecutiveFailures = 0;

  Future<void> _syncQueue(List<ChannelModel> items,
      {String lang = 'tr'}) async {
    for (int i = 0; i < items.length; i++) {
      if (!_isSyncing) break;

      final channel = items[i];

      try {
        Map<String, dynamic>? meta;
        if (channel.contentType == 'movie') {
          meta = await TmdbService.instance.searchMovie(
            channel.name,
            year: channel.tmdbYear,
            lang: lang,
          );
        } else if (channel.contentType == 'series') {
          final sName = channel.seriesName ?? channel.name;
          meta = await TmdbService.instance.searchSeries(
            sName,
            year: channel.tmdbYear,
            lang: lang,
          );
        }

        if (meta != null && _isSyncing) {
          _consecutiveFailures = 0;
          await ChannelService.instance.saveTmdbMeta(
            channelId: channel.id,
            tmdbId: meta['tmdbId'],
            imdbRating: meta['imdbRating'],
            poster: meta['poster'],
            overview: meta['overview'],
            year: meta['year'],
            applyToAllEpisodes: true,
          );
        } else {
          // Could be a rate limit or not found
          _consecutiveFailures++;
        }
      } catch (e) {
        debugPrint('[MetadataSync] Error: $e');
        _consecutiveFailures++;
      }

      _syncedCount++;
      _progress = _syncedCount / _totalToSync;

      if (_syncedCount % 5 == 0 || _syncedCount == _totalToSync) {
        notifyListeners();
      }

      // ⚡ PRO RATE LIMITING & BACKOFF
      int delay = 1000;
      if (_consecutiveFailures > 3) {
        delay = 5000; // Backoff if many items are failing/missing
      }
      if (_consecutiveFailures > 10) {
        debugPrint('[MetadataSync] Too many failures, stopping batch.');
        break;
      }

      await Future.delayed(Duration(milliseconds: delay));
    }

    _isSyncing = false;
    _progress = 0.0;
    notifyListeners();
  }

  void stopSync() {
    _isSyncing = false;
    notifyListeners();
  }
}
