import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_epg_model.dart';
import '../../core/services/aladin_epg_service.dart';
import '../../core/services/aladin_epg_engine.dart';
import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';

class AladinEpgGridPage extends StatefulWidget {
  final List<ChannelModel> channels;
  final ValueChanged<ChannelModel> onPlay;

  const AladinEpgGridPage({
    super.key,
    required this.channels,
    required this.onPlay,
  });

  @override
  State<AladinEpgGridPage> createState() => _AladinEpgGridPageState();
}

class _AladinEpgGridPageState extends State<AladinEpgGridPage> {
  int _dayOffset = 0;
  DateTime get _day => DateTime.now().add(Duration(days: _dayOffset));

  @override
  Widget build(BuildContext context) {
    final channels = widget.channels.take(150).toList(growable: false);
    final s = context.watch<AppState>().s;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(s.v49('epgGuide')),
        actions: [
          IconButton(
            tooltip: s.v49('previousDay'),
            onPressed:
                _dayOffset > -1 ? () => setState(() => _dayOffset--) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Center(
            child: Semantics(
              label: 'Seçili rehber günü',
              child: Text(DateFormat('dd MMM, EEEE').format(_day),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            tooltip: s.v49('nextDay'),
            onPressed:
                _dayOffset < 2 ? () => setState(() => _dayOffset++) : null,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: FutureBuilder<Map<String, List<EpgProgramModel>>>(
        future: EpgService.instance.getDayGrid(_day),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final grid = snapshot.data!;
          return ListView.builder(
            itemCount: channels.length,
            itemExtent: 92,
            itemBuilder: (context, index) {
              final channel = channels[index];
              final id = channel.tvgId?.trim().isNotEmpty == true
                  ? channel.tvgId!
                  : channel.name;
              final normalized = AladinEpgEngine.normalizeId(id);
              final byName = AladinEpgEngine.normalizeId(channel.name);
              return _EpgChannelRow(
                key: ValueKey('${channel.id}:$_dayOffset'),
                channel: channel,
                programs: grid[normalized] ?? grid[byName] ?? const [],
                noProgramText: s.v49('noProgram'),
                catchupText: s.v49('catchup'),
                onPlay: () => widget.onPlay(channel),
              );
            },
          );
        },
      ),
    );
  }
}

class _EpgChannelRow extends StatelessWidget {
  final ChannelModel channel;
  final List<EpgProgramModel> programs;
  final VoidCallback onPlay;
  final String noProgramText;
  final String catchupText;

  const _EpgChannelRow({
    super.key,
    required this.channel,
    required this.programs,
    required this.onPlay,
    required this.noProgramText,
    required this.catchupText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: ListTile(
            autofocus: false,
            onTap: onPlay,
            leading: const Icon(Icons.live_tv, color: AppTheme.accent),
            title: Text(channel.name,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: (channel.catchupDays ?? 0) > 0
                ? Text(catchupText,
                    style: const TextStyle(color: Colors.greenAccent))
                : null,
          ),
        ),
        const VerticalDivider(width: 1, color: Colors.white12),
        Expanded(
          child: Builder(
            builder: (context) {
              if (programs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(noProgramText,
                      style: const TextStyle(color: AppTheme.textMuted)),
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                itemCount: programs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final p = programs[i];
                  return Semantics(
                    button: true,
                    label:
                        '${p.title}, ${DateFormat('HH:mm').format(p.startTime)}',
                    child: Container(
                      width: (p.durationMinutes.clamp(20, 120) * 3.0)
                          .clamp(150, 360),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: p.isNow
                            ? AppTheme.accent.withValues(alpha: 0.25)
                            : AppTheme.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: p.isNow ? AppTheme.accent : Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${DateFormat('HH:mm').format(p.startTime)}–${DateFormat('HH:mm').format(p.endTime)}',
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11)),
                          Text(p.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
