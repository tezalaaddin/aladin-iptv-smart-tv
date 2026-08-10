import '../../core/models/aladin_category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_playlist_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/services/aladin_playlist_service.dart';
import '../../core/services/aladin_tmdb_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../core/parsers/aladin_xtream_parser.dart';
import '../../core/utils/aladin_episode_deduplicator.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../../shared/widgets/aladin_app_bar.dart';
import '../../shared/widgets/aladin_category_row.dart';
import '../../shared/widgets/aladin_channel_card.dart';
import '../../shared/widgets/aladin_empty_state.dart';
import '../../shared/widgets/aladin_category_menu.dart';
import '../../shared/widgets/aladin_section_header.dart';
import '../player/aladin_player_page.dart';
import '../search/aladin_search_page.dart';

class AladinSeriesDetailPage extends StatefulWidget {
  final String seriesName;
  final int playlistId;
  final String? seriesId;
  final PlaylistModel? playlistModel;
  const AladinSeriesDetailPage({
    super.key,
    required this.seriesName,
    required this.playlistId,
    this.seriesId,
    this.playlistModel,
  });
  @override
  State<AladinSeriesDetailPage> createState() => _AladinSeriesDetailPageState();
}

class _AladinSeriesDetailPageState extends State<AladinSeriesDetailPage> {
  List<ChannelModel> _eps = [];
  ChannelModel? _rep;
  int _season = -1;
  bool _loading = true;
  bool _tmdbLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var eps = await ChannelService.instance
        .getSeriesEpisodes(widget.playlistId, widget.seriesName);

    // Xtream için on-demand episode fetch
    // Eğer liste boşsa veya sadece URL'si boş olan "ana seri kaydı" varsa bölümleri çek
    // ⚡ CACHE: 24 saat kuralını uygula (shouldRefetchEpisodes)
    final onlyMainEntry = eps.length == 1 && eps.first.url.isEmpty;
    final needsFetch = eps.isEmpty ||
        onlyMainEntry ||
        (eps.isNotEmpty && eps.first.shouldRefetchEpisodes);

    if (needsFetch && widget.seriesId != null) {
      final state = context.read<AppState>();
      final p = state.active;
      if (p != null && p.type == 'xtream') {
        final pass = await PlaylistService.instance.getPass(p.id);
        if (pass != null) {
          final parser = AladinXtreamParser(
            server: p.xtreamServer ?? '',
            username: p.xtreamUsername ?? '',
            password: pass,
          );
          // Önce bölümleri çek
          final remoteEps = await parser.fetchSeriesEpisodes(
            widget.seriesId!,
            widget.playlistId,
            'Series',
          );
          if (remoteEps.isNotEmpty) {
            await ChannelService.instance.saveChannels(remoteEps);
            // Veritabanından güncel halini tekrar çek
            eps = await ChannelService.instance
                .getSeriesEpisodes(widget.playlistId, widget.seriesName);
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      // Sadece oynatılabilir (URL'si olan) bölümleri listeye al
      _eps = deduplicateEpisodes(eps);
      // Bilgi paneli için (afiş vs) ilk kaydı (ana kayıt da olabilir) kullan
      _rep = eps.isNotEmpty ? eps.first : null;
      _loading = false;
    });
    if (_rep != null && _rep!.tmdbPoster == null) _fetchTmdb();
  }

  Future<void> _fetchTmdb() async {
    final rep = _rep!;
    final lang = context.read<AppState>().lang;
    setState(() => _tmdbLoading = true);
    final meta = await TmdbService.instance
        .searchSeries(rep.seriesName ?? rep.name, lang: lang);
    if (meta != null) {
      await ChannelService.instance.saveTmdbMeta(
        channelId: rep.id,
        tmdbId: meta['tmdbId'],
        imdbRating: meta['imdbRating'],
        poster: meta['poster'],
        overview: meta['overview'],
        year: meta['year'],
      );
      final fresh = await ChannelService.instance.getById(rep.id);
      if (mounted && fresh != null) setState(() => _rep = fresh);
    }
    if (mounted) setState(() => _tmdbLoading = false);
  }

  List<int> get _seasons {
    final s = <int>{};
    for (final e in _eps) {
      if (e.season != null) s.add(e.season!);
    }
    return s.toList()..sort();
  }

  List<ChannelModel> get _filtered =>
      _season == -1 ? _eps : _eps.where((e) => e.season == _season).toList();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AladinAppBar(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : LayoutBuilder(builder: (_, cns) {
              final wide =
                  cns.maxWidth > 500; // Geniş ekran (TV/Tablet) kontrolü
              return wide ? _wideLayout(state) : _narrowLayout(state, _seasons);
            }),
    );
  }

  Widget _wideLayout(AppState state) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 220,
          child: _infoPanel(state)), // Sol bilgi paneli genişliği (220)
      const VerticalDivider(
          width: 1, color: AppTheme.divider), // Dikey çizgi kalınlığı
      Expanded(child: _episodeList(state)),
    ]);
  }

  Widget _narrowLayout(AppState state, List<int> seasons) {
    return Column(children: [
      if (_rep?.tmdbPoster != null || _rep?.tmdbOverview != null)
        _infoPanel(state, compact: true),
      Expanded(child: _episodeList(state)),
    ]);
  }

  Widget _infoPanel(AppState state, {bool compact = false}) {
    final rep = _rep;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14), // Panel iç boşluğu
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (rep?.tmdbPoster != null)
          ClipRRect(
              borderRadius: BorderRadius.circular(8), // Afiş köşe yuvarlaması
              child: Image.network(rep!.tmdbPoster!,
                  width: double.infinity,
                  height: compact
                      ? 120
                      : 180, // Mobilde 120, TV'de 180 afiş yüksekliği
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())),
        const SizedBox(height: 10), // Afiş-İsim arası boşluk
        Text(widget.seriesName, style: AppTheme.headingMedium),
        if (rep?.tmdbYear != null)
          Text(rep!.tmdbYear!,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        if (rep?.imdbRating != null) ...[
          const SizedBox(height: 6), // Yıl-Yıldız arası boşluk
          Row(children: [
            const Icon(Icons.star,
                color: AppTheme.favorite, size: 14), // Yıldız ikon boyutu
            const SizedBox(width: 4), // Yıldız-Puan arası boşluk
            Text('${rep!.imdbRating}/10',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ]),
        ],
        if (rep?.tmdbOverview != null) ...[
          const SizedBox(height: 10), // Puan-Açıklama arası boşluk
          Text(rep!.tmdbOverview!,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
              maxLines: compact ? 3 : 20, // Mobilde 3, TV'de 20 satır özet
              overflow: TextOverflow.ellipsis),
        ],
        if (_tmdbLoading)
          const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                  width: 20,
                  height: 20, // TMDB yükleniyor simgesi boyutu
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent))),
      ]),
    );
  }

  Widget _seasonBar(List<int> seasons) {
    if (seasons.isEmpty) return const SizedBox.shrink();
    final s = context.read<AppState>().s;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.fromLTRB(14, 8, 14, 4), // Sezon çubuğu dış boşluğu
      child: Row(children: [
        _SChip(
            label: s.all,
            active: _season == -1,
            onTap: () => setState(() => _season = -1)),
        ...seasons.map((sec) => _SChip(
            label: 'S$sec',
            active: _season == sec,
            onTap: () => setState(() => _season = sec))),
      ]),
    );
  }

  Widget _episodeList(AppState state) {
    final seasons = _seasons;
    return Column(children: [
      if (seasons.isNotEmpty) _seasonBar(seasons),
      Expanded(
          child: ListView.builder(
        itemCount: _filtered.length,
        itemBuilder: (_, i) {
          final ep = _filtered[i];
          final double progress = ep.totalDurationSeconds > 0
              ? (ep.watchedSeconds / ep.totalDurationSeconds).clamp(0.0, 1.0)
              : 0.0;

          return Column(
            children: [
              ListTile(
                leading: Container(
                    width: 44, // Bölüm numarası kutusu genişliği
                    height: 44, // Bölüm numarası kutusu yüksekliği
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                        child: Text(ep.episode != null ? 'E${ep.episode}' : '?',
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)))),
                title: Text(ep.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Row(children: [
                  if (ep.season != null)
                    Text('S${ep.season}', style: AppTheme.caption),
                  if (ep.quality != null)
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 8), // Sezon-Kalite arası boşluk
                        child: Text(ep.quality!,
                            style: AppTheme.caption
                                .copyWith(color: AppTheme.accent))),
                ]),
                trailing: const Icon(Icons.play_arrow,
                    color:
                        AppTheme.accent), // Oynat ikon boyutu (varsayılan 24)
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PlayerPage(channel: ep, playlist: _filtered))),
              ),
              if (progress > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    height: 2,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    color: Colors.white10,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(color: Colors.redAccent),
                    ),
                  ),
                ),
            ],
          );
        },
      )),
    ]);
  }
}

class _SChip extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SChip(
      {required this.label, required this.active, required this.onTap});

  @override
  State<_SChip> createState() => _SChipState();
}

class _SChipState extends State<_SChip> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) => Focus(
        onFocusChange: (value) => setState(() => _focused = value),
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.only(right: 8), // Çipler arası boşluk
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6), // Çip iç boşluğu
            decoration: BoxDecoration(
                color: _focused
                    ? Colors.white
                    : (widget.active ? AppTheme.accent : AppTheme.card),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _focused ? AppTheme.accent : Colors.transparent,
                  width: 2,
                )), // Çip yuvarlaması
            child: Text(widget.label,
                style: TextStyle(
                    color: _focused
                        ? Colors.black
                        : (widget.active
                            ? Colors.white
                            : AppTheme.textSecondary),
                    fontSize: 12,
                    fontWeight: widget.active || _focused
                        ? FontWeight.w700
                        : FontWeight.w400)),
          ),
        ),
      );
}

class SeriesPage extends StatefulWidget {
  final void Function(CategoryModel)? onCategoryTap;
  final FocusNode? categoryFocusNode;
  const SeriesPage({super.key, this.onCategoryTap, this.categoryFocusNode});
  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  List<CategoryModel> _categories = [];
  List<ChannelModel> _favorites = [];
  List<ChannelModel> _continueWatching = [];
  Map<String, double> _seriesProgress = {};
  bool _loading = false;
  int? _loadedId;

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
    final a = context.read<AppState>().active;
    if (a != null) _load(a.id);
  }

  Future<void> _load(int id) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadedId = id;
    });
    final cats = await ChannelService.instance
        .getCategories(playlistId: id, contentType: 'series');
    final allFavs = await ChannelService.instance.getFavorites(id);
    final seriesFavs = allFavs.where((c) => c.contentType == 'series').toList();

    final cw = await ChannelService.instance.getContinueWatching(id);
    final seriesCW = cw.where((c) => c.contentType == 'series').toList();

    final progress = await ChannelService.instance.getSeriesProgressMap(id);

    if (!mounted) return;
    setState(() {
      _categories = cats;
      _favorites = seriesFavs;
      _continueWatching = seriesCW;
      _seriesProgress = progress;
      _loading = false;
    });
  }

  Future<void> _confirmRemoveCW(ChannelModel ch) async {
    final s = context.read<AppState>().s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.continueWatching,
            style: const TextStyle(color: Colors.white)),
        content: Text(s.removeListQ(ch.seriesName ?? ch.name),
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
    if (ok == true) {
      await ChannelService.instance
          .updateWatched(ch.id, 0); // Progress sıfırlayarak listeden çıkarır
      if (_loadedId != null) _load(_loadedId!);
    }
  }

  Future<void> _confirmRemoveFavorite(ChannelModel ch) async {
    final s = context.read<AppState>().s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.favorites, style: const TextStyle(color: Colors.white)),
        content: Text(s.removeFavoriteQ(ch.seriesName ?? ch.name),
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
    if (ok == true) {
      await ChannelService.instance.toggleFavorite(ch.id);
      if (_loadedId != null) _load(_loadedId!);
    }
  }

  void _onSeriesTap(ChannelModel ch, int playlistId) {
    final name =
        ch.seriesName?.trim().isNotEmpty == true ? ch.seriesName! : ch.name;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AladinSeriesDetailPage(
          seriesName: name,
          playlistId: playlistId,
          seriesId: ch.parentSeriesId ?? ch.tvgId,
          playlistModel: context.read<AppState>().active,
        ),
      ),
    );
  }

  void _openSearch() {
    final s = context.read<AppState>().s;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(
          isActive: true,
          contentType: 'series',
          sectionTitle: s.navSeries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, state, __) {
      final s = state.s;
      final noList = state.active == null;

      if (noList) {
        return AladinEmptyState(
          icon: Icons.video_library_outlined,
          title: s.noPlaylistSelected,
          message: s.addPlaylistHint,
          buttonLabel: s.goToSettings,
          onAction: () => state.navigateToPage(6),
        );
      }

      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AladinAppBar(
            onSearch: _openSearch,
            onRefresh:
                state.active != null ? () => _load(state.active!.id) : null),
        body: _loading && _categories.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accent))
            : _categories.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Icon(Icons.video_library_outlined,
                            size: 50, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text(s.noSeriesFound,
                            style:
                                const TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                            onPressed: () => _load(state.active!.id),
                            autofocus: true,
                            icon: const Icon(Icons.refresh),
                            label: Text(s.retry)),
                      ]))
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
                            horizontal: MediaQuery.of(context).size.width *
                                0.05, // Sol-sağ güvenli alan boşluğu
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              if (_continueWatching.isNotEmpty)
                                _SeriesFavStrip(
                                  title: state.s.continueWatch,
                                  channels: _continueWatching,
                                  progressMap: _seriesProgress,
                                  onTap: (ch) =>
                                      _onSeriesTap(ch, state.active!.id),
                                  onLongPress: (ch) => _confirmRemoveCW(ch),
                                ),
                              if (_favorites.isNotEmpty)
                                _SeriesFavStrip(
                                  title: state.s.favorites,
                                  channels: _favorites,
                                  progressMap: _seriesProgress,
                                  onTap: (ch) =>
                                      _onSeriesTap(ch, state.active!.id),
                                  onLongPress: (ch) =>
                                      _confirmRemoveFavorite(ch),
                                ),
                            ]),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width *
                                0.05, // Sol-sağ güvenli alan boşluğu
                          ),
                          sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                            (_, i) => CategoryRow(
                              key: ValueKey(_categories[i].id),
                              category: _categories[i],
                              playlistId: state.active!.id,
                              seriesProgressMap: _seriesProgress,
                              onChannelTap: (ch, list) =>
                                  _onSeriesTap(ch, state.active!.id),
                              onCategoryTap: widget.onCategoryTap,
                            ),
                            childCount: _categories.length,
                          )),
                        ),
                        const SliverToBoxAdapter(
                            child: SizedBox(height: 40)), // Liste sonu boşluğu
                      ]),
      );
    });
  }
}

class _SeriesFavStrip extends StatelessWidget {
  final String title;
  final List<ChannelModel> channels;
  final Map<String, double> progressMap;
  final void Function(ChannelModel) onTap;
  final void Function(ChannelModel)? onLongPress;

  const _SeriesFavStrip({
    required this.title,
    required this.channels,
    required this.progressMap,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                14, 16, 14, 8), // Şerit başlığı dış boşluğu
            child: Text(title, style: AppTheme.headingMedium),
          ),
          SizedBox(
            height: AppTheme.listHeight, // Standart şerit yüksekliği
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14), // Şerit içi yan boşluklar
              itemCount: channels.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 12), // Kartlar arası boşluk
              clipBehavior: Clip.none,
              itemBuilder: (_, i) {
                final ch = channels[i];
                final prog =
                    progressMap[ch.seriesName?.trim() ?? ch.name.trim()];
                return ChannelCard(
                  channel: ch,
                  seriesProgress: prog,
                  onTap: () => onTap(ch),
                  onLongPress:
                      onLongPress != null ? () => onLongPress!(ch) : null,
                );
              },
            ),
          ),
        ],
      );
}
