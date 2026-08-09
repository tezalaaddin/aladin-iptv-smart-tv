import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../core/state/aladin_app_prefs.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../../shared/widgets/aladin_channel_card.dart';
import '../../shared/widgets/aladin_channel_options.dart';
import '../player/aladin_player_page.dart';
import '../series/aladin_series_page.dart';
import '../help/aladin_help_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.helpFocusNode});

  final FocusNode? helpFocusNode;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChannelModel> _continueWatching = [];
  List<ChannelModel> _favorites = [];
  List<ChannelModel> _recentlyAdded = [];
  List<ChannelModel> _discovery = [];
  List<ChannelModel> _movieShelf = [];
  List<ChannelModel> _seriesShelf = [];
  List<ChannelModel> _mostWatched = [];
  List<ChannelModel> _completed = [];
  List<ChannelModel> _history = [];
  Map<String, double> _seriesProgress = {};
  bool _loading = true;
  static const _defaultShelves = [
    'continue',
    'favorites',
    'recent',
    'most',
    'completed',
    'history',
    'movies',
    'series',
    'discover'
  ];
  late List<String> _shelfOrder;
  final Set<String> _hiddenShelves = {};

  @override
  void initState() {
    super.initState();
    _loadShelfPrefs();
    _loadData();
  }

  void _loadShelfPrefs() {
    try {
      final saved = (jsonDecode(
              AladinPrefs.instance.getString('dashboard_shelf_order_v50') ??
                  '[]') as List)
          .map((e) => '$e')
          .where(_defaultShelves.contains)
          .toList();
      _shelfOrder = [
        ...saved,
        ..._defaultShelves.where((e) => !saved.contains(e))
      ];
      _hiddenShelves.addAll((jsonDecode(
              AladinPrefs.instance.getString('dashboard_hidden_shelves_v50') ??
                  '[]') as List)
          .map((e) => '$e'));
    } catch (_) {
      _shelfOrder = List.of(_defaultShelves);
    }
  }

  Future<void> _saveShelfPrefs() async {
    await AladinPrefs.instance
        .setString('dashboard_shelf_order_v50', jsonEncode(_shelfOrder));
    await AladinPrefs.instance.setString(
        'dashboard_hidden_shelves_v50', jsonEncode(_hiddenShelves.toList()));
  }

  Future<void> _customizeShelves() async {
    final s = context.read<AppState>().s;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, update) {
        String label(String key) => switch (key) {
              'continue' => s.continueWatching,
              'favorites' => s.favorites,
              'recent' => s.recentlyAdded,
              'most' => s.v50('mostWatched'),
              'completed' => 'Tamamlananlar',
              'history' => 'Son izlenen kanallar',
              'movies' => s.navMovies,
              'series' => s.navSeries,
              _ => s.discover,
            };
        return AlertDialog(
          backgroundColor: AppTheme.card,
          title: Text(s.v50('customizeDashboard')),
          content: SizedBox(
            width: 620,
            height: 430,
            child: ListView.builder(
              itemCount: _shelfOrder.length,
              itemBuilder: (context, index) {
                final key = _shelfOrder[index];
                return SwitchListTile(
                  autofocus: index == 0,
                  value: !_hiddenShelves.contains(key),
                  onChanged: (value) => update(() => value
                      ? _hiddenShelves.remove(key)
                      : _hiddenShelves.add(key)),
                  title: Text(label(key)),
                  secondary: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        onPressed: index > 0
                            ? () => update(() {
                                  final item = _shelfOrder.removeAt(index);
                                  _shelfOrder.insert(index - 1, item);
                                })
                            : null,
                        icon: const Icon(Icons.arrow_upward)),
                    IconButton(
                        onPressed: index < _shelfOrder.length - 1
                            ? () => update(() {
                                  final item = _shelfOrder.removeAt(index);
                                  _shelfOrder.insert(index + 1, item);
                                })
                            : null,
                        icon: const Icon(Icons.arrow_downward)),
                  ]),
                );
              },
            ),
          ),
          actions: [
            FilledButton(
                autofocus: true,
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(s.save))
          ],
        );
      }),
    );
    await _saveShelfPrefs();
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final state = context.read<AppState>();
    if (state.active == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final id = state.active!.id;
    final cw = await ChannelService.instance.getContinueWatching(id, limit: 15);
    final favs = await ChannelService.instance.getFavorites(id);
    final added = await ChannelService.instance.getRecentlyAdded(id, limit: 15);
    final disc =
        await ChannelService.instance.getRandomDiscovery(id, limit: 15);
    final movies =
        await ChannelService.instance.getHomeShelf(id, 'movie', limit: 15);
    final series =
        await ChannelService.instance.getHomeShelf(id, 'series', limit: 15);
    final prog = await ChannelService.instance.getSeriesProgressMap(id);
    final mostWatched =
        await ChannelService.instance.getMostWatched(id, limit: 15);
    final completed = await ChannelService.instance.getCompleted(id, limit: 15);
    final history = await ChannelService.instance.getChannelHistory(id);

    favs.sort((a, b) => b.id.compareTo(a.id));
    final recentFavs = favs.take(15).toList();

    if (mounted) {
      setState(() {
        _continueWatching = cw;
        _favorites = recentFavs;
        _recentlyAdded = _fillShelf(added, [movies, series, disc], 15);
        _discovery = disc;
        _movieShelf = movies;
        _seriesShelf = series;
        _seriesProgress = prog;
        _mostWatched = mostWatched;
        _completed = completed;
        _history = history;
        _loading = false;
      });
    }
  }

  List<ChannelModel> _fillShelf(List<ChannelModel> primary,
      List<List<ChannelModel>> fallbacks, int limit) {
    final result = <ChannelModel>[];
    final seen = <int>{};
    for (final source in [primary, ...fallbacks]) {
      for (final item in source) {
        if (seen.add(item.id)) result.add(item);
        if (result.length >= limit) return result;
      }
    }
    return result;
  }

  void _onTap(ChannelModel ch) {
    if (ch.contentType == 'series') {
      final name =
          ch.seriesName?.trim().isNotEmpty == true ? ch.seriesName! : ch.name;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AladinSeriesDetailPage(
            seriesName: name,
            playlistId: ch.playlistId,
            seriesId: ch.parentSeriesId ?? ch.tvgId,
            playlistModel: context.read<AppState>().active,
          ),
        ),
      ).then((_) => _loadData());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerPage(
            channel: ch,
            playlist: [ch],
          ),
        ),
      ).then((_) => _loadData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;

    if (state.active == null) {
      return const Center(
          child: Icon(Icons.home, size: 100, color: AppTheme.textMuted));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 32, 0),
                    child: FocusTraversalGroup(
                      policy: OrderedTraversalPolicy(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HomeActionButton(
                            focusNode: widget.helpFocusNode,
                            order: 1,
                            icon: Icons.question_mark_rounded,
                            tooltip:
                                AladinHelpCatalog.labels(state.lang)['title']!,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AladinHelpPage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _HomeActionButton(
                            order: 2,
                            icon: Icons.tune,
                            tooltip: s.v50('customizeDashboard'),
                            onPressed: _customizeShelves,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
                ..._shelfOrder.expand((key) => _shelfFor(key, s)),
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
    );
  }

  Iterable<Widget> _shelfFor(String key, dynamic s) {
    if (_hiddenShelves.contains(key)) return const [];
    final (String, List<ChannelModel>) data = switch (key) {
      'continue' => (s.continueWatching, _continueWatching),
      'favorites' => (s.favorites, _favorites),
      'recent' => (s.recentlyAdded, _recentlyAdded),
      'most' => (s.v50('mostWatched'), _mostWatched),
      'completed' => ('Tamamlananlar', _completed),
      'history' => ('Son izlenen kanallar', _history),
      'movies' => (s.navMovies, _movieShelf),
      'series' => (s.navSeries, _seriesShelf),
      _ => (s.discover, _discovery),
    };
    if (data.$2.isEmpty) return const [];
    return [
      _SliverHorizontalSection(
        title: data.$1,
        items: data.$2,
        seriesProgressMap: _seriesProgress,
        onTap: _onTap,
      )
    ];
  }
}

class _HomeActionButton extends StatefulWidget {
  const _HomeActionButton({
    required this.order,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.focusNode,
  });

  final double order;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  @override
  State<_HomeActionButton> createState() => _HomeActionButtonState();
}

class _HomeActionButtonState extends State<_HomeActionButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(widget.order),
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: Focus(
          focusNode: widget.focusNode,
          onFocusChange: (value) => setState(() => _focused = value),
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.select ||
                    event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
              widget.onPressed();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _focused ? AppTheme.accent : AppTheme.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _focused ? Colors.white : Colors.white24,
                  width: _focused ? 2.5 : 1,
                ),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(.32),
                          blurRadius: 18,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                size: 26,
                color: _focused ? Colors.black : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverHorizontalSection extends StatelessWidget {
  final String title;
  final List<ChannelModel> items;
  final Function(ChannelModel) onTap;
  final Map<String, double>? seriesProgressMap;

  const _SliverHorizontalSection({
    required this.title,
    required this.items,
    required this.onTap,
    this.seriesProgressMap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(
            height: AppTheme.listHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              clipBehavior: Clip.none,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final ch = items[index];
                final prog =
                    seriesProgressMap?[ch.seriesName?.trim() ?? ch.name.trim()];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChannelCard(
                    channel: ch,
                    seriesProgress: prog,
                    onTap: () => onTap(ch),
                    onLongPress: () async {
                      final changed =
                          await showAladinChannelOptions(context, ch);
                      if (changed && context.mounted) {
                        final state =
                            context.findAncestorStateOfType<_HomePageState>();
                        await state?._loadData();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
