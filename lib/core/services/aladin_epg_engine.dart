import 'dart:async';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
import 'package:xml/xml.dart';
import 'aladin_epg_service.dart';
import '../database/aladin_isar_service.dart';
import '../models/aladin_channel_model.dart';
import '../models/aladin_epg_model.dart';
import '../state/aladin_app_prefs.dart';

/// AladinEpgEngine — Universal EPG sync + logo enrichment engine.
class AladinEpgEngine extends ChangeNotifier {
  AladinEpgEngine._();
  static final AladinEpgEngine instance = AladinEpgEngine._();

  static const _kTr1GzUrl =
      'https://epgshare01.online/epgshare01/epg_ripper_TR1.xml.gz';
  static const _kTr1TxtUrl =
      'https://epgshare01.online/epgshare01/epg_ripper_TR1.txt';
  static const _kTr3GzUrl =
      'https://epgshare01.online/epgshare01/epg_ripper_TR3.xml.gz';
  static const _kTr3TxtUrl =
      'https://epgshare01.online/epgshare01/epg_ripper_TR3.txt';
  static const _kFallbackUrl =
      'https://epgshare01.online/epgshare01/epg_ripper_ALL_SOURCES1.xml.gz';

  static const _kSyncKeyMs = 'epg_last_sync_ms';
  static const _kSyncStatus = 'epg_sync_status';

  bool _syncing = false;
  double _progress = 0;

  bool get isSyncing => _syncing;
  double get progress => _progress;

  String get syncStatus =>
      AladinPrefs.instance.getString(_kSyncStatus) ?? 'idle';

  int get daysSinceSync {
    final lastMs = AladinPrefs.instance.getInt(_kSyncKeyMs);
    if (lastMs == 0) return 999;
    return ((DateTime.now().millisecondsSinceEpoch - lastMs) /
            (1000 * 60 * 60 * 24))
        .floor();
  }

  bool get needsUpdate => daysSinceSync >= 6;

  Future<bool> forceSync() async {
    if (_syncing) return false;
    return _doSync();
  }

  static String normalizeId(String id) {
    var s = id.trim();
    s = s.replaceAll(RegExp(r'@\S+$'), '');
    s = s.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '');
    s = s.replaceAll(RegExp(r'^[A-Za-z]{1,6}\s*[|:]\s*'), '');
    s = s.replaceAll(RegExp(r'\.[a-zA-Z]{2,3}$'), '');
    const tr = {
      'İ': 'I',
      'ı': 'i',
      'Ş': 'S',
      'ş': 's',
      'Ğ': 'G',
      'ğ': 'g',
      'Ü': 'U',
      'ü': 'u',
      'Ö': 'O',
      'ö': 'o',
      'Ç': 'C',
      'ç': 'c'
    };
    for (final e in tr.entries) {
      s = s.replaceAll(e.key, e.value);
    }
    s = s.replaceAll(
        RegExp(
            r'\b(4K|UHD|FHD|1080[PpIi]|HD\+?|720[Pp]|SD|HEVC|H\.?265|H\.?264|AVC|MPEG2)\b',
            caseSensitive: false),
        '');
    s = s.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return s.toLowerCase();
  }

  Future<bool> _doSync() async {
    if (EpgService.instance.isPaused) return false;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return false;

    _syncing = true;
    _progress = 0.05;
    notifyListeners();
    await AladinPrefs.instance.setString(_kSyncStatus, 'syncing');

    var success = false;
    try {
      final db = IsarService.instance.db;
      final sharedBestPrograms = <String, _BestProgramCandidate>{};
      final syncSessionId = DateTime.now().millisecondsSinceEpoch;

      _progress = 0.1;
      notifyListeners();
      await _trySource(_kTr1GzUrl, sharedBestPrograms) ||
          await _trySource(_kTr1TxtUrl, sharedBestPrograms);

      _progress = 0.4;
      notifyListeners();
      await _trySource(_kTr3GzUrl, sharedBestPrograms) ||
          await _trySource(_kTr3TxtUrl, sharedBestPrograms);

      if (sharedBestPrograms.isEmpty) {
        _progress = 0.6;
        notifyListeners();
        await _trySource(_kFallbackUrl, sharedBestPrograms);
      }

      if (sharedBestPrograms.isNotEmpty) {
        // ⚡ PRO FEATURE: SWAP PATTERN
        // 1. Write new data with sessionId
        _progress = 0.8;
        notifyListeners();
        await _commitBestPrograms(sharedBestPrograms, syncSessionId);

        // 2. Only if everything succeeded, delete OLD data
        await db.writeTxn(() => db.epgProgramModels
            .filter()
            .not()
            .syncSessionEqualTo(syncSessionId)
            .deleteAll());
        await AladinPrefs.instance
            .setInt(_kSyncKeyMs, DateTime.now().millisecondsSinceEpoch);
        await AladinPrefs.instance.setString(_kSyncStatus, 'ok');
        _progress = 1.0;
        success = true;
      } else {
        await AladinPrefs.instance.setString(_kSyncStatus, 'error');
        throw StateError('EPG kaynakları kullanılabilir program döndürmedi.');
      }
    } catch (e) {
      debugPrint('[EPG] _doSync error: $e');
      await AladinPrefs.instance.setString(_kSyncStatus, 'error');
    } finally {
      _syncing = false;
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        _progress = 0;
        notifyListeners();
      });
    }
    return success;
  }

  Future<bool> _trySource(
      String url, Map<String, _BestProgramCandidate> sharedBestPrograms) async {
    try {
      final res = await http.get(Uri.parse(url), headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      }).timeout(const Duration(seconds: 90));

      if (res.statusCode != 200) return false;

      String xml;
      if (url.endsWith('.gz')) {
        try {
          xml = utf8.decode(GZipDecoder().decodeBytes(res.bodyBytes),
              allowMalformed: true);
        } catch (_) {
          xml = utf8.decode(res.bodyBytes, allowMalformed: true);
        }
      } else {
        xml = utf8.decode(res.bodyBytes, allowMalformed: true);
      }

      if (!xml.contains('<tv') && !xml.contains('<programme')) return false;

      final result = await compute(_parseXmlWorker, xml);

      // Merge results
      for (final candidate in result.programs) {
        final normCid = normalizeId(candidate.channelId);
        final dedupKey =
            '$normCid|${candidate.startTime.millisecondsSinceEpoch}';
        final existing = sharedBestPrograms[dedupKey];
        if (existing == null ||
            (!existing.hasDescription && candidate.hasDescription)) {
          sharedBestPrograms[dedupKey] = candidate;
        }
      }

      await _enrichChannelLogos(IsarService.instance.db, result.channels);

      return true;
    } catch (e) {
      debugPrint('[EPG] _trySource error: $e');
      return false;
    }
  }

  Future<void> _commitBestPrograms(
      Map<String, _BestProgramCandidate> bestPrograms, int sessionId) async {
    final db = IsarService.instance.db;
    final batch = <EpgProgramModel>[];
    int stored = 0;
    int total = bestPrograms.length;

    for (final candidate in bestPrograms.values) {
      batch.add(EpgProgramModel()
        ..channelId = candidate.channelId
        ..normalizedChannelId = normalizeId(candidate.channelId)
        ..title = candidate.title
        ..description = candidate.description
        ..category = candidate.category
        ..icon = candidate.icon
        ..startTime = candidate.startTime
        ..endTime = candidate.endTime
        ..syncSession = sessionId);
      stored++;

      if (batch.length >= 500) {
        final currentBatch = List<EpgProgramModel>.from(batch);
        await db.writeTxn(() => db.epgProgramModels.putAll(currentBatch));
        batch.clear();
        _progress = 0.8 + (stored / total) * 0.15;
        notifyListeners();
      }
    }
    if (batch.isNotEmpty) {
      await db.writeTxn(() => db.epgProgramModels.putAll(batch));
    }
  }

  Future<void> _enrichChannelLogos(
      Isar db, Map<String, _AladinXmlChannel> channelMeta) async {
    // 30k+ kanalı tek seferde çekmek OOM riskidir. 500'erli batch'lerle işle.
    int offset = 0;
    const batchSize = 500;
    bool hasMore = true;

    while (hasMore) {
      final channels = await db.channelModels
          .filter()
          .contentTypeEqualTo('tv')
          .offset(offset)
          .limit(batchSize)
          .findAll();

      if (channels.isEmpty) {
        hasMore = false;
        break;
      }

      final toUpdate = <ChannelModel>[];
      for (final ch in channels) {
        final keys = <String>[];
        if (ch.tvgId != null && ch.tvgId!.isNotEmpty)
          keys.add(normalizeId(ch.tvgId!));
        if (ch.name.isNotEmpty) keys.add(normalizeId(ch.name));
        if (ch.tvgName != null && ch.tvgName!.isNotEmpty)
          keys.add(normalizeId(ch.tvgName!));

        for (final key in keys) {
          final epgCh = channelMeta[key];
          final iconUrl = epgCh?.iconUrl;
          if (iconUrl == null || iconUrl.isEmpty) continue;

          bool changed = false;
          if (ch.epgLogoUrl != iconUrl) {
            ch.epgLogoUrl = iconUrl;
            changed = true;
          }
          if (ch.logoUrl == null || ch.logoUrl!.isEmpty) {
            ch.logoUrl = iconUrl;
            changed = true;
          }

          if (changed) {
            toUpdate.add(ch);
          }
          break;
        }
      }

      if (toUpdate.isNotEmpty) {
        await db.writeTxn(() => db.channelModels.putAll(toUpdate));
      }

      offset += batchSize;
      if (channels.length < batchSize) hasMore = false;
    }
  }
}

// ── Worker Functions (Must be top-level for compute) ────────────────────────

class _ParseResult {
  final Map<String, _AladinXmlChannel> channels;
  final List<_BestProgramCandidate> programs;
  _ParseResult(this.channels, this.programs);
}

_ParseResult _parseXmlWorker(String xml) {
  final doc = XmlDocument.parse(xml);
  final now = DateTime.now();
  final retentionEnd = now.add(const Duration(days: 7));

  final channels = <String, _AladinXmlChannel>{};
  for (final ch in doc.findAllElements('channel')) {
    final xmlId = ch.getAttribute('id') ?? '';
    if (xmlId.isEmpty) continue;
    final normKey = AladinEpgEngine.normalizeId(xmlId);
    channels[normKey] = _AladinXmlChannel(
      originalId: xmlId,
      displayName: ch.findElements('display-name').firstOrNull?.innerText ?? '',
      iconUrl: ch.findElements('icon').firstOrNull?.getAttribute('src'),
    );
  }

  final programs = <_BestProgramCandidate>[];
  for (final prog in doc.findAllElements('programme')) {
    try {
      final cid = prog.getAttribute('channel') ?? '';
      final start = _parseDateInternal(prog.getAttribute('start') ?? '');
      final stop = _parseDateInternal(prog.getAttribute('stop') ?? '');
      if (cid.isEmpty || start == null || stop == null) continue;
      if (stop.isBefore(now)) continue;
      if (start.isAfter(retentionEnd)) continue;

      final title = prog.findElements('title').firstOrNull?.innerText ?? '';
      if (title.isEmpty) continue;

      final description = prog.findElements('desc').firstOrNull?.innerText;

      programs.add(_BestProgramCandidate(
        channelId: cid,
        title: title,
        description: description,
        category: prog.findElements('category').firstOrNull?.innerText,
        icon: prog.findElements('icon').firstOrNull?.getAttribute('src'),
        startTime: start,
        endTime: stop,
        hasDescription: description != null && description.isNotEmpty,
      ));
    } catch (_) {}
  }

  return _ParseResult(channels, programs);
}

DateTime? _parseDateInternal(String raw) {
  try {
    final parts = raw.trim().split(RegExp(r'\s+'));
    final clean = parts[0];
    if (clean.length < 14) return null;
    final dt = DateTime.utc(
      int.parse(clean.substring(0, 4)),
      int.parse(clean.substring(4, 6)),
      int.parse(clean.substring(6, 8)),
      int.parse(clean.substring(8, 10)),
      int.parse(clean.substring(10, 12)),
      int.parse(clean.substring(12, 14)),
    );
    if (parts.length > 1) {
      final tz = parts[1];
      if (tz.length == 5) {
        final sign = tz[0] == '-' ? 1 : -1;
        final h = int.tryParse(tz.substring(1, 3)) ?? 0;
        final m = int.tryParse(tz.substring(3, 5)) ?? 0;
        return dt.add(Duration(hours: sign * h, minutes: sign * m));
      }
    }
    return dt;
  } catch (_) {
    return null;
  }
}

class _AladinXmlChannel {
  final String originalId;
  final String displayName;
  final String? iconUrl;
  const _AladinXmlChannel(
      {required this.originalId, required this.displayName, this.iconUrl});
}

class _BestProgramCandidate {
  final String channelId;
  final String title;
  final String? description;
  final String? category;
  final String? icon;
  final DateTime startTime;
  final DateTime endTime;
  final bool hasDescription;
  const _BestProgramCandidate({
    required this.channelId,
    required this.title,
    this.description,
    this.category,
    this.icon,
    required this.startTime,
    required this.endTime,
    required this.hasDescription,
  });
}
