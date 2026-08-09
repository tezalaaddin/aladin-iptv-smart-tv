import 'package:flutter/material.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_category_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/services/aladin_content_visibility_service.dart';
import '../../core/state/aladin_app_prefs.dart';
import '../theme/aladin_app_theme.dart';
import 'aladin_channel_card.dart';
import 'aladin_channel_options.dart';

class CategoryRow extends StatefulWidget {
  final CategoryModel category;
  final int playlistId;
  final void Function(ChannelModel, List<ChannelModel>) onChannelTap;
  final void Function(CategoryModel)? onCategoryTap;
  final void Function(ChannelModel)? onFavorite;
  final bool tvMode;
  final bool showEpg;
  final Map<String, double>? seriesProgressMap;

  const CategoryRow({
    super.key,
    required this.category,
    required this.playlistId,
    required this.onChannelTap,
    this.onCategoryTap,
    this.onFavorite,
    this.tvMode = false,
    this.showEpg = false,
    this.seriesProgressMap,
  });

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  final List<ChannelModel> _channels = [];
  final ScrollController _scroll = ScrollController();
  bool _loading = true;
  bool _hasMore = true;
  bool _fetching = false;
  static const _pageSize = 100;

  void _refreshLayout() {
    if (mounted) setState(() {});
  }

  // Layout Standards from AppTheme
  @override
  void initState() {
    super.initState();
    _fetchNext();
    _scroll.addListener(_onScroll);
    AladinPrefs.instance.layoutRevision.addListener(_refreshLayout);
  }

  @override
  void dispose() {
    _scroll.dispose();
    AladinPrefs.instance.layoutRevision.removeListener(_refreshLayout);
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      // Sona 200px kala yeni veri çek
      _fetchNext();
    }
  }

  Future<void> _fetchNext() async {
    if (_fetching || !_hasMore) return;
    setState(() => _fetching = true);
    final batch = await ChannelService.instance.getChannelsByCategory(
      playlistId: widget.playlistId,
      categoryName: widget.category.name,
      contentType: widget.category.contentType,
      offset: _channels.length,
      limit: _pageSize,
    );
    if (!mounted) return;
    setState(() {
      _channels.addAll(batch);
      _hasMore = batch.length == _pageSize;
      _loading = false;
      _fetching = false;
    });
  }

  void _openCategoryDetail() {
    if (widget.onCategoryTap != null) {
      widget.onCategoryTap!(widget.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compact 16:9 live-TV cards show more channels per 1080p row while
    // preserving enough room for the two-line EPG overlay and D-pad focus.
    final metrics = TvCardMetrics.fromPreference(
      AladinPrefs.instance.getString('tv_card_density'),
    );
    final cardWidth = widget.tvMode ? metrics.width : AppTheme.cardWidth;
    final cardHeight = widget.tvMode ? metrics.height : AppTheme.cardHeight;
    final rowHeight = widget.tvMode ? metrics.rowHeight : AppTheme.listHeight;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Kategori Başlığı ve Kanal Sayısı Alanı
      Padding(
        padding:
            const EdgeInsets.fromLTRB(14, 16, 14, 8), // Başlık dış boşlukları
        child: InkWell(
          onTap: _openCategoryDetail,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0), // Tıklama alanı iç boşluğu
            child: Row(children: [
              Expanded(
                  child: Text(widget.category.name,
                      style: AppTheme.headingMedium,
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2), // Kanal sayısı kutucuğu iç boşluğu
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${widget.category.channelCount} >',
                    style: AppTheme.caption.copyWith(
                        color: AppTheme.accent, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ),
      ),

      // Yatay Kart Listesi
      SizedBox(
        height: rowHeight,
        child: _loading
            ? _Placeholder(height: cardHeight, width: cardWidth)
            : _channels.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14), // Şeridin sol-sağ başlangıç boşluğu
                    itemCount: _channels.length + (_hasMore ? 1 : 0),
                    itemExtent: cardWidth + 14,
                    clipBehavior:
                        Clip.none, // Kartların büyüme efekti için taşmayı kesme
                    itemBuilder: (_, i) {
                      if (i >= _channels.length) {
                        return const Center(
                            child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.accent)));
                      }
                      final ch = _channels[i];
                      final prog = widget.seriesProgressMap?[
                          ch.seriesName?.trim() ?? ch.name.trim()];
                      return ChannelCard(
                        key: ValueKey(ch.id),
                        channel: ch,
                        width: cardWidth,
                        height: cardHeight,
                        tvMode: widget.tvMode,
                        showEpg: widget.showEpg,
                        seriesProgress: prog,
                        onTap: () => widget.onChannelTap(ch, _channels),
                        onLongPress: () async {
                          final changed =
                              await showAladinChannelOptions(context, ch);
                          if (changed && mounted) {
                            setState(() => _channels.removeWhere((item) =>
                                item.id == ch.id &&
                                !ContentVisibilityService.instance
                                    .isChannelVisible(item)));
                          }
                        },
                        onFavoriteTap: () => widget.onFavorite?.call(ch),
                      );
                    },
                  ),
      ),
    ]);
  }
}

@immutable
class TvCardMetrics {
  const TvCardMetrics(this.width, this.height, this.rowHeight);

  final double width;
  final double height;
  final double rowHeight;

  static TvCardMetrics fromPreference(String? density) => switch (density) {
        'standard' => const TvCardMetrics(176, 99, 128),
        'large' => const TvCardMetrics(212, 119, 152),
        _ => const TvCardMetrics(127.2, 71.4, 96),
      };
}

class _Placeholder extends StatelessWidget {
  final double height;
  final double width;
  const _Placeholder({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: 6,
      itemExtent: width + 14,
      itemBuilder: (_, __) => Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
            color: AppTheme.card.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
