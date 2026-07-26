import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_category_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/services/aladin_parental_service.dart';
import '../../core/services/aladin_content_visibility_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../core/state/aladin_app_prefs.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../../shared/widgets/aladin_channel_card.dart';
import '../../shared/widgets/aladin_parental_gate.dart';
import '../../shared/widgets/aladin_category_menu.dart';
import 'dart:async';
import 'aladin_epg_grid_page.dart';

class AladinCategoryPage extends StatefulWidget {
  final CategoryModel category;
  final int playlistId;
  final void Function(ChannelModel, List<ChannelModel>) onChannelTap;
  final VoidCallback? onBack;
  final ValueChanged<CategoryModel>? onCategoryChanged;
  final VoidCallback? onManageHidden;
  final FocusNode? categoryFocusNode;

  const AladinCategoryPage({
    super.key,
    required this.category,
    required this.playlistId,
    required this.onChannelTap,
    this.onBack,
    this.onCategoryChanged,
    this.onManageHidden,
    this.categoryFocusNode,
  });

  @override
  State<AladinCategoryPage> createState() => _AladinCategoryPageState();
}

class _AladinCategoryPageState extends State<AladinCategoryPage> {
  final List<ChannelModel> _channels = [];
  List<CategoryModel> _categories = [];
  bool _loading = true;
  String _sortBy = 'default';
  bool _isAscending = false;
  bool _hideWatched = false;

  Future<bool> _authorizeLockChange() async {
    final parental = ParentalService.instance;
    if (!parental.isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Önce Ayarlar > Ebeveyn Kontrolü bölümünü etkinleştirin.')));
      return false;
    }
    return requestParentalUnlock(context,
        protectedContent: true, title: 'Kilit ayarını değiştir');
  }

  Future<void> _toggleCategoryLock() async {
    if (!await _authorizeLockChange()) return;
    final locked = await ParentalService.instance
        .toggleCategoryLock(widget.playlistId, widget.category.name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            locked ? 'Kategori kilitlendi.' : 'Kategori kilidi kaldırıldı.')));
    setState(() {});
  }

  Future<void> _toggleChannelLock(ChannelModel channel) async {
    if (!await _authorizeLockChange()) return;
    final locked = await ParentalService.instance.toggleChannelLock(channel);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(locked ? 'İçerik kilitlendi.' : 'İçerik kilidi kaldırıldı.')));
    setState(() {});
  }

  Future<void> _showChannelOptions(ChannelModel channel) async {
    final scope = '${channel.playlistId}_${channel.id}';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: AppTheme.card,
        title: Text(channel.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _toggleChannelLock(channel);
            },
            child: const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('İçerik kilidini değiştir'),
              subtitle: Text('Ebeveyn PIN koduyla korunur'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              final current =
                  AladinPrefs.instance.getString('channel_decoder_$scope') ??
                      'auto';
              const values = ['auto', 'hw', 'sw'];
              final next =
                  values[(values.indexOf(current) + 1) % values.length];
              await AladinPrefs.instance
                  .setString('channel_decoder_$scope', next);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Kanal kod çözücüsü: ${next.toUpperCase()}')));
            },
            child: const ListTile(
              leading: Icon(Icons.memory),
              title: Text('Kanal kod çözücüsünü değiştir'),
              subtitle: Text('Otomatik → Donanım → Yazılım'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              final current =
                  AladinPrefs.instance.getString('channel_quality_$scope') ??
                      'auto';
              const values = ['auto', '4k', 'fhd', 'hd', 'sd'];
              final next =
                  values[(values.indexOf(current) + 1) % values.length];
              await AladinPrefs.instance
                  .setString('channel_quality_$scope', next);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Kanal kalite sınırı: ${next.toUpperCase()}')));
            },
            child: const ListTile(
              leading: Icon(Icons.high_quality),
              title: Text('Kanal kalite sınırını değiştir'),
              subtitle: Text('Otomatik → 4K → FHD → HD → SD'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final scope =
        '${widget.playlistId}_${widget.category.contentType}_${widget.category.name}';
    _sortBy =
        AladinPrefs.instance.getString('category_sort_$scope') ?? 'default';
    _isAscending =
        AladinPrefs.instance.getBool('category_sort_ascending_$scope');
    _hideWatched = AladinPrefs.instance.getBool('category_hide_watched_$scope');
    _loadAll();
  }

  @override
  void didUpdateWidget(covariant AladinCategoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _channels.clear();
      _loading = true;
      final scope =
          '${widget.playlistId}_${widget.category.contentType}_${widget.category.name}';
      _sortBy =
          AladinPrefs.instance.getString('category_sort_$scope') ?? 'default';
      _isAscending =
          AladinPrefs.instance.getBool('category_sort_ascending_$scope');
      _hideWatched =
          AladinPrefs.instance.getBool('category_hide_watched_$scope');
      _loadAll();
    }
  }

  Future<void> _saveViewPreferences() async {
    final scope =
        '${widget.playlistId}_${widget.category.contentType}_${widget.category.name}';
    await AladinPrefs.instance.setString('category_sort_$scope', _sortBy);
    await AladinPrefs.instance
        .setBool('category_sort_ascending_$scope', _isAscending);
    await AladinPrefs.instance
        .setBool('category_hide_watched_$scope', _hideWatched);
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      ChannelService.instance.getChannelsByCategory(
        playlistId: widget.playlistId,
        categoryName: widget.category.name,
        contentType: widget.category.contentType,
        limit: 2000,
      ),
      ChannelService.instance.getCategories(
        playlistId: widget.playlistId,
        contentType: widget.category.contentType,
      ),
    ]);
    final batch = results[0] as List<ChannelModel>;
    final categories = results[1] as List<CategoryModel>;
    if (!mounted) return;
    setState(() {
      _channels.addAll(batch);
      _categories = categories;
      _loading = false;
      _applySort();
    });
  }

  void _applySort() {
    setState(() {
      _channels.sort((a, b) {
        int cmp;
        if (_sortBy == 'rating') {
          final rA = double.tryParse(a.imdbRating ?? '0') ?? 0.0;
          final rB = double.tryParse(b.imdbRating ?? '0') ?? 0.0;
          cmp = rA.compareTo(rB);
        } else if (_sortBy == 'year') {
          cmp = (a.tmdbYear ?? '').compareTo(b.tmdbYear ?? '');
        } else if (_sortBy == 'alpha') {
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        } else {
          return 0;
        }
        return _isAscending ? cmp : -cmp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double safePadding = MediaQuery.of(context).size.width *
        0.04; // Ekran genişliğine göre dinamik güvenli alan
    final s = context.watch<AppState>().s;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120, // Üst başlık alanı maksimum yüksekliği
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  FocusScope.of(context)
                      .focusInDirection(TraversalDirection.right);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: BackButton(
                color: Colors.white,
                onPressed: widget.onBack ?? () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.category.contentType == 'tv' ? s.navLiveTV : s.navMovies} › ${widget.category.name}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  Text(widget.category.name,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ],
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: safePadding + 40, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: AladinCategoryMenuButton(
                  categories: _categories,
                  focusNode: widget.categoryFocusNode,
                  current: widget.category,
                  onSelected: (category) =>
                      widget.onCategoryChanged?.call(category),
                  onShowAll: widget.onBack,
                  onManageHidden: widget.onManageHidden,
                ),
              ),
              IconButton(
                tooltip: 'Kategoriyi gizle',
                onPressed: () async {
                  await ContentVisibilityService.instance
                      .hideCategory(widget.category);
                  if (mounted)
                    (widget.onBack ?? () => Navigator.pop(context))();
                },
                icon: const Icon(Icons.visibility_off_outlined),
              ),
              if (widget.category.contentType == 'tv')
                IconButton(
                  tooltip: 'Tam program rehberi',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AladinEpgGridPage(
                        channels: _filteredChannels,
                        onPlay: (channel) =>
                            widget.onChannelTap(channel, _filteredChannels),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_view_week,
                      color: AppTheme.accent),
                ),
              IconButton(
                tooltip: 'Kategoriyi kilitle / kilidi kaldır',
                onPressed: _toggleCategoryLock,
                icon: Icon(
                  ParentalService.instance.isCategoryLocked(
                          widget.playlistId, widget.category.name)
                      ? Icons.lock
                      : Icons.lock_open,
                  color: AppTheme.accent,
                ),
              ),
              _SortButton(
                label: s.rating,
                icon: Icons.star_border,
                isSelected: _sortBy == 'rating',
                isAscending: _isAscending,
                onTap: () {
                  if (_sortBy == 'rating') {
                    setState(() => _isAscending = !_isAscending);
                  } else {
                    setState(() {
                      _sortBy = 'rating';
                      _isAscending = false;
                    });
                  }
                  _applySort();
                  _saveViewPreferences();
                },
              ),
              _SortButton(
                label: s.year,
                icon: Icons.calendar_today,
                isSelected: _sortBy == 'year',
                isAscending: _isAscending,
                onTap: () {
                  if (_sortBy == 'year') {
                    setState(() => _isAscending = !_isAscending);
                  } else {
                    setState(() {
                      _sortBy = 'year';
                      _isAscending = false;
                    });
                  }
                  _applySort();
                  _saveViewPreferences();
                },
              ),
              _SortButton(
                label: s.alpha,
                icon: Icons.sort_by_alpha,
                isSelected: _sortBy == 'alpha',
                isAscending: _isAscending,
                onTap: () {
                  if (_sortBy == 'alpha') {
                    setState(() => _isAscending = !_isAscending);
                  } else {
                    setState(() {
                      _sortBy = 'alpha';
                      _isAscending = true;
                    });
                  }
                  _applySort();
                  _saveViewPreferences();
                },
              ),
              _SortButton(
                label: 'Gizle', // s.hideWatched if exists
                icon: _hideWatched ? Icons.visibility_off : Icons.visibility,
                isSelected: _hideWatched,
                isAscending: false,
                onTap: () {
                  setState(() => _hideWatched = !_hideWatched);
                  _saveViewPreferences();
                },
              ),
              SizedBox(width: safePadding), // En sağdaki boşluk
            ],
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accent)),
            )
          else if (_filteredChannels.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  s.noContentFound,
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 16),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  horizontal: safePadding, vertical: 10), // Izgara dış boşluğu
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: AppTheme.cardWidth +
                      20, // Her bir sütunun maksimum genişliği
                  mainAxisSpacing: 25, // Dikey satırlar arası boşluk
                  crossAxisSpacing: 15, // Yatay sütunlar arası boşluk
                  mainAxisExtent:
                      AppTheme.gridHeight, // Her bir öğenin toplam yüksekliği
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ch = _filteredChannels[index];
                    return Center(
                      child: ChannelCard(
                        key: ValueKey('grid_${ch.id}'),
                        channel: ch,
                        margin: EdgeInsets.zero,
                        onTap: () => widget.onChannelTap(ch, _filteredChannels),
                        onLongPress: () => _showChannelOptions(ch),
                      ),
                    );
                  },
                  childCount: _filteredChannels.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<ChannelModel> get _filteredChannels {
    var result = _channels.where(ParentalService.instance.canExpose);
    if (_hideWatched) result = result.where((ch) => ch.lastWatched == null);
    return result.toList();
  }
}

class _SortButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isAscending;
  final VoidCallback onTap;

  const _SortButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isAscending,
    required this.onTap,
  });

  @override
  State<_SortButton> createState() => _SortButtonState();
}

class _SortButtonState extends State<_SortButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
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
          margin: const EdgeInsets.symmetric(
              horizontal: 4, vertical: 10), // Buton dış boşluğu
          padding: const EdgeInsets.symmetric(
              horizontal: 14), // Buton iç metin boşluğu
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.accent
                : (_focused
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(25), // Hap şekli yuvarlama
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.accent
                  : (_focused ? Colors.white54 : Colors.white24),
              width: 1.5, // Buton kenarlık kalınlığı
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon,
                    size: 14,
                    color: widget.isSelected
                        ? Colors.white
                        : Colors.white70), // İkon boyutu
                const SizedBox(width: 6), // İkon-Metin arası boşluk
                Text(
                  widget.label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                      widget.isAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 12,
                      color: Colors.white), // Ok işareti boyutu
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
