import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/aladin_playlist_model.dart';
import '../../../core/services/aladin_playlist_service.dart';
import '../../../core/services/aladin_update_service.dart';
import '../../core/services/aladin_epg_engine.dart';
import '../../../core/state/aladin_app_prefs.dart';
import '../../../core/state/aladin_app_state.dart';
import '../../../core/state/aladin_app_strings.dart';
import '../../../shared/theme/aladin_app_theme.dart';
import '../../../shared/widgets/aladin_input_dialog.dart';
import '../../../shared/widgets/aladin_folder_explorer.dart';

class SettingsThemeTokens {
  static const double radius = 12.0;
  static const double spacing = 20.0;
  static const Duration animDuration = Duration(milliseconds: 140);

  static List<BoxShadow> focusShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];

  static BoxDecoration cardDecoration(
      {bool focused = false, bool active = false}) {
    return BoxDecoration(
      color: focused
          ? Colors.white
          : (active ? AppTheme.accent.withOpacity(0.08) : AppTheme.card),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: focused
            ? Colors.white
            : (active ? AppTheme.accent : Colors.transparent),
        width: 1.5,
      ),
      boxShadow: focused ? focusShadow(AppTheme.accent) : null,
    );
  }
}

enum ImportType { m3u, xtream, local }

class SettingsPage extends StatefulWidget {
  final VoidCallback? onPlaylistSelected;
  final bool isActive;
  const SettingsPage(
      {super.key, this.onPlaylistSelected, this.isActive = false});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PackageInfo? _packageInfo;
  bool _importing = false;
  bool _epgSyncing = false;
  String _status = '';

  // Focus Management
  late final FocusNode _pageFocusNode = FocusNode(debugLabel: 'settings_page');
  late final List<FocusNode> _leftNodes =
      List.generate(8, (i) => FocusNode(debugLabel: 'left_$i'));
  final List<FocusNode> _playlistNodes = [];

  final ScrollController _leftScroll = ScrollController();
  final ScrollController _rightScroll = ScrollController();

  bool _inLeftPanel = true;
  int _leftFocusedIndex = 0;
  int _rightFocusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isActive) {
        _leftNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pageFocusNode.dispose();
    for (var node in _leftNodes) {
      node.dispose();
    }
    for (var node in _playlistNodes) {
      node.dispose();
    }
    _leftScroll.dispose();
    _rightScroll.dispose();
    super.dispose();
  }

  void _updatePlaylistNodes(int count) {
    if (_playlistNodes.length == count) return;

    if (_playlistNodes.length < count) {
      for (int i = _playlistNodes.length; i < count; i++) {
        _playlistNodes.add(FocusNode(debugLabel: 'playlist_$i'));
      }
    } else {
      while (_playlistNodes.length > count) {
        _playlistNodes.removeLast().dispose();
      }
    }
  }

  KeyEventResult _handleGlobalKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    final state = context.read<AppState>();

    // Back / Escape handling
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.goBack) {
      if (!_inLeftPanel) {
        setState(() => _inLeftPanel = true);
        _leftNodes[_leftFocusedIndex].requestFocus();
        return KeyEventResult.handled;
      }
      // If in left panel, let it propagate to MainPage for tab switching or app exit
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowRight && _inLeftPanel) {
      if (state.playlists.isNotEmpty) {
        setState(() => _inLeftPanel = false);
        _playlistNodes[_rightFocusedIndex.clamp(0, state.playlists.length - 1)]
            .requestFocus();
        return KeyEventResult.handled;
      }
    }

    if (key == LogicalKeyboardKey.arrowLeft && !_inLeftPanel) {
      setState(() => _inLeftPanel = true);
      _leftNodes[_leftFocusedIndex].requestFocus();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _ensureVisible(FocusNode node) {
    if (node.context != null) {
      Scrollable.ensureVisible(
        node.context!,
        duration: const Duration(milliseconds: 250),
        alignment: 0.5,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
  }

  String _toggleProtocol(String url) {
    url = url.trim();
    if (url.startsWith('https://'))
      return url.replaceFirst('https://', 'http://');
    if (url.startsWith('http://'))
      return url.replaceFirst('http://', 'https://');
    return 'http://$url';
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade700 : AppTheme.accent,
        duration: const Duration(seconds: 3)));
  }

  String _pt(ImportProgress p, int c) {
    final state = context.read<AppState>();
    final s = state.s;
    return switch (p) {
      ImportProgress.downloading => s.downloadingDots,
      ImportProgress.parsing => s.parsing,
      ImportProgress.saving => '${c} ${s.channelsSaved}',
      ImportProgress.done => '✅ ${s.done}! $c ${s.channels}',
      ImportProgress.error => '❌ ${s.error}',
      ImportProgress.idle => '',
    };
  }

  Future<void> _openM3UForm() async {
    final state = context.read<AppState>();
    final s = state.s;

    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => AladinFormDialog(
        title: s.addM3uTitle,
        fields: [
          AladinField(
            label: s.m3uUrl,
            initialValue: 'http://',
            hint: 'http://...',
            icon: Icons.link,
            quickTokens: const [
              'http://',
              'https://',
              '.com',
              '.net',
              ':8080',
              '/',
            ],
          ),
          AladinField(
              label: s.playlistName,
              hint: s.playlistName,
              icon: Icons.edit_note),
        ],
      ),
    );

    if (result != null && _hasUrlHost(result[0])) {
      String url =
          result[0].replaceAll(RegExp(r'[\u200b-\u200d\ufeff]'), '').trim();
      final name = result[1].isEmpty ? s.tabM3U : result[1];

      setState(() {
        _importing = true;
        _status = s.connecting;
      });
      try {
        PlaylistModel? p;
        try {
          p = await PlaylistService.instance.importM3U(
              url: url,
              name: name,
              onProgress: (p, c) {
                if (mounted) setState(() => _status = _pt(p, c));
              });
        } catch (e) {
          final altUrl = _toggleProtocol(url);
          if (altUrl != url) {
            url = altUrl;
            if (mounted) setState(() => _status = s.altProtocolTry);
            p = await PlaylistService.instance.importM3U(
                url: url,
                name: name,
                onProgress: (p, c) {
                  if (mounted) setState(() => _status = _pt(p, c));
                });
          } else {
            rethrow;
          }
        }
        await state.refresh();
        if (mounted && p != null) _showActivationDialog(p, s, state);
      } catch (e) {
        _showErrorDialog(e.toString(), s);
      } finally {
        if (mounted) setState(() => _importing = false);
      }
    }
  }

  Future<void> _openXtreamForm() async {
    final state = context.read<AppState>();
    final s = state.s;

    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => AladinFormDialog(
        title: s.addXtreamTitle,
        fields: [
          AladinField(
            label: s.server,
            initialValue: 'http://',
            hint: 'http://...',
            icon: Icons.dns,
            quickTokens: const [
              'http://',
              'https://',
              '.com',
              '.net',
              ':8080',
              ':25461',
              '/',
            ],
          ),
          AladinField(label: s.username, icon: Icons.person),
          AladinField(label: s.password, obscure: true, icon: Icons.lock),
          AladinField(
              label: s.playlistName, hint: s.username, icon: Icons.badge),
        ],
      ),
    );

    if (result != null &&
        _hasUrlHost(result[0]) &&
        result[1].isNotEmpty &&
        result[2].isNotEmpty) {
      String server = result[0].trim();
      setState(() {
        _importing = true;
        _status = s.validating;
      });
      try {
        PlaylistModel? p;
        try {
          p = await PlaylistService.instance.importXtream(
              server: server,
              username: result[1],
              password: result[2],
              name: result[3].isEmpty ? result[1] : result[3],
              onProgress: (p, c) {
                if (mounted) setState(() => _status = _pt(p, c));
              });
        } catch (e) {
          final altServer = _toggleProtocol(server);
          if (altServer != server) {
            server = altServer;
            if (mounted) setState(() => _status = s.altProtocolTry);
            p = await PlaylistService.instance.importXtream(
                server: server,
                username: result[1],
                password: result[2],
                name: result[3].isEmpty ? result[1] : result[3],
                onProgress: (p, c) {
                  if (mounted) setState(() => _status = _pt(p, c));
                });
          } else {
            rethrow;
          }
        }
        await state.refresh();
        if (mounted && p != null) _showActivationDialog(p, s, state);
      } catch (e) {
        _showErrorDialog(e.toString(), s);
      } finally {
        if (mounted) setState(() => _importing = false);
      }
    }
  }

  bool _hasUrlHost(String value) {
    final normalized = value.trim().replaceFirst(RegExp(r'^https?://'), '');
    return normalized.isNotEmpty;
  }

  Future<void> _openLocalForm() async {
    final state = context.read<AppState>();
    final s = state.s;

    final path = await showDialog<String>(
      context: context,
      builder: (_) => const AladinFolderExplorer(),
    );

    if (path != null) {
      final nameResult = await showDialog<String>(
        context: context,
        builder: (_) => AladinInputDialog(title: s.playlistName, hint: s.local),
      );

      setState(() {
        _importing = true;
        _status = s.reading;
      });
      try {
        final p = await PlaylistService.instance.importM3U(
            url: path,
            name: nameResult ?? s.local,
            isLocalFile: true,
            onProgress: (p, c) {
              if (mounted) setState(() => _status = _pt(p, c));
            });
        await state.refresh();
        if (mounted) _showActivationDialog(p, s, state);
      } catch (e) {
        _showErrorDialog(e.toString(), s);
      } finally {
        if (mounted) setState(() => _importing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final size = MediaQuery.of(context).size;
    final isTV = size.width > size.height && size.width > 900;

    _updatePlaylistNodes(state.playlists.length);

    Widget content;
    if (isTV) {
      content = Row(
        children: [
          Expanded(
            flex: 3,
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: CustomScrollView(
                controller: _leftScroll,
                slivers: [
                  _buildHeader(s),
                  _buildSectionHeader(s.newPlaylistAdd),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _SetupTile(
                          focusNode: _leftNodes[0],
                          icon: Icons.auto_fix_high,
                          title: s.setupWizard,
                          subtitle: s.setupWizardSub,
                          onTap: _startImportWizard,
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 0;
                              });
                            _ensureVisible(_leftNodes[0]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[1],
                          icon: Icons.sync,
                          title: s.epgUpdate,
                          subtitle:
                              AladinEpgEngine.instance.daysSinceSync >= 999
                                  ? s.epgNeverSynced
                                  : s.epgLastSync(
                                      AladinEpgEngine.instance.daysSinceSync),
                          onTap: _epgSyncing ? null : _forceEpgSync,
                          loading: _epgSyncing,
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 1;
                              });
                            _ensureVisible(_leftNodes[1]);
                          },
                        ),
                      ]),
                    ),
                  ),
                  _buildSectionHeader(s.navSettings),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _SetupTile(
                          focusNode: _leftNodes[2],
                          icon: Icons.language,
                          title: s.langTitle,
                          subtitle:
                              (AppStrings.getLanguageNames()[state.lang] ?? '')
                                  .split(' ')
                                  .skip(1)
                                  .join(' '),
                          onTap: () => _showLanguageDialog(state, s),
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 2;
                              });
                            _ensureVisible(_leftNodes[2]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[3],
                          icon: Icons.settings_input_component,
                          title: s.decoderMode,
                          subtitle: _getDecoderName(s),
                          onTap: () => _showDecoderDialog(s),
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 3;
                              });
                            _ensureVisible(_leftNodes[3]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[4],
                          icon: Icons.high_quality,
                          title: s.quality,
                          subtitle: _getQualityName(s),
                          onTap: () => _showQualityDialog(s),
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 4;
                              });
                            _ensureVisible(_leftNodes[4]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[5],
                          icon: Icons.play_circle_filled,
                          title: s.autoPlayStartup,
                          subtitle:
                              AladinPrefs.instance.getBool('auto_play_last')
                                  ? s.autoPlayActiveSub
                                  : s.autoPlayInactiveSub,
                          onTap: () async {
                            final cur =
                                AladinPrefs.instance.getBool('auto_play_last');
                            await AladinPrefs.instance
                                .setBool('auto_play_last', !cur);
                            setState(() {});
                          },
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 5;
                              });
                            _ensureVisible(_leftNodes[5]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[6],
                          icon: Icons.shuffle,
                          title: s.shuffleLaunch,
                          subtitle: AladinPrefs.instance.shuffleOnLaunch
                              ? s.shuffleActiveSub
                              : s.shuffleInactiveSub,
                          onTap: () async {
                            await AladinPrefs.instance.setBool(
                              'shuffle_on_launch',
                              !AladinPrefs.instance.shuffleOnLaunch,
                            );
                            setState(() {});
                          },
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 6;
                              });
                            _ensureVisible(_leftNodes[6]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[7],
                          icon: Icons.info_outline,
                          title: s.about,
                          subtitle:
                              '${s.version} ${_packageInfo?.version ?? '...'} (${_packageInfo?.buildNumber ?? ''})',
                          onTap: () => _showAboutDialog(s),
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 7;
                              });
                            _ensureVisible(_leftNodes[7]);
                          },
                        ),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.white10),
          Expanded(
            flex: 2,
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Container(
                color: AppTheme.surface.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRightPanelHeader(s, state),
                    Expanded(child: _playlistList(state, s)),
                    if (_status.isNotEmpty) _statusRow(),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Mobile Layout (Single Column / Responsive Mode Split)
      content = CustomScrollView(
        slivers: [
          _buildHeader(s),
          _buildSectionHeader(s.savedPlaylists.toUpperCase()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _PTile(
                  p: state.playlists[i],
                  active: state.active?.id == state.playlists[i].id,
                  onSelect: () =>
                      _showPlaylistMenu(state.playlists[i], s, state),
                  onMenu: () => _showPlaylistMenu(state.playlists[i], s, state),
                ),
                childCount: state.playlists.length,
              ),
            ),
          ),
          _buildSectionHeader(s.actions),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SetupTile(
                  icon: Icons.auto_fix_high,
                  title: s.setupWizard,
                  subtitle: s.newPlaylistAdd,
                  onTap: _startImportWizard,
                ),
                _SetupTile(
                  icon: Icons.sync,
                  title: s.epgUpdate,
                  subtitle: AladinEpgEngine.instance.daysSinceSync >= 999
                      ? s.epgNeverSynced
                      : s.epgLastSync(AladinEpgEngine.instance.daysSinceSync),
                  onTap: _epgSyncing ? null : _forceEpgSync,
                  loading: _epgSyncing,
                ),
                _SetupTile(
                  icon: Icons.language,
                  title: s.langTitle,
                  subtitle: (AppStrings.getLanguageNames()[state.lang] ?? '')
                      .split(' ')
                      .skip(1)
                      .join(' '),
                  onTap: () => _showLanguageDialog(state, s),
                ),
                _SetupTile(
                  icon: Icons.settings_input_component,
                  title: s.decoderMode,
                  subtitle: _getDecoderName(s),
                  onTap: () => _showDecoderDialog(s),
                ),
                _SetupTile(
                  icon: Icons.high_quality,
                  title: s.quality,
                  subtitle: _getQualityName(s),
                  onTap: () => _showQualityDialog(s),
                ),
                _SetupTile(
                  icon: Icons.play_circle_filled,
                  title: s.autoPlayStartup,
                  subtitle: AladinPrefs.instance.getBool('auto_play_last')
                      ? s.autoPlayActiveSub
                      : s.autoPlayInactiveSub,
                  onTap: () async {
                    final current =
                        AladinPrefs.instance.getBool('auto_play_last');
                    await AladinPrefs.instance
                        .setBool('auto_play_last', !current);
                    if (mounted) setState(() {});
                  },
                ),
                _SetupTile(
                  icon: Icons.shuffle,
                  title: s.shuffleLaunch,
                  subtitle: AladinPrefs.instance.shuffleOnLaunch
                      ? s.shuffleActiveSub
                      : s.shuffleInactiveSub,
                  onTap: () async {
                    await AladinPrefs.instance.setBool(
                      'shuffle_on_launch',
                      !AladinPrefs.instance.shuffleOnLaunch,
                    );
                    if (mounted) setState(() {});
                  },
                ),
                _SetupTile(
                  icon: Icons.info_outline,
                  title: s.about,
                  subtitle: '${s.version} ${_packageInfo?.version ?? '...'}',
                  onTap: () => _showAboutDialog(s),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      );
    }

    return Focus(
      focusNode: _pageFocusNode,
      onKeyEvent: _handleGlobalKey,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: [
            _buildCinematicBackground(),
            content,
            if (_importing) ...[
              const ModalBarrier(dismissible: false, color: Colors.black54),
              _buildImportOverlay(s),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanelHeader(AppStrings s, AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.savedPlaylists.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(s.listSavedCount(state.playlists.length),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCinematicBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              AppTheme.accent.withOpacity(0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportOverlay(AppStrings s) {
    return IgnorePointer(
      ignoring: false,
      child: Focus(
        autofocus: true,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    color: AppTheme.accent, strokeWidth: 3),
                const SizedBox(height: 32),
                Text(s.updating, style: AppTheme.headingLarge),
                const SizedBox(height: 12),
                Text(_status,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startImportWizard() async {
    final s = context.read<AppState>().s;
    final prevFocus = FocusManager.instance.primaryFocus;

    final type = await showDialog<ImportType>(
      context: context,
      builder: (context) => _ImportTypeSelectorDialog(s: s),
    );

    prevFocus?.requestFocus();
    if (type == null) return;

    switch (type) {
      case ImportType.m3u:
        await _openM3UForm();
        break;
      case ImportType.xtream:
        await _openXtreamForm();
        break;
      case ImportType.local:
        await _openLocalForm();
        break;
    }
  }

  Widget _buildHeader(AppStrings s) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 12),
                  Text(s.navSettings.toUpperCase(),
                      style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                ],
              ),
              const SizedBox(height: 12),
              Text(s.appAndListMgmt, style: AppTheme.headingLarge),
              const SizedBox(height: 8),
              Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(2))),
            ],
          ),
        ),
      );

  Widget _buildSectionHeader(String title) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 12),
          child: Row(
            children: [
              Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Text(title,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.2)),
            ],
          ),
        ),
      );

  Widget _statusRow() => Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.accent.withOpacity(0.1),
        child: Row(children: [
          if (_importing)
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.accent)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(_status,
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13))),
        ]),
      );

  void _showErrorDialog(String error, AppStrings s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.errorUrlTitle),
        content:
            Text(error.contains('Handshake') ? s.httpsError : s.errorUrlMsg),
        actions: [
          TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context),
              child: Text(s.done))
        ],
      ),
    );
  }

  void _showActivationDialog(PlaylistModel p, AppStrings s, AppState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.playlistLoadedTitle),
        content: Text(s.playlistLoadedMsg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
          ElevatedButton(
            autofocus: true,
            onPressed: () {
              Navigator.pop(context);
              state.selectPlaylist(p);
              widget.onPlaylistSelected?.call();
            },
            child: Text(s.activateNow),
          ),
        ],
      ),
    );
  }

  Future<void> _forceEpgSync() async {
    final s = context.read<AppState>().s;
    setState(() => _epgSyncing = true);
    try {
      final success = await AladinEpgEngine.instance.forceSync();
      if (!success && mounted) _snack(s.error);
    } finally {
      if (mounted) {
        setState(() => _epgSyncing = false);
        if (AladinEpgEngine.instance.syncStatus == 'ok') {
          _snack(s.epgUpdated);
        }
      }
    }
  }

  String _getDecoderName(AppStrings s) {
    final mode = AladinPrefs.instance.getString('decoderMode') ?? 'auto';
    return switch (mode) {
      'hw' => s.hwDecoder,
      'sw' => s.swDecoder,
      _ => s.autoDecoder,
    };
  }

  void _showDecoderDialog(AppStrings s) {
    final prevFocus = FocusManager.instance.primaryFocus;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.decoderMode),
        children: [
          _buildDecoderOption('auto', s.autoDecoder, s),
          _buildDecoderOption('hw', s.hwDecoder, s),
          _buildDecoderOption('sw', s.swDecoder, s),
        ],
      ),
    ).then((_) => prevFocus?.requestFocus());
  }

  Widget _buildDecoderOption(String value, String label, AppStrings s) {
    final current = AladinPrefs.instance.getString('decoderMode') ?? 'auto';
    return Focus(
      autofocus: current == value,
      child: SimpleDialogOption(
        onPressed: () async {
          await AladinPrefs.instance.setString('decoderMode', value);
          if (mounted) setState(() {});
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: TextStyle(
                color: current == value ? AppTheme.accent : Colors.white),
          ),
        ),
      ),
    );
  }

  String _getQualityName(AppStrings s) {
    final mode = AladinPrefs.instance.getString('preferredQuality') ?? 'auto';
    return switch (mode) {
      '4k' => '4K (2160p)',
      'fhd' => 'FHD (1080p)',
      'hd' => 'HD (720p)',
      'sd' => 'SD (480p)',
      _ => s.autoDecoder, // Reusing auto label
    };
  }

  void _showQualityDialog(AppStrings s) {
    final prevFocus = FocusManager.instance.primaryFocus;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.quality),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              s.qualityAdaptiveHint,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          _buildQualityOption('auto', s.autoDecoder),
          _buildQualityOption('4k', '4K (2160p)'),
          _buildQualityOption('fhd', 'FHD (1080p)'),
          _buildQualityOption('hd', 'HD (720p)'),
          _buildQualityOption('sd', 'SD (480p)'),
        ],
      ),
    ).then((_) => prevFocus?.requestFocus());
  }

  Widget _buildQualityOption(String value, String label) {
    final current =
        AladinPrefs.instance.getString('preferredQuality') ?? 'auto';
    return Focus(
      autofocus: current == value,
      child: SimpleDialogOption(
        onPressed: () async {
          await AladinPrefs.instance.setString('preferredQuality', value);
          if (mounted) setState(() {});
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: TextStyle(
                color: current == value ? AppTheme.accent : Colors.white),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(AppState state, AppStrings s) {
    final langs = AppStrings.getLanguageNames();
    final prevFocus = FocusManager.instance.primaryFocus;
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              backgroundColor: AppTheme.card,
              title: Text(s.langTitle),
              children: langs.entries
                  .map((e) => SimpleDialogOption(
                        onPressed: () {
                          state.setLang(e.key);
                          Navigator.pop(context);
                        },
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(e.value,
                                style: TextStyle(
                                    color: state.lang == e.key
                                        ? AppTheme.accent
                                        : Colors.white))),
                      ))
                  .toList(),
            )).then((_) => prevFocus?.requestFocus());
  }

  void _showPlaylistMenu(PlaylistModel p, AppStrings s, AppState state) {
    final prevFocus = FocusManager.instance.primaryFocus;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AppTheme.card,
        title: Text(p.name,
            style: const TextStyle(
                color: AppTheme.accent, fontWeight: FontWeight.bold)),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              state.selectPlaylist(p);
              widget.onPlaylistSelected?.call();
            },
            child: Row(children: [
              const Icon(Icons.play_circle_outline, color: Colors.greenAccent),
              const SizedBox(width: 12),
              Text(s.activateNow)
            ]),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _refreshPlaylist(p, state, s);
            },
            child: Row(children: [
              const Icon(Icons.sync, color: Colors.white70),
              const SizedBox(width: 12),
              Text(s.update)
            ]),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _renamePlaylist(p, state, s);
            },
            child: Row(children: [
              const Icon(Icons.edit, color: Colors.white70),
              const SizedBox(width: 12),
              Text(s.playlistRename)
            ]),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _deletePlaylist(p, state, s);
            },
            child: Row(children: [
              const Icon(Icons.delete_outline, color: Colors.redAccent),
              const SizedBox(width: 12),
              Text(s.delete, style: const TextStyle(color: Colors.redAccent))
            ]),
          ),
        ],
      ),
    ).then((_) => prevFocus?.requestFocus());
  }

  Future<void> _refreshPlaylist(
      PlaylistModel p, AppState state, AppStrings s) async {
    setState(() {
      _importing = true;
      _status = '${p.name} ${s.updating}...';
    });
    try {
      try {
        await PlaylistService.instance.refreshPlaylist(p.id,
            onProgress: (pr, c) {
          if (mounted) setState(() => _status = _pt(pr, c));
        });
      } catch (e) {
        String? altUrl;
        if (p.type == 'xtream') {
          altUrl = _toggleProtocol(p.xtreamServer ?? '');
        } else if (p.type == 'm3u') {
          altUrl = _toggleProtocol(p.url);
        }

        if (altUrl != null &&
            altUrl != (p.type == 'xtream' ? p.xtreamServer : p.url)) {
          if (mounted) setState(() => _status = s.altProtocolTry);
          if (p.type == 'xtream') {
            final pass = await PlaylistService.instance.getPass(p.id);
            if (pass != null) {
              await PlaylistService.instance.importXtream(
                  server: altUrl,
                  username: p.xtreamUsername!,
                  password: pass,
                  name: p.name,
                  onProgress: (pr, c) {
                    if (mounted) setState(() => _status = _pt(pr, c));
                  });
            }
          } else {
            await PlaylistService.instance.importM3U(
                url: altUrl,
                name: p.name,
                onProgress: (pr, c) {
                  if (mounted) setState(() => _status = _pt(pr, c));
                });
          }
        } else {
          rethrow;
        }
      }
      await state.refresh();
      _snack(s.updated);
    } catch (e) {
      _showErrorDialog(e.toString(), s);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _renamePlaylist(
      PlaylistModel p, AppState state, AppStrings s) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AladinInputDialog(
          title: s.playlistRename, initialValue: p.name, hint: s.newName),
    );
    if (newName != null && newName.isNotEmpty) {
      await PlaylistService.instance.rename(p.id, newName);
      await state.refresh();
      _snack(s.updated);
    }
  }

  Future<void> _deletePlaylist(
      PlaylistModel p, AppState state, AppStrings s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.delete),
        content: Text('${p.name} ${s.playlistDeleteQ}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(s.cancel)),
          TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(s.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await PlaylistService.instance.delete(p.id);
      await state.refresh();
      _snack(s.playlistDeleted);
    }
  }

  void _showAboutDialog(AppStrings s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(s.about),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.settingsTitle,
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 20)),
            const SizedBox(height: 4),
            Text(
                '${s.version} ${_packageInfo?.version} (${_packageInfo?.buildNumber})',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            Text(s.developer,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildLink(Icons.code, s.github,
                'https://github.com/tezalaaddin/aladin-iptv-smart-tv'),
            const SizedBox(height: 8),
            _buildLink(Icons.shop, s.playStore,
                'https://play.google.com/store/apps/details?id=com.aladin.iptv.player.pro'),
            const SizedBox(height: 8),
            _buildLink(Icons.privacy_tip, s.privacyPolicy,
                'https://github.com/tezalaaddin/aladin-iptv-smart-tv/blob/main/PRIVACY_POLICY.md'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleUpdateCheck(s),
                icon: const Icon(Icons.system_update),
                label: Text(s.checkUpdates),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context),
              child: Text(s.close))
        ],
      ),
    );
  }

  Future<void> _handleUpdateCheck(AppStrings s) async {
    Navigator.pop(context);
    _snack(s.checkingUpdates);

    final update = await UpdateService.instance.checkUpdate();

    if (update != null && update['hasUpdate'] == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.card,
          title: Text(s.checkUpdates),
          content: Text(
              '${s.version} ${update['version']} ${s.loaded}. ${s.playlistLoadedMsg}'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
            ElevatedButton(
              autofocus: true,
              onPressed: () {
                Navigator.pop(context);
                _openStoreUpdate(update['url']?.toString());
              },
              child: Text(s.download),
            ),
          ],
        ),
      );
    } else if (update?['error'] == true) {
      _snack(s.error);
    } else {
      _snack(s.upToDate);
    }
  }

  Future<void> _openStoreUpdate(String? fallbackUrl) async {
    final market = Uri.parse('market://details?id=com.aladin.iptv.player.pro');
    if (await canLaunchUrl(market)) {
      await launchUrl(market, mode: LaunchMode.externalApplication);
      return;
    }
    await launchUrl(
      Uri.parse(fallbackUrl ?? UpdateService.playStoreUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _buildLink(IconData icon, String label, String url) {
    return InkWell(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.accent),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _playlistList(AppState state, AppStrings s) {
    if (state.playlists.isEmpty)
      return Center(
          child: Text(s.noPlaylistsAdded,
              style: const TextStyle(color: AppTheme.textMuted)));
    return ListView.builder(
      controller: _rightScroll,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.playlists.length,
      itemBuilder: (_, i) => _PTile(
        focusNode: _playlistNodes[i],
        p: state.playlists[i],
        active: state.active?.id == state.playlists[i].id,
        onSelect: () => _showPlaylistMenu(state.playlists[i], s, state),
        onMenu: () => _showPlaylistMenu(state.playlists[i], s, state),
        onFocus: (v) {
          if (v) {
            setState(() {
              _inLeftPanel = false;
              _rightFocusedIndex = i;
            });
            _ensureVisible(_playlistNodes[i]);
          }
        },
      ),
    );
  }
}

class _SetupTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool loading;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocus;
  const _SetupTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap,
      this.loading = false,
      this.focusNode,
      this.onFocus});

  @override
  State<_SetupTile> createState() => _SetupTileState();
}

class _SetupTileState extends State<_SetupTile> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>().s;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        focusNode: widget.focusNode,
        onFocusChange: (v) {
          setState(() => _focused = v);
          widget.onFocus?.call(v);
        },
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter)) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: SettingsThemeTokens.animDuration,
            padding: const EdgeInsets.all(20),
            transform: Matrix4.identity()..scale(_focused ? 1.02 : 1.0),
            decoration: SettingsThemeTokens.cardDecoration(focused: _focused),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _focused
                          ? AppTheme.accent
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(widget.icon,
                      color: _focused ? Colors.white : AppTheme.accent),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(widget.title,
                          style: TextStyle(
                              color: _focused ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(widget.subtitle,
                          style: TextStyle(
                              color: _focused
                                  ? Colors.black54
                                  : AppTheme.textMuted,
                              fontSize: 14)),
                    ])),
                if (widget.loading)
                  const CircularProgressIndicator(strokeWidth: 2)
                else
                  Icon(Icons.chevron_right,
                      color: _focused ? Colors.black26 : Colors.white12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PTile extends StatefulWidget {
  final PlaylistModel p;
  final bool active;
  final VoidCallback onSelect;
  final VoidCallback onMenu;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocus;
  const _PTile(
      {required this.p,
      required this.active,
      required this.onSelect,
      required this.onMenu,
      this.focusNode,
      this.onFocus});

  @override
  State<_PTile> createState() => _PTileState();
}

class _PTileState extends State<_PTile> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>().s;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        focusNode: widget.focusNode,
        onFocusChange: (v) {
          setState(() => _focused = v);
          widget.onFocus?.call(v);
        },
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              widget.onSelect();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.contextMenu) {
              widget.onMenu();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onSelect,
          child: AnimatedContainer(
            duration: SettingsThemeTokens.animDuration,
            padding: const EdgeInsets.all(16),
            transform: Matrix4.identity()..scale(_focused ? 1.02 : 1.0),
            decoration: SettingsThemeTokens.cardDecoration(
                focused: _focused, active: widget.active),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.p.type == 'xtream'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.p.type == 'xtream' ? Icons.cloud : Icons.link,
                  size: 20,
                  color: widget.p.type == 'xtream' ? Colors.blue : Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(widget.p.name,
                                style: TextStyle(
                                    color:
                                        _focused ? Colors.black : Colors.white,
                                    fontWeight: widget.active
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)),
                        if (widget.active) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(context.read<AppState>().s.active,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.playlistStats(
                          tv: widget.p.tvCount,
                          movie: widget.p.movieCount,
                          series: widget.p.seriesCount),
                      style: TextStyle(
                          color: _focused ? Colors.black54 : AppTheme.textMuted,
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: _focused ? Colors.black26 : Colors.white12),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ImportTypeSelectorDialog extends StatefulWidget {
  final AppStrings s;
  const _ImportTypeSelectorDialog({required this.s});

  @override
  State<_ImportTypeSelectorDialog> createState() =>
      _ImportTypeSelectorDialogState();
}

class _ImportTypeSelectorDialogState extends State<_ImportTypeSelectorDialog> {
  final List<FocusNode> _nodes = List.generate(3, (i) => FocusNode());

  @override
  void dispose() {
    for (var n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.s.selectSource, style: AppTheme.headingMedium),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypeCard(
              focusNode: _nodes[0],
              icon: Icons.link,
              title: widget.s.tabM3U,
              subtitle: widget.s.m3uSub,
              onTap: () => Navigator.pop(context, ImportType.m3u),
            ),
            const SizedBox(width: 16),
            _TypeCard(
              focusNode: _nodes[1],
              icon: Icons.cloud_queue,
              title: widget.s.tabXtream,
              subtitle: widget.s.xtreamSub,
              onTap: () => Navigator.pop(context, ImportType.xtream),
            ),
            const SizedBox(width: 16),
            _TypeCard(
              focusNode: _nodes[2],
              icon: Icons.folder_open,
              title: widget.s.tabLocal,
              subtitle: widget.s.localSub,
              onTap: () => Navigator.pop(context, ImportType.local),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  const _TypeCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.focusNode});

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.select)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: SettingsThemeTokens.animDuration,
          width: 180,
          padding: const EdgeInsets.all(24),
          transform: Matrix4.identity()..scale(_focused ? 1.02 : 1.0),
          decoration: SettingsThemeTokens.cardDecoration(focused: _focused),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  size: 56, color: _focused ? AppTheme.accent : Colors.white54),
              const SizedBox(height: 20),
              Text(widget.title,
                  style: TextStyle(
                      color: _focused ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Text(widget.subtitle,
                  style: TextStyle(
                      color: _focused ? Colors.black54 : AppTheme.textMuted,
                      fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
