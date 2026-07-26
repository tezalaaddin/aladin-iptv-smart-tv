import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../../shared/widgets/aladin_channel_card.dart';
import '../../shared/widgets/aladin_channel_options.dart';
import '../player/aladin_player_page.dart';
import '../series/aladin_series_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  Map<String, double> _seriesProgress = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                if (_continueWatching.isNotEmpty)
                  _SliverHorizontalSection(
                    title: s.continueWatching,
                    items: _continueWatching,
                    seriesProgressMap: _seriesProgress,
                    onTap: _onTap,
                  ),
                if (_favorites.isNotEmpty)
                  _SliverHorizontalSection(
                    title: s.favorites,
                    items: _favorites,
                    seriesProgressMap: _seriesProgress,
                    onTap: _onTap,
                  ),
                if (_recentlyAdded.isNotEmpty)
                  _SliverHorizontalSection(
                    title: s.recentlyAdded,
                    items: _recentlyAdded,
                    seriesProgressMap: _seriesProgress,
                    onTap: _onTap,
                  ),
                if (_mostWatched.isNotEmpty)
                  _SliverHorizontalSection(
                    title: 'En Sık İzlenenler',
                    items: _mostWatched,
                    seriesProgressMap: _seriesProgress,
                    onTap: _onTap,
                  ),
                if (_movieShelf.isNotEmpty)
                  _SliverHorizontalSection(
                    title: s.navMovies,
                    items: _movieShelf,
                    seriesProgressMap: _seriesProgress,
                    onTap: _onTap,
                  ),
                if (_seriesShelf.isNotEmpty)
                  _SliverHorizontalSection(
                    title: s.navSeries,
                    items: _seriesShelf,
                    seriesProgressMap: _seriesProgress,
                    onTap: _onTap,
                  ),
                if (_discovery.isNotEmpty)
                  _SliverHorizontalSection(
                    title: s.discover,
                    items: _discovery,
                    seriesProgressMap: _seriesProgress,
                    onTap: _onTap,
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
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
                    onLongPress: () => showAladinChannelOptions(context, ch),
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
