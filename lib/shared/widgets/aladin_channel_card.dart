import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_epg_model.dart';
import '../../core/services/aladin_epg_service.dart';
import '../../core/services/aladin_tmdb_service.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../theme/aladin_app_theme.dart';
import 'aladin_manual_logos.dart';

class ChannelCard extends StatefulWidget {
  final ChannelModel channel;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback?
      onLongPress; // Yeni: Uzun basma (Kaldır/Favoriden Çıkar için)
  final double width;
  final double height;
  final bool showEpg;
  final bool tvMode;
  final double? seriesProgress;
  final EdgeInsets? margin;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    this.onFavoriteTap,
    this.onLongPress,
    this.width = AppTheme.cardWidth,
    this.height = AppTheme.cardHeight,
    this.showEpg = false,
    this.tvMode = false,
    this.seriesProgress,
    this.margin,
  });

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _focused = false;
  DateTime? _selectPressedAt;
  EpgProgramModel? _nowPlaying;
  EpgProgramModel? _nextPlaying;
  bool _epgLoaded = false;
  Timer? _fetchTimer;

  static const _kHeaders = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  };

  @override
  void initState() {
    super.initState();
    if (widget.showEpg && widget.channel.contentType == 'tv') _loadEpg();
    _checkMetadata();
  }

  void _checkMetadata() {
    final ch = widget.channel;
    // Sadece film ve diziler için, eğer poster yoksa fetch planla
    if (ch.contentType != 'tv' &&
        (ch.tmdbPoster == null || ch.tmdbPoster!.isEmpty)) {
      // 1.5 saniye bekle; eğer kullanıcı hızlıca kaydırıp geçerse fetch yapma
      _fetchTimer = Timer(const Duration(milliseconds: 1500), _fetchMetadata);
    }
  }

  Future<void> _fetchMetadata() async {
    if (!mounted) return;
    final ch = widget.channel;
    try {
      Map<String, dynamic>? meta;
      if (ch.contentType == 'movie') {
        meta =
            await TmdbService.instance.searchMovie(ch.name, year: ch.tmdbYear);
      } else if (ch.contentType == 'series') {
        final sName =
            ch.seriesName?.trim().isNotEmpty == true ? ch.seriesName! : ch.name;
        meta =
            await TmdbService.instance.searchSeries(sName, year: ch.tmdbYear);
      }

      if (meta != null && mounted) {
        await ChannelService.instance.saveTmdbMeta(
          channelId: ch.id,
          tmdbId: meta['tmdbId'],
          imdbRating: meta['imdbRating'],
          poster: meta['poster'],
          overview: meta['overview'],
          year: meta['year'],
          applyToAllEpisodes: ch.contentType == 'series',
        );
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('[ChannelCard] Fetch Meta Error: $e');
    }
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEpg() async {
    final ch = widget.channel;
    final id = (ch.tvgId?.isNotEmpty == true) ? ch.tvgId! : ch.name;
    try {
      final now =
          await EpgService.instance.getNowPlaying(id, cleanName: ch.name);
      final upcoming = await EpgService.instance
          .getUpcoming(id, cleanName: ch.name, limit: 1);
      if (mounted)
        setState(() {
          _nowPlaying = now;
          _nextPlaying = upcoming.isEmpty ? null : upcoming.first;
          _epgLoaded = true;
        });
    } catch (_) {
      if (mounted) setState(() => _epgLoaded = true);
    }
  }

  String get _displayRating {
    final r = double.tryParse(widget.channel.imdbRating ?? '0') ?? 0.0;
    return r > 0 ? r.toStringAsFixed(1) : '';
  }

  bool get _hasCatchup => (widget.channel.catchupDays ?? 0) > 0;

  String get _cleanName {
    final name = (widget.channel.contentType == 'series' &&
            widget.channel.seriesName?.isNotEmpty == true)
        ? widget.channel.seriesName!
        : widget.channel.name;
    return name.replaceFirst(RegExp(r'^\d+[\.\-\)\s]+'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = _focused;
    final rating = _displayRating;
    final year = widget.channel.tmdbYear;
    final cleanName = _cleanName;

    final bool isTv = widget.channel.contentType == 'tv';
    final bool compactTv = isTv && widget.width <= 140;

    final double progress = widget.seriesProgress ??
        (widget.channel.totalDurationSeconds > 0
            ? (widget.channel.watchedSeconds /
                    widget.channel.totalDurationSeconds)
                .clamp(0.01, 1.0)
            : 0.0);

    return RepaintBoundary(
      child: Focus(
        onFocusChange: (v) {
          setState(() => _focused = v);
          if (v) {
            context.read<AppState>().setFocusedChannel(widget.channel);
            // Kart odaklandığında ekranın ortasına veya görünür alana gelmesini sağlar
            Scrollable.ensureVisible(
              context,
              alignment:
                  0.5, // 0.5 değeri kartı ekranın dikey/yatay ortasına getirir
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        onKeyEvent: (node, event) {
          final isSelect = event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA;
          if (!isSelect) return KeyEventResult.ignored;

          if (event is KeyDownEvent) {
            _selectPressedAt ??= DateTime.now();
            return KeyEventResult.handled;
          }
          if (event is KeyRepeatEvent) return KeyEventResult.handled;
          if (event is KeyUpEvent) {
            final pressedAt = _selectPressedAt;
            _selectPressedAt = null;
            final held = pressedAt == null
                ? Duration.zero
                : DateTime.now().difference(pressedAt);
            if (held >= const Duration(milliseconds: 650) &&
                widget.onLongPress != null) {
              widget.onLongPress!();
            } else {
              widget.onTap();
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.handled;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress, // Uzun basma desteği eklendi
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 200), // Odaklanma animasyon süresi
            curve: Curves.easeInOut,
            width: widget.width, // AppTheme.cardWidth
            height: widget.height, // AppTheme.cardHeight
            margin: widget.margin ??
                const EdgeInsets.only(right: 12), // Kartlar arası boşluk
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()
              ..scaleByDouble(isSelected ? 1.08 : 1.0, isSelected ? 1.08 : 1.0,
                  1.0, 1.0), // Odaklanınca %8 büyüme
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Kart köşe yuvarlaması
              border: Border.all(
                color: isSelected
                    ? AppTheme.accent
                    : Colors.transparent, // Odak çerçevesi
                width: 3.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 7 : 10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildContent(), // Afiş veya Logo

                  // Alt karartma gradyanı
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // IMDb Rozeti
                  if (rating.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _Badge(
                          text: rating,
                          label: 'IMDb',
                          color: const Color(0xFFF5C518),
                          textColor: Colors.black),
                    ),

                  // Yıl Rozeti
                  if (year != null && year.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _Badge(
                          text: year,
                          color: Colors.black54,
                          textColor: Colors.white,
                          isYear: true),
                    ),

                  // Catchup Rozeti
                  if (_hasCatchup)
                    Positioned(
                      bottom: isTv ? 34 : 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.blueAccent, shape: BoxShape.circle),
                        child: const Icon(Icons.history,
                            color: Colors.white, size: 12),
                      ),
                    ),

                  // İsim ve EPG Bilgisi Alanı
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: compactTv ? 38 : (isTv ? 72 : 85),
                    child: Container(
                      padding: EdgeInsets.all(compactTv ? 4 : 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NameBar(
                            displayName: cleanName,
                            channel: widget.channel,
                            nowPlaying: _epgLoaded ? _nowPlaying : null,
                            nextPlaying: _epgLoaded ? _nextPlaying : null,
                            compact: compactTv,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // İzleme İlerleme Çubuğu (VOD / Dizi)
                  if (progress > 0 && widget.channel.contentType != 'tv')
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 4,
                        alignment: Alignment.centerLeft,
                        color: Colors.white10,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                boxShadow: [
                                  BoxShadow(
                                      color: AppTheme.accent, blurRadius: 4)
                                ]),
                          ),
                        ),
                      ),
                    ),

                  // EPG İlerleme Çubuğu (Sadece TV için)
                  if (isTv && _nowPlaying != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _EpgProgressBar(program: _nowPlaying!),
                    ),

                  // ⚡ OPTIMISTIC FAVORITE INDICATOR (MADDE 18)
                  if (widget.channel.isFavorite)
                    const Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(Icons.favorite,
                          color: AppTheme.accent, size: 16),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final ch = widget.channel;
    final isTv = ch.contentType == 'tv' || widget.tvMode;
    final fit = isTv ? BoxFit.contain : BoxFit.cover;

    final String? playlistUrl = (ch.logoUrl != null && ch.logoUrl!.isNotEmpty)
        ? ch.logoUrl!.split('|').first.trim()
        : null;
    final String? githubUrl =
        isTv ? AladinManualLogos.urlFor(ch.name, ch.tvgId) : null;
    final String? vodUrl = isTv ? null : ch.tmdbPoster;

    final color = _getChannelColor(ch.name);

    Widget? imageWidget;
    if (playlistUrl != null && playlistUrl.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: playlistUrl,
        httpHeaders: _kHeaders,
        fit: fit,
        // ⚡ PERFORMANS: memCacheWidth/Height ile RAM kullanımını 4x azalt
        memCacheWidth: isTv ? 212 : 140,
        memCacheHeight: isTv ? 119 : 200,
        placeholder: (_, __) => _placeholder(color),
        errorWidget: (_, __, ___) {
          if (vodUrl != null && vodUrl.isNotEmpty)
            return _img(vodUrl, BoxFit.cover);
          if (githubUrl != null) return _img(githubUrl, fit);
          return _placeholder(color);
        },
      );
    } else if (vodUrl != null && vodUrl.isNotEmpty) {
      imageWidget = _img(vodUrl, BoxFit.cover);
    } else if (githubUrl != null) {
      imageWidget = _img(githubUrl, fit);
    }

    if (imageWidget != null) {
      if (isTv) {
        final compact = widget.width <= 140;
        return Container(
            color: AppTheme.card,
            padding: compact
                ? const EdgeInsets.fromLTRB(10, 4, 10, 18)
                : const EdgeInsets.fromLTRB(25, 10, 25, 25),
            child: Center(child: imageWidget));
      }
      return imageWidget;
    }
    return _placeholder(color);
  }

  Widget _img(String url, BoxFit fit) => CachedNetworkImage(
        imageUrl: url,
        httpHeaders: _kHeaders,
        fit: fit,
        memCacheWidth: 200,
        memCacheHeight: 300,
        placeholder: (_, __) =>
            _placeholder(_getChannelColor(widget.channel.name)),
        errorWidget: (_, __, ___) =>
            _placeholder(_getChannelColor(widget.channel.name)),
      );

  Color _getChannelColor(String name) {
    const palette = [
      Color(0xFF378ADD),
      Color(0xFF1D9E75),
      Color(0xFFD85A30),
      Color(0xFFD4537E),
      Color(0xFF7F77DD),
      Color(0xFFBA7517)
    ];
    if (name.isEmpty) return palette[0];
    final h = name.codeUnits.fold(0, (a, c) => (a * 31 + c) & 0x7fffffff);
    return palette[h % palette.length];
  }

  Widget _placeholder(Color color) {
    final ch = widget.channel;
    final seriesInfo = (ch.contentType == 'series' && ch.season != null)
        ? 'S${ch.season} E${ch.episode ?? '?'}'
        : '';
    return Container(
      color: AppTheme.card,
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _cleanName,
              textAlign: TextAlign.center,
              maxLines: 4, // 4 Satır
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            if (seriesInfo.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(seriesInfo,
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
            ],
          ],
        ),
      ),
    );
  }
}

class _NameBar extends StatelessWidget {
  final String displayName;
  final ChannelModel channel;
  final EpgProgramModel? nowPlaying;
  final EpgProgramModel? nextPlaying;
  final bool compact;
  const _NameBar(
      {required this.displayName,
      required this.channel,
      this.nowPlaying,
      this.nextPlaying,
      this.compact = false});

  @override
  Widget build(BuildContext context) {
    final strings = context.read<AppState>().s;
    final hasEpg = nowPlaying != null;
    final seriesInfo =
        (channel.contentType == 'series' && channel.season != null)
            ? 'S${channel.season} E${channel.episode ?? '?'}'
            : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          channel.contentType == 'tv'
              ? '#${channel.sortOrder + 1}  $displayName'
              : displayName,
          style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 9 : 13,
              fontWeight: FontWeight.bold,
              height: 1.1),
          maxLines: hasEpg ? 1 : 4,
          overflow: TextOverflow.ellipsis,
        ),
        if (seriesInfo.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(seriesInfo,
              style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w900)),
        ],
        if (hasEpg) ...[
          SizedBox(height: compact ? 1 : 2),
          Text(
            '${strings.v52('currentProgram')}: ${nowPlaying!.title}',
            style: TextStyle(
                color: AppTheme.accent,
                fontSize: compact ? 8 : 11,
                fontWeight: FontWeight.bold),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (nextPlaying != null && !compact)
          Text(
            '${strings.v52('nextProgram')}: ${nextPlaying!.title}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final String? label;
  final Color color;
  final Color textColor;
  final bool isYear;
  const _Badge(
      {required this.text,
      this.label,
      required this.color,
      required this.textColor,
      this.isYear = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(label!,
                  style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      color: textColor)),
              const SizedBox(width: 3)
            ],
            Text(text,
                style: TextStyle(
                    fontSize: isYear ? 8 : 9,
                    fontWeight: FontWeight.w900,
                    color: textColor)),
          ],
        ),
      );
}

class _EpgProgressBar extends StatefulWidget {
  final EpgProgramModel program;
  const _EpgProgressBar({required this.program});

  @override
  State<_EpgProgressBar> createState() => _EpgProgressBarState();
}

class _EpgProgressBarState extends State<_EpgProgressBar> {
  late Timer _timer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _update());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    final now = DateTime.now();
    final total =
        widget.program.endTime.difference(widget.program.startTime).inSeconds;
    final elapsed = now.difference(widget.program.startTime).inSeconds;
    if (total > 0) {
      setState(() => _progress = (elapsed / total).clamp(0.0, 1.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      width: double.infinity,
      color: Colors.white10,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: _progress,
        child: Container(color: AppTheme.accent),
      ),
    );
  }
}
