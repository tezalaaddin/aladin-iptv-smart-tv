import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/aladin_category_model.dart';
import '../core/services/aladin_metadata_sync_service.dart';
import '../core/services/aladin_epg_engine.dart';
import '../core/services/aladin_channel_service.dart';
import '../core/di/aladin_di.dart';
import '../core/state/aladin_app_prefs.dart';
import '../core/state/aladin_app_state.dart';
import '../shared/theme/aladin_app_theme.dart';
import 'live_tv/aladin_live_tv_page.dart';
import 'movies/aladin_movies_page.dart';
import 'series/aladin_series_page.dart';
import 'favorites/aladin_favorites_page.dart';
import 'search/aladin_search_page.dart';
import 'settings/aladin_settings_page.dart';
import 'player/aladin_player_page.dart';
import 'content/aladin_category_page.dart';
import 'home/aladin_home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;
  final FocusScopeNode _mainFocusScope = FocusScopeNode();
  final List<FocusNode> _navNodes = List.generate(7, (index) => FocusNode());
  final FocusNode _contentFocusNode = FocusNode();
  bool _epgDialogShown = false;
  DateTime? _lastKeyEventTime;
  
  CategoryModel? _selectedCategory;

  void _goTo(int i) {
    if (_index == i && _selectedCategory == null) return;
    setState(() {
      _index = i;
      _selectedCategory = null; 
    });
  }

  void _openCategory(CategoryModel cat) {
    setState(() => _selectedCategory = cat);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = AppState.instance;
      final activeId = state.active?.id;
      if (activeId != null) {
        MetadataSyncService.instance.startSync(activeId, lang: state.lang);
        _autoPlayLast(activeId);
      }
      _checkUpdates();
    });
  }

  void _autoPlayLast(int playlistId) async {
    final bool autoPlay = sl<AladinPrefs>().getBool('auto_play_last', def: false);
    if (!autoPlay) return;

    final last = await ChannelService.instance.getLastWatched(playlistId);
    if (last != null && mounted) {
      if (last.contentType == 'series') {
        final name = last.seriesName?.trim().isNotEmpty == true ? last.seriesName! : last.name;
        Navigator.push(context, MaterialPageRoute(builder: (_) => AladinSeriesDetailPage(
          seriesName: name,
          playlistId: last.playlistId,
          seriesId: last.parentSeriesId ?? last.tvgId,
          playlistModel: AppState.instance.active,
        )));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(
          channel: last,
          playlist: [last],
        )));
      }
    }
  }

  void _checkUpdates() {
    final state = AppState.instance;
    final epg = AladinEpgEngine.instance;

    // 1. EPG Update Check (> 6 days)
    if (epg.needsUpdate && !_epgDialogShown) {
      _epgDialogShown = true;
      Future.delayed(const Duration(seconds: 3), () => _showUpdateRecommendation('epg'));
    }
    
    // 2. Playlist Update Check (> 24 hours)
    final active = state.active;
    if (active != null) {
      final hoursSinceUpdate = DateTime.now().difference(active.lastUpdated).inHours;
      if (hoursSinceUpdate >= 24) {
        // Only show once per session
        debugPrint('Playlist update recommended: $hoursSinceUpdate hours old');
      }
    }
  }

  void _showUpdateRecommendation(String type) async {
    if (!mounted) return;
    final s = AppState.instance.s;
    final isEpg = type == 'epg';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(isEpg ? s.epgUpdate : s.update, style: const TextStyle(color: Colors.white)),
        content: Text(
          isEpg ? s.epgUpdateRecommended : s.updating, 
          style: const TextStyle(color: AppTheme.textSecondary)
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isEpg) {
                AladinEpgEngine.instance.forceSync();
              } else {
                _goTo(6); // Settings
              }
            },
            child: Text(s.update),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mainFocusScope.dispose();
    _contentFocusNode.dispose();
    for (final n in _navNodes) {
      n.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleGlobalKeys(KeyEvent event) {
    if (event is KeyRepeatEvent) return KeyEventResult.handled;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // ── KESİN ÇÖZÜM: Yazı alanı kontrolü
    final primaryFocus = FocusManager.instance.primaryFocus;
    bool isEditable = false;
    
    if (primaryFocus != null) {
      final context = primaryFocus.context;
      final dbg = primaryFocus.debugLabel?.toLowerCase() ?? '';
      isEditable = context?.widget is EditableText ||
                   context?.findAncestorWidgetOfExactType<TextField>() != null ||
                   dbg.contains('editable') ||
                   dbg.contains('field') ||
                   dbg.contains('input');
    }

    final now = DateTime.now();
    if (_lastKeyEventTime != null && now.difference(_lastKeyEventTime!) < const Duration(milliseconds: 150)) {
      return KeyEventResult.handled;
    }
    _lastKeyEventTime = now;

    final key = event.logicalKey;
    final label = event.logicalKey.keyLabel;

    // Navigasyon Haritası
    final Map<String, int> navMap = {
      '0': 0, // Home
      '1': 1, // Live TV
      '2': 2, // Movies
      '3': 3, // Series
      '4': 4, // Search
      '5': 5, // Favorites
      '6': 6, // Settings
    };

    // Arama (4) ve Ayarlar (6) sayfalarında sayı kısayollarını tamamen devre dışı bırakıyoruz.
    // Ayrıca herhangi bir sayfada metin alanındaysak da engelliyoruz.
    if ((_index == 4 || _index == 6 || isEditable) && navMap.containsKey(label)) {
      return KeyEventResult.ignored;
    }

    int? targetIndex;
    if (key == LogicalKeyboardKey.colorF0Red || key == LogicalKeyboardKey.f1) targetIndex = 1;
    else if (key == LogicalKeyboardKey.colorF1Green || key == LogicalKeyboardKey.f2) targetIndex = 2;
    else if (key == LogicalKeyboardKey.colorF2Yellow || key == LogicalKeyboardKey.f3) targetIndex = 3;
    else if (key == LogicalKeyboardKey.colorF3Blue || key == LogicalKeyboardKey.f4) targetIndex = 6;
    else if (navMap.containsKey(label)) targetIndex = navMap[label];

    if (targetIndex != null) {
      _goTo(targetIndex);
      // Navigasyon barındaki ilgili butona odaklan
      if (targetIndex < _navNodes.length) {
        _navNodes[targetIndex].requestFocus();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    final reqIdx = state.requestedIndex;
    if (reqIdx != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state.clearNavigationRequest();
          _goTo(reqIdx);
          _navNodes[reqIdx].requestFocus();
        }
      });
    }

    // ── DEEP LINK / PLAY REQUEST HANDLING (ELITE UX) ────────────────────────
    final reqCh = state.requestedChannel;
    if (reqCh != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state.clearPlayRequest();
          if (reqCh.contentType == 'series') {
            final name = reqCh.seriesName?.trim().isNotEmpty == true ? reqCh.seriesName! : reqCh.name;
            Navigator.push(context, MaterialPageRoute(builder: (_) => AladinSeriesDetailPage(
              seriesName: name,
              playlistId: reqCh.playlistId,
              seriesId: reqCh.parentSeriesId ?? reqCh.tvgId,
              playlistModel: state.active,
            )));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(
              channel: reqCh,
              playlist: [reqCh],
            )));
          }
        }
      });
    }

    final s = state.s;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    Widget content;
    if (_selectedCategory != null) {
      content = AladinCategoryPage(
        category: _selectedCategory!,
        playlistId: state.active!.id,
        onChannelTap: (ch, list) {
          if (ch.contentType == 'series') {
            final name = ch.seriesName?.trim().isNotEmpty == true ? ch.seriesName! : ch.name;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AladinSeriesDetailPage(
                  seriesName: name,
                  playlistId: state.active!.id,
                  seriesId: ch.parentSeriesId ?? ch.tvgId,
                  playlistModel: state.active,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerPage(
                  channel: ch,
                  playlist: list,
                ),
              ),
            );
          }
        },
        onBack: () => setState(() => _selectedCategory = null),
      );
    } else {
      final pages = [
        const HomePage(),
        LiveTvPage(
          onGoToSettings: () => _goTo(6),
          onCategoryTap: _openCategory,
        ),
        MoviesPage(onCategoryTap: _openCategory),
        SeriesPage(onCategoryTap: _openCategory),
        SearchPage(isActive: _index == 4),
        const FavoritesPage(),
        SettingsPage(
          onPlaylistSelected: () {
            _goTo(0);
            final state = AppState.instance;
            final activeId = state.active?.id;
            if (activeId != null) {
              MetadataSyncService.instance.startSync(activeId, lang: state.lang);
            }
          },
        ),
      ];
      content = IndexedStack(index: _index, children: pages);
    }

    return FocusScope(
      node: _mainFocusScope,
      autofocus: true,
      child: Focus(
        onKeyEvent: (node, event) => _handleGlobalKeys(event),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            
            final sidebarHasFocus = _navNodes.any((n) => n.hasFocus);

            if (!sidebarHasFocus) {
              // 1. İçerik alanındaysak yan menüye odaklan
              _navNodes[_index].requestFocus();
              return;
            }

            if (_selectedCategory != null) {
              setState(() => _selectedCategory = null);
              _navNodes[_index].requestFocus();
              return;
            }

            if (_index != 0) {
              // 2. Yan menüde ama Home değilsek Home'a git
              _goTo(0);
              _navNodes[0].requestFocus();
              return;
            }
            
            // 3. Home'dayız, çıkış onayı iste
            final shouldExit = await _showExitConfirmation(s);
            if (shouldExit && mounted) {
              await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            } else {
              _navNodes[_index].requestFocus();
            }
          },
          child: Scaffold(
            backgroundColor: AppTheme.background,
            body: Stack(
              children: [
                // ── DYNAMIC BACKDROP (PRO FEATURE) ──────────────────────────
                Positioned.fill(child: _DynamicBackdrop()),
                
                // ── METADATA SYNC INDICATOR (ELITE UX) ──────────────────────
                const Positioned(
                  top: 20, 
                  right: 40,
                  child: _SyncIndicator(),
                ),

                Row(
                  children: [
                    if (isLandscape)
                      _SideNavBar(
                        currentIndex: _index,
                        onTap: _goTo,
                        nodes: _navNodes,
                        onRightPressed: () => _contentFocusNode.requestFocus(),
                      ),
                    Expanded(
                      child: Focus(
                        focusNode: _contentFocusNode,
                        skipTraversal: true,
                        child: FocusTraversalGroup(
                          policy: OrderedTraversalPolicy(),
                          child: content,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            bottomNavigationBar: isLandscape
                ? null
                : BottomNavigationBar(
              currentIndex: _index,
              onTap: _goTo,
              selectedItemColor: AppTheme.accent,
              unselectedItemColor: AppTheme.textMuted,
              backgroundColor: AppTheme.surface,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.home), label: s.navHome),
                BottomNavigationBarItem(icon: const Icon(Icons.live_tv), label: s.navLiveTV),
                BottomNavigationBarItem(icon: const Icon(Icons.movie), label: s.navMovies),
                BottomNavigationBarItem(icon: const Icon(Icons.video_library), label: s.navSeries),
                BottomNavigationBarItem(icon: const Icon(Icons.search), label: s.navSearch),
                BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: s.navFavorites),
                BottomNavigationBarItem(icon: const Icon(Icons.settings), label: s.navSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation(dynamic s) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.card,
            title: Text(s.exitConfirmTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            content: Text(s.exitConfirmMsg, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              _TVDialogButton(
                label: s.no, 
                onPressed: () => Navigator.pop(context, false)
              ),
              _TVDialogButton(
                label: s.yes, 
                isPrimary: true, 
                onPressed: () => Navigator.pop(context, true)
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _DynamicBackdrop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final focused = context.watch<AppState>().focusedChannel;
    final poster = focused?.tmdbPoster ?? focused?.logoUrl;
    
    // ⚡ PRO OPTIMIZATION: Disable blur on extremely low-end devices if needed
    // or use a simpler gradient overlay.
    final bool useBlur = poster != null && poster.startsWith('http');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: useBlur
          ? Stack(
              key: ValueKey(poster),
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: poster,
                  fit: BoxFit.cover,
                  // Low-res for backdrop to save RAM
                  memCacheWidth: 400,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
                // Only render blur if it's actually visible
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        AppTheme.background,
                      ],
                      stops: const [0.0, 0.8],
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  const _SyncIndicator();
  @override
  Widget build(BuildContext context) {
    final sync = context.watch<MetadataSyncService>();
    if (!sync.isSyncing) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: sync.progress > 0 ? sync.progress : null,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            context.read<AppState>().s.syncingData,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TVDialogButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _TVDialogButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_TVDialogButton> createState() => _TVDialogButtonState();
}

class _TVDialogButtonState extends State<_TVDialogButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.isPrimary,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: _focused ? AppTheme.accent : (widget.isPrimary ? AppTheme.card : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _focused ? Colors.white : (widget.isPrimary ? AppTheme.accent : Colors.transparent),
              width: 2,
            ),
            boxShadow: _focused ? [BoxShadow(color: AppTheme.accent.withValues(alpha:0.4), blurRadius: 10)] : null,
          ),
          transform: Matrix4.identity()..scale(_focused ? 1.05 : 1.0),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _focused ? Colors.white : (widget.isPrimary ? AppTheme.accent : AppTheme.textMuted),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SideNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FocusNode> nodes;
  final VoidCallback onRightPressed;

  const _SideNavBar({required this.currentIndex, required this.onTap, required this.nodes, required this.onRightPressed});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Container(
      width: 280, // Biraz daha geniş ve ferah
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(right: BorderSide(color: Colors.white12, width: 1)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surface,
            AppTheme.background.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: AppTheme.accent.withValues(alpha:0.4), blurRadius: 10)
                    ]
                  ),
                  child: const Icon(Icons.live_tv, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.appNameShort,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        s.forSmartTv,
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SideNavItem(
                    focusNode: nodes[0],
                    icon: Icons.home,
                    label: s.navHome,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                    onRightPressed: onRightPressed,
                    numberHint: '0',
                    autofocus: currentIndex == 0, 
                  ),
                  _SideNavItem(
                    focusNode: nodes[1],
                    icon: Icons.live_tv,
                    label: s.navLiveTV,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                    onRightPressed: onRightPressed,
                    colorHint: Colors.red,
                    numberHint: '1',
                  ),
                  _SideNavItem(
                    focusNode: nodes[2],
                    icon: Icons.movie,
                    label: s.navMovies,
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                    onRightPressed: onRightPressed,
                    colorHint: Colors.green,
                    numberHint: '2',
                  ),
                  _SideNavItem(
                    focusNode: nodes[3],
                    icon: Icons.video_library,
                    label: s.navSeries,
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                    onRightPressed: onRightPressed,
                    colorHint: Colors.yellow,
                    numberHint: '3',
                  ),
                  _SideNavItem(
                    focusNode: nodes[4],
                    icon: Icons.search,
                    label: s.navSearch,
                    isSelected: currentIndex == 4,
                    onTap: () => onTap(4),
                    onRightPressed: onRightPressed,
                    colorHint: Colors.blue,
                    numberHint: '4',
                  ),
                  _SideNavItem(
                    focusNode: nodes[5],
                    icon: Icons.favorite,
                    label: s.navFavorites,
                    isSelected: currentIndex == 5,
                    onTap: () => onTap(5),
                    onRightPressed: onRightPressed,
                    numberHint: '5',
                  ),
                  _SideNavItem(
                    focusNode: nodes[6],
                    icon: Icons.settings,
                    label: s.navSettings,
                    isSelected: currentIndex == 6,
                    onTap: () => onTap(6),
                    onRightPressed: onRightPressed,
                    numberHint: '6',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onRightPressed;
  final Color? colorHint;
  final String? numberHint;
  final bool autofocus;
  final FocusNode? focusNode;

  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onRightPressed,
    this.colorHint,
    this.numberHint,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _isFocused = false;
  // Madde 4: static OLMAMALI — static olunca tüm nav item'lar aynı zamayıcıyı
  // paylaşır; bir butona basmak diğerlerini 250ms kilitler.
  DateTime? _lastNavTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Focus(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onFocusChange: (v) => setState(() => _isFocused = v),
        onKeyEvent: (node, event) {
          if (event is KeyRepeatEvent) return KeyEventResult.handled;
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          final now = DateTime.now();
          if (_lastNavTime != null && now.difference(_lastNavTime!) < const Duration(milliseconds: 250)) {
            final k = event.logicalKey;
            if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.arrowUp || 
                k == LogicalKeyboardKey.select || k == LogicalKeyboardKey.enter) {
              return KeyEventResult.handled;
            }
          }
          _lastNavTime = now;

          if (event.logicalKey == LogicalKeyboardKey.select || 
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (FocusScope.of(context).focusInDirection(TraversalDirection.right)) {
              return KeyEventResult.handled;
            }
            widget.onRightPressed?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _isFocused ? AppTheme.accent : (widget.isSelected ? AppTheme.accent.withValues(alpha:0.15) : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: _isFocused ? Border.all(color: Colors.white.withValues(alpha:0.5), width: 1) : null,
              boxShadow: _isFocused ? [
                BoxShadow(color: AppTheme.accent.withValues(alpha:0.3), blurRadius: 10, offset: const Offset(0, 4))
              ] : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: _isFocused ? Colors.white : (widget.isSelected ? AppTheme.accent : AppTheme.textSecondary),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: _isFocused ? Colors.white : (widget.isSelected ? Colors.white : AppTheme.textSecondary),
                      fontSize: 16,
                      fontWeight: widget.isSelected || _isFocused ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (widget.numberHint != null)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: widget.colorHint ?? AppTheme.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.numberHint!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
