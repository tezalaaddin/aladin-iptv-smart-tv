import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_epg_model.dart';
import '../../core/services/aladin_epg_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../player/aladin_player_page.dart';

class AladinCatchupPage extends StatefulWidget {
  final ChannelModel channel;
  const AladinCatchupPage({super.key, required this.channel});

  @override
  State<AladinCatchupPage> createState() => _AladinCatchupPageState();
}

class _AladinCatchupPageState extends State<AladinCatchupPage> {
  List<EpgProgramModel> _programs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = (widget.channel.tvgId?.isNotEmpty == true)
        ? widget.channel.tvgId!
        : widget.channel.name;
    final list = await EpgService.instance
        .getPrograms(id, cleanName: widget.channel.name);

    // Sadece geçmiş programları (catchupDays kadar geriye) ve şu anki yayını filtrele
    final now = DateTime.now();
    final limit = now.subtract(Duration(days: widget.channel.catchupDays ?? 7));

    final filtered = list
        .where((p) => p.endTime.isAfter(limit) && p.startTime.isBefore(now))
        .toList();
    filtered
        .sort((a, b) => b.startTime.compareTo(a.startTime)); // En yeni en üstte

    if (mounted) {
      setState(() {
        _programs = filtered;
        _loading = false;
      });
    }
  }

  void _playCatchup(EpgProgramModel p) {
    // Timeshift URL formatı genellikle: url?timeshift=YYYY-MM-DD-HH-MM veya ?utc=timestamp
    // Xtream için genellikle: /live/user/pass/stream_id.ts?timeshift=YYYY-MM-DD-HH-MM
    // M3U için sağlayıcıya göre değişir. Varsayılan olarak Xtream formatını kullanalım.

    final startTimeStr = DateFormat('yyyy-MM-dd-HH-mm').format(p.startTime);
    String catchupUrl = widget.channel.url;
    if (catchupUrl.contains('?')) {
      catchupUrl += '&timeshift=$startTimeStr';
    } else {
      catchupUrl += '?timeshift=$startTimeStr';
    }

    final catchupChannel = ChannelModel()
      ..id = widget.channel.id
      ..playlistId = widget.channel.playlistId
      ..name = '${widget.channel.name} - ${p.title}'
      ..url = catchupUrl
      ..logoUrl = widget.channel.logoUrl
      ..categoryName = widget.channel.categoryName
      ..contentType = 'movie'; // Player treat as VOD for seeking

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          channel: catchupChannel,
          playlist: [catchupChannel],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // Sol Taraf: Kanal Bilgisi
          Container(
            width: 350,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.channel.logoUrl != null)
                  Image.network(widget.channel.logoUrl!,
                      height: 100,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.live_tv, size: 100)),
                const SizedBox(height: 24),
                Text(widget.channel.name, style: AppTheme.headingLarge),
                const SizedBox(height: 8),
                Text(
                    s
                        .v52('catchupDays')
                        .replaceAll('{days}', '${widget.channel.catchupDays}'),
                    style: const TextStyle(color: AppTheme.accent)),
                const Spacer(),
                Text(s.v52('catchupInstruction'),
                    style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),
          // Sağ Taraf: Program Listesi
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _programs.isEmpty
                    ? Center(child: Text(s.v52('noCatchup')))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _programs.length,
                        itemBuilder: (context, i) {
                          final p = _programs[i];
                          final timeStr =
                              '${DateFormat('HH:mm').format(p.startTime)} - ${DateFormat('HH:mm').format(p.endTime)}';
                          final dateStr =
                              DateFormat('dd MMM').format(p.startTime);

                          return _CatchupItem(
                            title: p.title,
                            subtitle: p.description ?? '',
                            time: timeStr,
                            date: dateStr,
                            onTap: () => _playCatchup(p),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _CatchupItem extends StatefulWidget {
  final String title, subtitle, time, date;
  final VoidCallback onTap;
  const _CatchupItem(
      {required this.title,
      required this.subtitle,
      required this.time,
      required this.date,
      required this.onTap});

  @override
  State<_CatchupItem> createState() => _CatchupItemState();
}

class _CatchupItemState extends State<_CatchupItem> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _focused ? Colors.white : AppTheme.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(widget.date,
                      style: TextStyle(
                          color: _focused ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold)),
                  Text(widget.time,
                      style: TextStyle(
                          color: _focused ? Colors.black54 : Colors.white38,
                          fontSize: 12)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: TextStyle(
                            color: _focused ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    if (widget.subtitle.isNotEmpty)
                      Text(widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: _focused ? Colors.black54 : Colors.white38,
                              fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill,
                  color: _focused ? AppTheme.accent : Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
