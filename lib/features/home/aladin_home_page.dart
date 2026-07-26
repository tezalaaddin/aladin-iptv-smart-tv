import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../../shared/widgets/aladin_channel_card.dart';
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
    final disc = await ChannelService.instance.getRandomDiscovery(id, limit: 15);
    final prog = await ChannelService.instance.getSeriesProgressMap(id);
    
    favs.sort((a, b) => b.id.compareTo(a.id));
    final recentFavs = favs.take(15).toList();

    if (mounted) {
      setState(() {
        _continueWatching = cw;
        _favorites = recentFavs;
        _recentlyAdded = added;
        _discovery = disc;
        _seriesProgress = prog;
        _loading = false;
      });
    }
  }

  void _onTap(ChannelModel ch) {
    if (ch.contentType == 'series') {
      final name = ch.seriesName?.trim().isNotEmpty == true ? ch.seriesName! : ch.name;
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
      return const Center(child: Icon(Icons.home, size: 100, color: AppTheme.textMuted));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _loading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.active?.name.toUpperCase() ?? '',
                          style: const TextStyle(
                            color: AppTheme.accent, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'DASHBOARD',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 42, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: -1.5,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Navigation Row
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Row(
                      children: [
                        _QuickNavCard(
                          icon: Icons.live_tv, 
                          label: s.navLiveTV, 
                          color: Colors.redAccent, 
                          onTap: () => state.navigateToPage(1),
                        ),
                        _QuickNavCard(
                          icon: Icons.movie, 
                          label: s.navMovies, 
                          color: Colors.blueAccent, 
                          onTap: () => state.navigateToPage(2),
                        ),
                        _QuickNavCard(
                          icon: Icons.video_library, 
                          label: s.navSeries, 
                          color: Colors.orangeAccent, 
                          onTap: () => state.navigateToPage(3),
                        ),
                        _QuickNavCard(
                          icon: Icons.search, 
                          label: s.navSearch, 
                          color: Colors.tealAccent, 
                          onTap: () => state.navigateToPage(4),
                        ),
                      ],
                    ),
                  ),
                ),

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

class _QuickNavCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickNavCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  State<_QuickNavCard> createState() => _QuickNavCardState();
}

class _QuickNavCardState extends State<_QuickNavCard> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 170,
          height: 90,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _focused ? widget.color : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _focused ? Colors.white : Colors.white.withOpacity(0.05), width: 2.5),
            boxShadow: _focused ? [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: _focused ? Colors.white : widget.color, size: 32),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: _focused ? Colors.white : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
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
                final prog = seriesProgressMap?[ch.seriesName?.trim() ?? ch.name.trim()];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChannelCard(
                    channel: ch,
                    seriesProgress: prog,
                    onTap: () => onTap(ch),
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
