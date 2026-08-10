import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_category_model.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../../shared/widgets/aladin_app_bar.dart';
import '../../shared/widgets/aladin_category_row.dart';
import '../../shared/widgets/aladin_channel_card.dart';
import '../../shared/widgets/aladin_empty_state.dart';
import '../../shared/widgets/aladin_category_menu.dart';
import '../../shared/widgets/aladin_section_header.dart';
import '../player/aladin_player_page.dart';
import '../content/aladin_catchup_page.dart';
import '../search/aladin_search_page.dart';

class LiveTvPage extends StatefulWidget {
  final VoidCallback? onGoToSettings;
  final void Function(CategoryModel)? onCategoryTap;
  final FocusNode? categoryFocusNode;

  const LiveTvPage(
      {super.key,
      this.onGoToSettings,
      this.onCategoryTap,
      this.categoryFocusNode});

  @override
  State<LiveTvPage> createState() => _LiveTvPageState();
}

class _LiveTvPageState extends State<LiveTvPage> {
  List<CategoryModel> _categories = [];
  List<ChannelModel> _favorites = [];
  bool _loading = false;
  int? _loadedId;
  int _reloadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<AppState>();
      s.addListener(_onState);
      if (s.active != null) _load(s.active!.id);
    });
  }

  @override
  void dispose() {
    try {
      context.read<AppState>().removeListener(_onState);
    } catch (_) {}
    super.dispose();
  }

  void _onState() {
    if (!mounted) return;
    final state = context.read<AppState>();
    final a = state.active;

    if (a == null) {
      if (_loadedId != null) {
        setState(() {
          _categories = [];
          _loadedId = null;
        });
      }
      return;
    }

    // Playlist değişmişse veya henüz yüklenmemişse yükle.
    // Fokus değişimleri gibi AppState bildirimlerinde tüm sayfayı yeniden yüklemeyi engeller.
    if (a.id != _loadedId) {
      _load(a.id);
    }
  }

  Future<void> _loadFavorites(int id) async {
    final allFavs = await ChannelService.instance.getFavorites(id);
    final tvFavs = allFavs.where((c) => c.contentType == 'tv').toList();
    if (!mounted) return;

    setState(() {
      _favorites = tvFavs;
    });
  }

  Future<void> _load(int id) async {
    if (!mounted) return;

    // Eğer zaten bu ID yüklenmişse ve sadece verileri tazelemek istiyorsak loader göstermeyebiliriz
    // Ama ilk defa yükleniyorsa loader gösteriyoruz.
    final bool isFirstLoad = _categories.isEmpty;

    setState(() {
      if (isFirstLoad) _loading = true;
      _loadedId = id;
      _reloadCount++;
    });

    final cats = await ChannelService.instance
        .getCategories(playlistId: id, contentType: 'tv');

    await _loadFavorites(id);

    if (!mounted) return;
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  void _play(ChannelModel ch, List<ChannelModel> list) async {
    if ((ch.catchupDays ?? 0) > 0) {
      _showCatchupDialog(ch, list);
    } else {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PlayerPage(
                  channel: ch, playlist: list.isNotEmpty ? list : [ch])));
      // Oyuncudan geri dönüldüğünde favoriler değişmiş olabilir, tazele.
      if (mounted && _loadedId != null) _loadFavorites(_loadedId!);
    }
  }

  void _showCatchupDialog(ChannelModel ch, List<ChannelModel> list) {
    final s = context.read<AppState>().s;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(ch.name, style: const TextStyle(color: Colors.white)),
        content: Text(s.v52('catchupPrompt'),
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PlayerPage(
                          channel: ch,
                          playlist: list.isNotEmpty ? list : [ch])));
              if (mounted && _loadedId != null) _loadFavorites(_loadedId!);
            },
            child: Text(s.v52('watchLive')),
          ),
          ElevatedButton(
            autofocus: true,
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AladinCatchupPage(channel: ch)));
            },
            child: Text(s.v52('browseCatchup')),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFav(ChannelModel ch) async {
    await ChannelService.instance.toggleFavorite(ch.id);
    // Sayfayı tamamen yenileyip scroll'u bozmak yerine sadece favori listesini güncelleyelim.
    if (_loadedId != null && mounted) {
      _loadFavorites(_loadedId!);
    }
  }

  void _openSearch() {
    final s = context.read<AppState>().s;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(
          isActive: true,
          contentType: 'tv',
          sectionTitle: s.navLiveTV,
        ),
      ),
    );
  }

  Future<void> _confirmRemoveFavorite(ChannelModel ch) async {
    final s = context.read<AppState>().s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.favorites, style: const TextStyle(color: Colors.white)),
        content: Text(s.removeFavoriteQ(ch.name),
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel)),
          TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.delete,
                  style: const TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (ok == true) _toggleFav(ch);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      if (state.active == null) {
        return AladinEmptyState(
          icon: Icons.live_tv,
          title: state.s.noPlaylistSelected,
          message: state.s.addPlaylistHint,
          buttonLabel: state.s.goToSettings,
          onAction: widget.onGoToSettings,
        );
      }

      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AladinAppBar(
          onSearch: _openSearch,
          onRefresh: () => _load(state.active!.id),
        ),
        body: RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => _load(state.active!.id),
          child: _loading && _categories.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accent))
              : _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 50, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            state.s.noPlaylistSelected,
                            style:
                                const TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: widget.onGoToSettings,
                            autofocus: true,
                            icon: const Icon(Icons.add),
                            label: Text(state.s.addPlaylist),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(54, 18, 54, 4),
                            child: AladinSectionHeader(
                              searchTooltip: state.s.navSearch,
                              refreshTooltip: state.s.retry,
                              onSearch: _openSearch,
                              onRefresh: () => _load(state.active!.id),
                              categoryButton: AladinCategoryMenuButton(
                                categories: _categories,
                                focusNode: widget.categoryFocusNode,
                                onSelected: (category) =>
                                    widget.onCategoryTap?.call(category),
                                onShowAll: () {},
                                onManageHidden: () =>
                                    showAladinHiddenContentManager(context),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              if (_favorites.isNotEmpty)
                                _HorizStrip(
                                  title: state.s.favorites,
                                  channels: _favorites,
                                  onTap: (ch) => _play(ch, _favorites),
                                  onLongPress: (ch) =>
                                      _confirmRemoveFavorite(ch),
                                ),
                            ]),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => CategoryRow(
                                key: ValueKey(
                                    '${_categories[i].id}_r$_reloadCount'),
                                category: _categories[i],
                                playlistId: state.active!.id,
                                onChannelTap: (ch, list) =>
                                    _play(ch, list), // Listeyi de gönderiyoruz
                                onCategoryTap: widget.onCategoryTap,
                                onFavorite: _toggleFav,
                                tvMode: true,
                                showEpg: true,
                              ),
                              childCount: _categories.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
                    ),
        ),
      );
    });
  }
}

class _HorizStrip extends StatelessWidget {
  final String title;
  final List<ChannelModel> channels;
  final void Function(ChannelModel) onTap;
  final void Function(ChannelModel)? onLongPress;

  const _HorizStrip({
    required this.title,
    required this.channels,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
            child: Text(title, style: AppTheme.headingMedium),
          ),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: channels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              clipBehavior: Clip.none,
              itemBuilder: (_, i) => ChannelCard(
                channel: channels[i],
                tvMode: true,
                width: 127.2,
                height: 71.4,
                onTap: () => onTap(channels[i]),
                onLongPress: onLongPress != null
                    ? () => onLongPress!(channels[i])
                    : null,
              ),
            ),
          ),
        ],
      );
}
