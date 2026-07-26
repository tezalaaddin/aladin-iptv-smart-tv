import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_playlist_model.dart';
import '../../core/state/aladin_app_state.dart';
import '../series/aladin_series_page.dart';
import '../../core/state/aladin_app_prefs.dart';
import '../../core/services/aladin_metadata_sync_service.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/services/aladin_parental_service.dart';
import '../../shared/widgets/aladin_parental_gate.dart';

class PlayerPage extends StatefulWidget {
  final ChannelModel channel;
  final List<ChannelModel> playlist; // Tüm kanal listesi
  final PlaylistModel? playlistModel; // Xtream yönlendirmesi için

  const PlayerPage({
    super.key,
    required this.channel,
    required this.playlist,
    this.playlistModel,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static const MethodChannel _exoChannel = MethodChannel('aladin/exoplayer');

  @override
  void initState() {
    super.initState();
    // ⚡ PERFORMANS: Oynatıcı açılırken arka plan senkronizasyonunu durdur
    MetadataSyncService.instance.stopSync();
    _launch();
  }

  Future<void> _launch() async {
    final allowed = await requestParentalUnlock(
      context,
      protectedContent: ParentalService.instance.requiresUnlock(widget.channel),
      title: widget.channel.name,
    );
    if (!allowed) {
      if (mounted) Navigator.pop(context);
      return;
    }
    // ── GUARD: Xtream dizisinde url boş olabilir (ana seri kaydı).
    // Bu durumda native player yerine dizi detay sayfasına yönlendir.
    if (widget.channel.url.trim().isEmpty) {
      if (!mounted) return;
      // initState'ten Navigator kullanmak için bir frame bekle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AladinSeriesDetailPage(
              playlistId: widget.channel.playlistId,
              seriesName: widget.channel.seriesName ?? widget.channel.name,
              seriesId: widget.channel.tvgId,
              playlistModel: widget.playlistModel,
            ),
          ),
        );
      });
      return;
    }
    await _launchNativePlayer();
  }

  Future<void> _launchNativePlayer() async {
    try {
      final state = context.read<AppState>();
      final s = state.s;

      // Playlist'teki boş URL'leri filtrele — native player'a sadece oynatılabilir içerik gönder
      // Keep the Android Intent safely below Binder's transaction limit.
      final allPlayable = widget.playlist
          .where((e) => e.url.trim().isNotEmpty)
          .where(ParentalService.instance.canExpose)
          .toList(growable: false);
      if (allPlayable.isEmpty) return;
      final selectedIndex = allPlayable.indexOf(widget.channel);
      final safeIndex = selectedIndex >= 0 ? selectedIndex : 0;
      const radius = 50;
      final start = math.max(0, safeIndex - radius);
      final end = math.min(allPlayable.length, safeIndex + radius + 1);
      final playable = allPlayable.sublist(start, end);
      final filteredIndex = safeIndex - start;

      final urls = playable.map((e) => e.url).toList();
      final names = playable.map((e) => e.name).toList();
      final descriptions = playable.map((e) => e.tmdbOverview ?? '').toList();
      final posters = playable.map((e) => e.tmdbPoster ?? '').toList();
      final ratings = playable.map((e) => e.imdbRating ?? '').toList();
      final years = playable.map((e) => e.tmdbYear ?? '').toList();
      final types = playable.map((e) => e.contentType).toList();
      final favs = playable.map((e) => e.isFavorite).toList();
      final positions = playable.map((e) => e.watchedSeconds).toList();
      final headers = playable.map((e) => e.streamHeaders ?? '').toList();

      final channelScope = '${widget.channel.playlistId}_${widget.channel.id}';
      final preferredQuality =
          AladinPrefs.instance.getString('channel_quality_$channelScope') ??
              AladinPrefs.instance.getString('preferredQuality');
      final decoderMode =
          AladinPrefs.instance.getString('channel_decoder_$channelScope') ??
              AladinPrefs.instance.getString('decoderMode') ??
              'auto';
      final videoLimit = switch (preferredQuality) {
        '4k' => 2160,
        'fhd' => 1080,
        'hd' => 720,
        'sd' => 480,
        _ => 0, // Auto
      };

      // ⚡ PRO FEATURE: Add to system-level Watch Next
      if (widget.channel.contentType != 'tv') {
        ChannelService.instance.addToWatchNext(widget.channel);
      }

      await _exoChannel.invokeMethod('playNative', {
        'urls': urls,
        'names': names,
        'descriptions': descriptions,
        'posters': posters,
        'ratings': ratings,
        'years': years,
        'types': types,
        'favs': favs,
        'positions': positions,
        'headers': headers,
        'index': filteredIndex >= 0 ? filteredIndex : 0,
        'decoderMode': decoderMode,
        'videoLimit': videoLimit,
        // Localization
        'i18n': {
          'subtitles': s.subtitles,
          'audio': s.audio,
          'quality': s.quality,
          'aspect': s.screenRatio,
          'added': s.addedToFav,
          'removed': s.removedFromFav,
          'off': s.off,
          'favorites_short': s.favoritesShort,
          'guide_channel': s.guideChannel,
          'guide_seek': s.guideSeek,
          'guide_volume': s.guideVolume,
          'aspect_fit': s.aspectFit,
          'aspect_fill': s.aspectFill,
          'aspect_zoom': s.aspectZoom,
          'loading': s.loading,
          'checking_connection': s.checkingConnection,
          'error': s.streamError,
          'retry_ok': s.retryWithOk,
          'attempt': s.attempt,
          'error_detailed': s.streamErrorDetailed,
          'sleep_timer': s.sleepTimer,
          'no_network': s.noNetwork,
          'playback_error': s.playbackError,
          'decoder_suggestion': s.decoderSuggestion,
          'software_low_memory': s.softwareLowMemory,
          'go_to_settings': s.goToSettings,
        }
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Native Player Hatası: $e");
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // url boşsa yönlendirme devam ediyor; yükleniyor göstergesi göster
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
    );
  }
}
