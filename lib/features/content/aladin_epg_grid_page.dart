import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_epg_model.dart';
import '../../core/services/aladin_epg_service.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Elektronik Program Rehberi'),
        actions: [
          IconButton(
            tooltip: 'Önceki gün',
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
            tooltip: 'Sonraki gün',
            onPressed:
                _dayOffset < 2 ? () => setState(() => _dayOffset++) : null,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: ListView.builder(
        itemCount: channels.length,
        itemExtent: 92,
        itemBuilder: (context, index) => _EpgChannelRow(
          key: ValueKey('${channels[index].id}:$_dayOffset'),
          channel: channels[index],
          day: _day,
          onPlay: () => widget.onPlay(channels[index]),
        ),
      ),
    );
  }
}

class _EpgChannelRow extends StatelessWidget {
  final ChannelModel channel;
  final DateTime day;
  final VoidCallback onPlay;

  const _EpgChannelRow({
    super.key,
    required this.channel,
    required this.day,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final id = channel.tvgId?.trim().isNotEmpty == true
        ? channel.tvgId!
        : channel.name;
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
                ? const Text('Arşiv',
                    style: TextStyle(color: Colors.greenAccent))
                : null,
          ),
        ),
        const VerticalDivider(width: 1, color: Colors.white12),
        Expanded(
          child: FutureBuilder<List<EpgProgramModel>>(
            future:
                EpgService.instance.getPrograms(id, cleanName: channel.name),
            builder: (context, snapshot) {
              final programs = (snapshot.data ?? const <EpgProgramModel>[])
                  .where((p) =>
                      p.endTime.isAfter(start) && p.startTime.isBefore(end))
                  .toList();
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator(minHeight: 2);
              }
              if (programs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Program bilgisi yok',
                      style: TextStyle(color: AppTheme.textMuted)),
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
