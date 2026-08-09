import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_epg_model.dart';
import '../../core/services/aladin_epg_engine.dart';
import '../../core/services/aladin_epg_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';

class AladinEpgGridPage extends StatefulWidget {
  final List<ChannelModel> channels;
  final ValueChanged<ChannelModel> onPlay;
  const AladinEpgGridPage(
      {super.key, required this.channels, required this.onPlay});

  @override
  State<AladinEpgGridPage> createState() => _AladinEpgGridPageState();
}

class _AladinEpgGridPageState extends State<AladinEpgGridPage> {
  static const _platform = MethodChannel('aladin/exoplayer');
  static const double _channelWidth = 250;
  static const double _rowHeight = 92;
  static const double _headerHeight = 44;
  static const double _pixelsPerMinute = 2;
  static const double _timelineWidth = 1440 * _pixelsPerMinute;
  int _dayOffset = 0;
  String _query = '';
  final ScrollController _horizontal = ScrollController();
  DateTime get _day => DateTime.now().add(Duration(days: _dayOffset));

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

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
            tooltip: s.v52('programSearch'),
            icon: const Icon(Icons.search),
            onPressed: () async {
              final controller = TextEditingController(text: _query);
              final value = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(s.v52('searchInEpg')),
                  content: TextField(controller: controller, autofocus: true),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, ''),
                        child: Text(s.v52('clear'))),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, controller.text),
                        child: Text(s.v52('search'))),
                  ],
                ),
              );
              if (value != null && mounted)
                setState(() => _query = value.trim());
            },
          ),
          IconButton(
              tooltip: s.v49('previousDay'),
              onPressed:
                  _dayOffset > -1 ? () => setState(() => _dayOffset--) : null,
              icon: const Icon(Icons.chevron_left)),
          Center(
              child: Semantics(
                  label: s.v50('selectedGuideDay'),
                  child: Text(DateFormat('dd MMM, EEEE').format(_day),
                      style: const TextStyle(fontWeight: FontWeight.bold)))),
          IconButton(
              tooltip: s.v49('nextDay'),
              onPressed:
                  _dayOffset < 2 ? () => setState(() => _dayOffset++) : null,
              icon: const Icon(Icons.chevron_right)),
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
          return SingleChildScrollView(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: _channelWidth,
                child: Column(children: [
                  const SizedBox(height: _headerHeight),
                  for (final channel in channels)
                    SizedBox(
                      height: _rowHeight,
                      child: ListTile(
                        onTap: () => widget.onPlay(channel),
                        leading:
                            const Icon(Icons.live_tv, color: AppTheme.accent),
                        title: Text(channel.name,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: (channel.catchupDays ?? 0) > 0
                            ? Text(s.v49('catchup'),
                                style:
                                    const TextStyle(color: Colors.greenAccent))
                            : null,
                      ),
                    ),
                ]),
              ),
              const VerticalDivider(width: 1, color: Colors.white12),
              Expanded(
                child: SingleChildScrollView(
                  controller: _horizontal,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: _timelineWidth,
                    child: Column(children: [
                      _TimeHeader(day: _day),
                      for (final channel in channels)
                        _TimelineRow(
                          channelName: channel.name,
                          day: _day,
                          programs: _programsFor(channel, grid)
                              .where((p) =>
                                  _query.isEmpty ||
                                  p.title
                                      .toLowerCase()
                                      .contains(_query.toLowerCase()))
                              .take(100)
                              .toList(growable: false),
                          noProgramText: s.v49('noProgram'),
                          onReminder: _scheduleReminder,
                        ),
                    ]),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Future<void> _scheduleReminder(
      String channelName, EpgProgramModel program) async {
    final s = context.read<AppState>().s;
    final trigger = program.startTime
        .subtract(const Duration(minutes: 5))
        .millisecondsSinceEpoch;
    if (trigger <= DateTime.now().millisecondsSinceEpoch) return;
    await _platform.invokeMethod('scheduleProgramReminder', {
      'title': program.title,
      'channel': channelName,
      'triggerAt': trigger,
      'id': Object.hash(channelName, program.startTime).abs() & 0x7fffffff,
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.v52('reminderSet'))));
    }
  }

  List<EpgProgramModel> _programsFor(
      ChannelModel channel, Map<String, List<EpgProgramModel>> grid) {
    final id = channel.tvgId?.trim().isNotEmpty == true
        ? channel.tvgId!
        : channel.name;
    return grid[AladinEpgEngine.normalizeId(id)] ??
        grid[AladinEpgEngine.normalizeId(channel.name)] ??
        const [];
  }
}

class _TimeHeader extends StatelessWidget {
  final DateTime day;
  const _TimeHeader({required this.day});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: _AladinEpgGridPageState._headerHeight,
        child: Stack(children: [
          for (var hour = 0; hour < 24; hour++)
            Positioned(
              left: hour * 60 * _AladinEpgGridPageState._pixelsPerMinute,
              width: 60 * _AladinEpgGridPageState._pixelsPerMinute,
              top: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 8, top: 12),
                decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.white24))),
                child: Text('${hour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(color: AppTheme.textMuted)),
              ),
            ),
        ]),
      );
}

class _TimelineRow extends StatelessWidget {
  final String channelName;
  final DateTime day;
  final List<EpgProgramModel> programs;
  final String noProgramText;
  final void Function(String, EpgProgramModel) onReminder;
  const _TimelineRow(
      {required this.channelName,
      required this.day,
      required this.programs,
      required this.noProgramText,
      required this.onReminder});

  @override
  Widget build(BuildContext context) {
    final start = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final showNow = now.year == start.year &&
        now.month == start.month &&
        now.day == start.day;
    return Container(
      height: _AladinEpgGridPageState._rowHeight,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Stack(children: [
        if (programs.isEmpty)
          Padding(
              padding: const EdgeInsets.all(20),
              child: Text(noProgramText,
                  style: const TextStyle(color: AppTheme.textMuted))),
        for (final p in programs) _program(p, start),
        if (showNow)
          Positioned(
            left: now.difference(start).inMinutes *
                _AladinEpgGridPageState._pixelsPerMinute,
            top: 0,
            bottom: 0,
            child: Container(width: 2, color: AppTheme.accent),
          ),
      ]),
    );
  }

  Widget _program(EpgProgramModel p, DateTime dayStart) {
    final startMinutes =
        p.startTime.difference(dayStart).inMinutes.clamp(0, 1440);
    final endMinutes = p.endTime.difference(dayStart).inMinutes.clamp(0, 1440);
    final width =
        ((endMinutes - startMinutes) * _AladinEpgGridPageState._pixelsPerMinute)
            .clamp(70.0, _AladinEpgGridPageState._timelineWidth);
    return Positioned(
      left: startMinutes * _AladinEpgGridPageState._pixelsPerMinute + 2,
      top: 8,
      width: width - 4,
      height: _AladinEpgGridPageState._rowHeight - 16,
      child: Semantics(
        label: '${p.title}, ${DateFormat('HH:mm').format(p.startTime)}',
        child: InkWell(
          onTap: () => onReminder(channelName, p),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: p.isNow
                  ? AppTheme.accent.withValues(alpha: 0.28)
                  : AppTheme.card,
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: p.isNow ? AppTheme.accent : Colors.white12),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat('HH:mm').format(p.startTime),
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              Text(p.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}
