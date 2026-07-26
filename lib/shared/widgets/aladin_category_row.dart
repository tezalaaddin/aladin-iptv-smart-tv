import 'package:flutter/material.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/models/aladin_category_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../theme/aladin_app_theme.dart';
import 'aladin_channel_card.dart';

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

  // Layout Standards from AppTheme
  static const double _cardWidth = AppTheme.cardWidth;
  static const double _cardHeight = AppTheme.cardHeight;
  static const double _rowHeight = AppTheme.listHeight;

  @override
  void initState() {
    super.initState();
    _fetchNext();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) { // Sona 200px kala yeni veri çek
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Kategori Başlığı ve Kanal Sayısı Alanı
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 8), // Başlık dış boşlukları
        child: InkWell(
          onTap: _openCategoryDetail,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4.0), // Tıklama alanı iç boşluğu
            child: Row(children: [
              Expanded(child: Text(widget.category.name, style: AppTheme.headingMedium, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Kanal sayısı kutucuğu iç boşluğu
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                child: Text('${widget.category.channelCount} >', style: AppTheme.caption.copyWith(color: AppTheme.accent, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ),
      ),
      
      // Yatay Kart Listesi
      SizedBox(
        height: _rowHeight, // Şerit yüksekliği (250)
        child: _loading
            ? _Placeholder(height: _cardHeight)
            : _channels.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14), // Şeridin sol-sağ başlangıç boşluğu
                    itemCount: _channels.length + (_hasMore ? 1 : 0),
                    itemExtent: _cardWidth + 14, // Her bir kartın kapladığı toplam yatay alan (Genişlik + Boşluk)
                    clipBehavior: Clip.none, // Kartların büyüme efekti için taşmayı kesme
                    itemBuilder: (_, i) {
                      if (i >= _channels.length) {
                        return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)));
                      }
                      final ch = _channels[i];
                      final prog = widget.seriesProgressMap?[ch.seriesName?.trim() ?? ch.name.trim()];
                      return ChannelCard(
                        key: ValueKey(ch.id),
                        channel: ch,
                        width: _cardWidth, // 130
                        height: _cardHeight, // 175
                        showEpg: widget.showEpg,
                        seriesProgress: prog,
                        onTap: () => widget.onChannelTap(ch, _channels),
                        onFavoriteTap: () => widget.onFavorite?.call(ch),
                      );
                    },
                  ),
      ),
    ]);
  }
}

class _Placeholder extends StatelessWidget {
  final double height;
  const _Placeholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: 6,
      itemExtent: 144, // Öğe genişliği
      itemBuilder: (_, __) => Container(
        width: 130, 
        height: height, 
        margin: const EdgeInsets.only(right: 14), 
        decoration: BoxDecoration(
          color: AppTheme.card.withValues(alpha: 0.5), 
          borderRadius: BorderRadius.circular(8)
        ),
      ),
    );
  }
}
