import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../../shared/widgets/aladin_app_bar.dart';
import '../../shared/widgets/aladin_channel_card.dart';
import '../../shared/widgets/aladin_empty_state.dart';
import '../player/aladin_player_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ChannelModel> _allFavs = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initLoad();
  }

  void _initLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<AppState>();
      s.addListener(_onStateChange);
      if (s.active != null) _load(s.active!.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    try { context.read<AppState>().removeListener(_onStateChange); } catch (_) {}
    super.dispose();
  }

  void _onStateChange() {
    final a = context.read<AppState>().active;
    if (a != null && mounted) _load(a.id);
  }

  Future<void> _load(int id) async {
    if (!mounted) return;
    setState(() => _loading = true);
    final rawFavs = await ChannelService.instance.getFavorites(id);
    if (!mounted) return;
    setState(() {
      _allFavs = rawFavs;
      _loading = false;
    });
  }

  Future<void> _toggleFav(ChannelModel ch) async {
    await ChannelService.instance.toggleFavorite(ch.id);
    if (context.read<AppState>().active != null) {
      _load(context.read<AppState>().active!.id);
    }
  }

  void _showRemoveConfirm(ChannelModel ch) {
    final s = context.read<AppState>().s;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.favorites, style: const TextStyle(color: Colors.white)),
        content: Text(s.removeFavoriteQ(ch.name), style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _toggleFav(ch);
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  void _play(ChannelModel ch, List<ChannelModel> currentList) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          channel: ch, 
          playlist: currentList, 
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AladinAppBar(
        title: s.navFavorites,
        onRefresh: state.active != null ? () => _load(state.active!.id) : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppTheme.accent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMuted,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                _TVTab(label: s.all),
                _TVTab(label: s.liveTv),
                _TVTab(label: s.movies),
                _TVTab(label: s.series),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : FocusScope(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Kumanda ile grid içinde gezerken tab kaymasını engelle
                children: [
                  _buildGrid(_allFavs), 
                  _buildGrid(_allFavs.where((e) => e.contentType == 'tv').toList()), 
                  _buildGrid(_allFavs.where((e) => e.contentType == 'movie').toList()), 
                  _buildGrid(_allFavs.where((e) => e.contentType == 'series').toList()), 
                ],
              ),
            ),
    );
  }

  Widget _buildGrid(List<ChannelModel> list) {
    if (list.isEmpty) return _buildEmptyState(context.read<AppState>().s);
    
    final double safePadding = MediaQuery.of(context).size.width * 0.04;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: safePadding, vertical: 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppTheme.cardWidth + 20,
        mainAxisSpacing: 25,
        crossAxisSpacing: 15,
        mainAxisExtent: AppTheme.gridHeight,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final ch = list[index];
        return Center(
          child: ChannelCard(
            channel: ch,
            margin: EdgeInsets.zero,
            onTap: () => _play(ch, list),
            onLongPress: () => _showRemoveConfirm(ch),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(dynamic s) {
    return AladinEmptyState(
      icon: Icons.favorite_border_rounded,
      title: s.noFavorites,
      message: 'Kanal kartlarına uzun basarak veya oynatıcı içinden 0 tuşuna basarak favorilerinizi ekleyebilirsiniz.',
      buttonLabel: s.navHome,
      onAction: () => context.read<AppState>().navigateToPage(0),
    );
  }
}

class _TVTab extends StatefulWidget {
  final String label;
  const _TVTab({required this.label});

  @override
  State<_TVTab> createState() => _TVTabState();
}

class _TVTabState extends State<_TVTab> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: Tab(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _focused ? Colors.white10 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _focused ? AppTheme.accent : Colors.transparent),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
