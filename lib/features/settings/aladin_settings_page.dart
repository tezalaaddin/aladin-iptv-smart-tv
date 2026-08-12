import 'package:flutter/material.dart';
import '../../core/platform/aladin_device_profile.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/models/aladin_playlist_model.dart';
import '../../../core/services/aladin_playlist_service.dart';
import '../../../core/services/aladin_update_service.dart';
import '../../../core/services/aladin_parental_service.dart';
import '../../../core/services/aladin_content_visibility_service.dart';
import '../../core/services/aladin_epg_engine.dart';
import '../../../core/state/aladin_app_prefs.dart';
import '../../../core/state/aladin_app_state.dart';
import '../../../core/state/aladin_app_strings.dart';
import '../../../shared/theme/aladin_app_theme.dart';
import '../../../shared/widgets/aladin_input_dialog.dart';
import '../../../shared/widgets/aladin_folder_explorer.dart';

part 'aladin_settings_components.dart';

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
      List.generate(15, (i) => FocusNode(debugLabel: 'left_$i'));
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

    // Never reinterpret editing keys (especially Backspace) as TV navigation
    // while an EditableText owns focus. This also protects physical keyboards
    // attached to Android TV devices.
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    final editingText = focusedContext != null &&
        (focusedContext.widget is EditableText ||
            focusedContext.findAncestorWidgetOfExactType<EditableText>() !=
                null);
    if (editingText) return KeyEventResult.ignored;

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

  Future<void> _showPlaybackPreferences() async {
    final s = context.read<AppState>().s;
    final current = AladinPrefs.instance.getString('buffer_profile') ?? 'auto';
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.v52('playbackBuffer')),
        children: {
          'auto': s.v52('bufferAuto'),
          'low_latency': s.v52('bufferLowLatency'),
          'balanced': s.v52('bufferBalanced'),
          'stable': s.v52('bufferStable'),
          'travel': s.v52('bufferTravel'),
        }
            .entries
            .map((entry) => RadioListTile<String>(
                  value: entry.key,
                  groupValue: current,
                  title: Text(entry.value),
                  onChanged: (value) => Navigator.pop(ctx, value),
                ))
            .toList(),
      ),
    );
    if (selected != null) {
      await AladinPrefs.instance.setString('buffer_profile', selected);
    }
    if (mounted) setState(() {});
  }

  String _bufferProfileLabel(AppStrings s) {
    final profile = AladinPrefs.instance.getString('buffer_profile') ?? 'auto';
    return switch (profile) {
      'low_latency' => s.v52('bufferLowLatency'),
      'balanced' => s.v52('bufferBalanced'),
      'stable' => s.v52('bufferStable'),
      'travel' => s.v52('bufferTravel'),
      _ => s.v52('bufferAuto'),
    };
  }

  Future<void> _showCardDensityPreferences() async {
    final s = context.read<AppState>().s;
    final current =
        AladinPrefs.instance.getString('tv_card_density') ?? 'compact';
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppTheme.card,
        title: Text(s.v52('cardDensity')),
        children: {
          'compact': s.v52('cardCompact'),
          'standard': s.v52('cardStandard'),
          'large': s.v52('cardLarge'),
        }
            .entries
            .map((entry) => RadioListTile<String>(
                  value: entry.key,
                  groupValue: current,
                  title: Text(entry.value),
                  onChanged: (value) => Navigator.pop(ctx, value),
                ))
            .toList(),
      ),
    );
    if (selected != null) {
      await AladinPrefs.instance.setString('tv_card_density', selected);
    }
    if (mounted) setState(() {});
  }

  String _cardDensityLabel(AppStrings s) =>
      switch (AladinPrefs.instance.getString('tv_card_density')) {
        'standard' => s.v52('cardStandard'),
        'large' => s.v52('cardLarge'),
        _ => s.v52('cardCompact'),
      };

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
    final isTV = AladinDeviceProfile.of(context).isTelevision;

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
                          icon: Icons.lock_person,
                          title: s.v49('parental'),
                          subtitle: ParentalService.instance.isEnabled
                              ? '${s.v52('enabled')} · ${s.v52('parentalEnabledSub')}'
                              : '${s.v52('disabled')} · ${s.v52('parentalDisabledSub')}',
                          onTap: _showParentalDialog,
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 7;
                              });
                            _ensureVisible(_leftNodes[7]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[8],
                          icon: Icons.format_size,
                          title: s.v49('largeText'),
                          subtitle: AladinPrefs.instance
                                  .getBool('accessibility_large_text')
                              ? '${s.v52('enabled')} · ${s.v52('largeTextEnabledSub')}'
                              : s.v52('standardText'),
                          onTap: () async {
                            final value = AladinPrefs.instance
                                .getBool('accessibility_large_text');
                            await AladinPrefs.instance
                                .setBool('accessibility_large_text', !value);
                            setState(() {});
                          },
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 8;
                              });
                            _ensureVisible(_leftNodes[8]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[9],
                          icon: Icons.contrast,
                          title: s.v49('highContrast'),
                          subtitle: AladinPrefs.instance
                                  .getBool('accessibility_high_contrast')
                              ? '${s.v52('enabled')} · ${s.v52('highContrastEnabledSub')}'
                              : s.v52('standardContrast'),
                          onTap: () async {
                            final value = AladinPrefs.instance
                                .getBool('accessibility_high_contrast');
                            await AladinPrefs.instance
                                .setBool('accessibility_high_contrast', !value);
                            setState(() {});
                          },
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 9;
                              });
                            _ensureVisible(_leftNodes[9]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[10],
                          icon: Icons.speed,
                          title: s.v49('frameRate'),
                          subtitle: AladinPrefs.instance
                                  .getBool('match_content_frame_rate')
                              ? '${s.v52('enabled')} · ${s.v52('frameRateEnabledSub')}'
                              : s.v52('disabled'),
                          onTap: () async {
                            final value = AladinPrefs.instance
                                .getBool('match_content_frame_rate');
                            await AladinPrefs.instance
                                .setBool('match_content_frame_rate', !value);
                            setState(() {});
                          },
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 10;
                              });
                            _ensureVisible(_leftNodes[10]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[11],
                          icon: Icons.network_check,
                          title: s.v52('bufferProfile'),
                          subtitle: _bufferProfileLabel(s),
                          onTap: _showPlaybackPreferences,
                          onFocus: (v) {
                            if (v) setState(() => _leftFocusedIndex = 11);
                            _ensureVisible(_leftNodes[11]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[12],
                          icon: Icons.view_module_outlined,
                          title: s.v52('cardDensity'),
                          subtitle: _cardDensityLabel(s),
                          onTap: _showCardDensityPreferences,
                          onFocus: (v) {
                            if (v) setState(() => _leftFocusedIndex = 12);
                            _ensureVisible(_leftNodes[12]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[13],
                          icon: Icons.skip_next,
                          title: s.v52('autoPlayNext'),
                          subtitle: AladinPrefs.instance
                                  .getBool('auto_play_next_episode', def: true)
                              ? s.v52('enabled')
                              : s.v52('disabled'),
                          onTap: () async {
                            final value = AladinPrefs.instance
                                .getBool('auto_play_next_episode', def: true);
                            await AladinPrefs.instance
                                .setBool('auto_play_next_episode', !value);
                            setState(() {});
                          },
                          onFocus: (v) {
                            if (v) setState(() => _leftFocusedIndex = 13);
                            _ensureVisible(_leftNodes[13]);
                          },
                        ),
                        _SetupTile(
                          focusNode: _leftNodes[14],
                          icon: Icons.info_outline,
                          title: s.about,
                          subtitle:
                              '${s.version} ${_packageInfo?.version ?? '...'} (${_packageInfo?.buildNumber ?? ''})',
                          onTap: () => _showAboutDialog(s),
                          onFocus: (v) {
                            if (v)
                              setState(() {
                                _inLeftPanel = true;
                                _leftFocusedIndex = 14;
                              });
                            _ensureVisible(_leftNodes[14]);
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
                  icon: Icons.lock_person,
                  title: s.v49('parental'),
                  subtitle: ParentalService.instance.isEnabled
                      ? '${s.v52('enabled')} · ${s.v52('parentalEnabledSub')}'
                      : '${s.v52('disabled')} · ${s.v52('parentalDisabledSub')}',
                  onTap: _showParentalDialog,
                ),
                _SetupTile(
                  icon: Icons.format_size,
                  title: s.v49('largeText'),
                  subtitle: AladinPrefs.instance
                          .getBool('accessibility_large_text')
                      ? '${s.v52('enabled')} · ${s.v52('largeTextEnabledSub')}'
                      : s.v52('standardText'),
                  onTap: () async {
                    final value = AladinPrefs.instance
                        .getBool('accessibility_large_text');
                    await AladinPrefs.instance
                        .setBool('accessibility_large_text', !value);
                    if (mounted) setState(() {});
                  },
                ),
                _SetupTile(
                  icon: Icons.contrast,
                  title: s.v49('highContrast'),
                  subtitle: AladinPrefs.instance
                          .getBool('accessibility_high_contrast')
                      ? '${s.v52('enabled')} · ${s.v52('highContrastEnabledSub')}'
                      : s.v52('standardContrast'),
                  onTap: () async {
                    final value = AladinPrefs.instance
                        .getBool('accessibility_high_contrast');
                    await AladinPrefs.instance
                        .setBool('accessibility_high_contrast', !value);
                    if (mounted) setState(() {});
                  },
                ),
                _SetupTile(
                  icon: Icons.speed,
                  title: s.v49('frameRate'),
                  subtitle: AladinPrefs.instance
                          .getBool('match_content_frame_rate')
                      ? '${s.v52('enabled')} · ${s.v52('frameRateEnabledSub')}'
                      : s.v52('disabled'),
                  onTap: () async {
                    final value = AladinPrefs.instance
                        .getBool('match_content_frame_rate');
                    await AladinPrefs.instance
                        .setBool('match_content_frame_rate', !value);
                    if (mounted) setState(() {});
                  },
                ),
                _SetupTile(
                  icon: Icons.network_check,
                  title: s.v52('bufferProfile'),
                  subtitle: _bufferProfileLabel(s),
                  onTap: _showPlaybackPreferences,
                ),
                _SetupTile(
                  icon: Icons.skip_next,
                  title: s.v52('autoPlayNext'),
                  subtitle: AladinPrefs.instance
                          .getBool('auto_play_next_episode', def: true)
                      ? s.v52('enabled')
                      : s.v52('disabled'),
                  onTap: () async {
                    final value = AladinPrefs.instance
                        .getBool('auto_play_next_episode', def: true);
                    await AladinPrefs.instance
                        .setBool('auto_play_next_episode', !value);
                    if (mounted) setState(() {});
                  },
                ),
                _SetupTile(
                  icon: Icons.view_module_outlined,
                  title: s.v52('cardDensity'),
                  subtitle: _cardDensityLabel(s),
                  onTap: _showCardDensityPreferences,
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
              _showPlaylistHealth(p);
            },
            child: Row(children: [
              const Icon(Icons.monitor_heart_outlined,
                  color: Colors.lightBlueAccent),
              const SizedBox(width: 12),
              Text(s.v49('healthReport'))
            ]),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              _snack(s.v52('testingStreams'));
              final result =
                  await PlaylistService.instance.testSampleStreams(p.id);
              _snack(
                  'Test: ${result['tested']} · Sağlıklı: ${result['healthy']} · Hatalı: ${result['failed']}',
                  error: (result['failed'] ?? 0) > 0);
            },
            child: Row(children: [
              const Icon(Icons.speed_outlined, color: Colors.orangeAccent),
              const SizedBox(width: 12),
              Text(s.v52('controlledStreamTest'))
            ]),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              final backup = await PlaylistService.instance.exportAppBackup();
              await Clipboard.setData(ClipboardData(text: backup));
              _snack('Güvenli yedek panoya kopyalandı (Xtream şifresi hariç).');
            },
            child: Row(children: [
              const Icon(Icons.backup_outlined, color: Colors.white70),
              const SizedBox(width: 12),
              Text(s.v49('secureBackup'))
            ]),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _exportEncryptedBackup();
            },
            child: Row(children: [
              const Icon(Icons.enhanced_encryption, color: Colors.greenAccent),
              const SizedBox(width: 12),
              Text(s.v49('encryptedExport'))
            ]),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _importEncryptedBackup(state);
            },
            child: Row(children: [
              const Icon(Icons.settings_backup_restore,
                  color: Colors.greenAccent),
              const SizedBox(width: 12),
              Text(s.v49('encryptedImport'))
            ]),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              final raw = data?.text?.trim() ?? '';
              if (raw.isEmpty) {
                _snack('Panoda yedek verisi bulunamadı.', error: true);
                return;
              }
              try {
                await PlaylistService.instance.importAppBackup(raw);
                await state.refresh();
                _snack('Yedek ayarları ve izleme verileri geri yüklendi.');
              } catch (e) {
                _snack('Yedek geri yüklenemedi: $e', error: true);
              }
            },
            child: Row(children: [
              const Icon(Icons.restore, color: Colors.white70),
              const SizedBox(width: 12),
              Text(s.v49('restoreBackup'))
            ]),
          ),
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

  Future<void> _showPlaylistHealth(PlaylistModel playlist) async {
    final strings = context.read<AppState>().s;
    final report = await PlaylistService.instance.getHealthReport(playlist.id);
    final xtream = await PlaylistService.instance.getXtreamHealth(playlist);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('${playlist.name} · ${strings.v49('healthReport')}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _healthRow(strings.v52('totalContent'), report['total']!),
              _healthRow(strings.v52('emptyStreamUrl'), report['emptyUrl']!),
              _healthRow(
                  strings.v52('duplicateStreamUrl'), report['duplicates']!),
              _healthRow(
                  strings.v52('missingArtwork'), report['missingArtwork']!),
              _healthRow(strings.v52('missingEpgId'), report['missingEpgId']!),
              if (xtream != null) ...[
                const Divider(),
                ListTile(
                    dense: true,
                    title: Text(strings.v49('serverLatency')),
                    trailing: Text('${xtream['latencyMs']} ms')),
                ListTile(
                    dense: true,
                    title: Text(strings.v49('accountStatus')),
                    trailing: Text('${xtream['status']}')),
                ListTile(
                    dense: true,
                    title: Text(strings.v52('connectionUsage')),
                    trailing: Text(
                        '${xtream['activeConnections']} / ${xtream['maxConnections']}')),
                ListTile(
                    dense: true,
                    title: Text(strings.v49('subscriptionExpiry')),
                    trailing: Text('${xtream['expiry']}')),
              ],
              const SizedBox(height: 12),
              Text(
                strings.v52('healthNote'),
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.pop(context),
            child: Text(strings.done),
          ),
        ],
      ),
    );
  }

  Future<String?> _requestBackupPassword(String title) => showDialog<String>(
        context: context,
        builder: (_) => AladinInputDialog(
          title: title,
          hint: 'En az 6 karakter',
          obscure: true,
        ),
      );

  Future<void> _exportEncryptedBackup() async {
    final password = await _requestBackupPassword('Yedek parolası');
    if (password == null) return;
    try {
      final bytes =
          await PlaylistService.instance.exportEncryptedBackup(password);
      await FilePicker.platform.saveFile(
        dialogTitle: 'Şifreli Aladin yedeğini kaydet',
        fileName:
            'aladin-backup-${DateTime.now().millisecondsSinceEpoch}.aladin',
        bytes: bytes,
      );
      _snack('Şifreli yedek dosyası hazırlandı.');
    } catch (e) {
      _snack('Yedek oluşturulamadı: $e', error: true);
    }
  }

  Future<void> _importEncryptedBackup(AppState state) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['aladin'],
      withData: true,
    );
    final bytes = picked?.files.single.bytes;
    if (bytes == null || !mounted) return;
    final password = await _requestBackupPassword('Yedek parolası');
    if (password == null) return;
    try {
      await PlaylistService.instance.importEncryptedBackup(bytes, password);
      await state.refresh();
      _snack('Şifreli yedek geri yüklendi.');
    } catch (e) {
      _snack('Parola yanlış veya yedek bozuk.', error: true);
    }
  }

  Widget _healthRow(String label, int value) => ListTile(
        dense: true,
        title: Text(label),
        trailing: Text('$value',
            style: const TextStyle(
                color: AppTheme.accent, fontWeight: FontWeight.bold)),
      );

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

  Future<String?> _requestPin(String title) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(title),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: context.read<AppState>().s.v52('pinInput'),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.pop(dialogContext, value),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.read<AppState>().s.cancel),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(context.read<AppState>().s.v52('confirm')),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<bool> _authenticateParental() async {
    final service = ParentalService.instance;
    if (!await service.hasPin()) return true;
    final strings = context.read<AppState>().s;
    final pin = await _requestPin(strings.v52('parentalPin'));
    if (pin == null) return false;
    final valid = await service.verifyPin(pin);
    if (!valid) _snack(strings.v52('invalidPin'), error: true);
    return valid;
  }

  Future<void> _setNewParentalPin() async {
    final strings = context.read<AppState>().s;
    final first = await _requestPin(strings.v52('newParentalPin'));
    if (first == null) return;
    if (!RegExp(r'^\d{4,6}$').hasMatch(first)) {
      _snack(strings.v52('pinLengthError'), error: true);
      return;
    }
    final second = await _requestPin(strings.v52('verifyPin'));
    if (first != second) {
      _snack(strings.v52('pinMismatch'), error: true);
      return;
    }
    await ParentalService.instance.setPin(first);
    _snack(strings.v52('pinSaved'));
  }

  Future<void> _showParentalDialog() async {
    final service = ParentalService.instance;
    final strings = context.read<AppState>().s;
    if (!await _authenticateParental()) return;
    if (!await service.hasPin()) await _setNewParentalPin();
    if (!await service.hasPin() || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: AppTheme.card,
          title: Text(strings.v49('parental')),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  autofocus: true,
                  title: Text(strings.v49('pinProtection')),
                  subtitle: Text(strings.v52('pinProtectionSub')),
                  value: service.isEnabled,
                  onChanged: (value) async {
                    await service.setEnabled(value);
                    update(() {});
                    if (mounted) setState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(strings.v49('hideLocked')),
                  subtitle: Text(strings.v52('hideLockedSub')),
                  value: service.hideLockedContent,
                  onChanged: (value) async {
                    await service.setHideLockedContent(value);
                    update(() {});
                  },
                ),
                ListTile(
                  title: Text(strings.v49('unlockDuration')),
                  subtitle: Text(strings
                      .v52('minutes')
                      .replaceAll('{value}', '${service.sessionMinutes}')),
                  trailing: DropdownButton<int>(
                    value: service.sessionMinutes,
                    items: const [15, 30, 60]
                        .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(strings
                                .v52('minutes')
                                .replaceAll('{value}', '$v'))))
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      await service.setSessionMinutes(value);
                      update(() {});
                    },
                  ),
                ),
                ListTile(
                  title: Text(strings.v49('manageLocked')),
                  subtitle: Text(strings.v52('manualLockedCount').replaceAll(
                      '{count}', '${service.lockedContent.length}')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _showLockedContentManager();
                  },
                ),
                ListTile(
                  title: Text(strings.v49('showHidden')),
                  subtitle: Text(strings.v52('hiddenCount').replaceAll(
                      '{count}',
                      '${ContentVisibilityService.instance.hiddenCount}')),
                  trailing: const Icon(Icons.visibility),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _showHiddenContentManager();
                  },
                ),
                ListTile(
                  title: Text(strings.v49('changePin')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _setNewParentalPin();
                  },
                ),
                ListTile(
                  title: Text(strings.v49('lockNow')),
                  subtitle: Text(strings.v52('lockNowSub')),
                  trailing: const Icon(Icons.lock),
                  onTap: () {
                    service.lockSession();
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              autofocus: true,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.done),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLockedContentManager() async {
    final service = ParentalService.instance;
    final strings = context.read<AppState>().s;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) {
          final entries = service.lockedContent;
          return AlertDialog(
            backgroundColor: AppTheme.card,
            title: Text(strings.v49('lockedContent')),
            content: SizedBox(
              width: 620,
              height: 420,
              child: entries.isEmpty
                  ? Center(child: Text(strings.v49('noManualLocks')))
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return ListTile(
                          autofocus: index == 0,
                          leading: Icon(entry.isCategory
                              ? Icons.folder_off_outlined
                              : Icons.lock_outline),
                          title: Text(entry.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(entry.isCategory
                              ? strings.category
                              : entry.subtitle),
                          trailing: const Icon(Icons.lock_open),
                          onTap: () async {
                            await service.unlockEntry(entry);
                            update(() {});
                          },
                        );
                      },
                    ),
            ),
            actions: [
              FilledButton(
                autofocus: entries.isEmpty,
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(strings.done),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showHiddenContentManager() async {
    final visibility = ContentVisibilityService.instance;
    final strings = context.read<AppState>().s;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) {
          final entries = visibility.hiddenEntries;
          return AlertDialog(
            backgroundColor: AppTheme.card,
            title: Text(strings.v49('showHidden')),
            content: SizedBox(
              width: 620,
              height: 420,
              child: entries.isEmpty
                  ? Center(child: Text(strings.v50('noHiddenContent')))
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return ListTile(
                          autofocus: index == 0,
                          leading: Icon(entry.isCategory
                              ? Icons.folder_outlined
                              : Icons.live_tv_outlined),
                          title: Text(entry.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(entry.isCategory
                              ? strings.v50('hiddenCategory')
                              : strings.v50('hiddenChannel')),
                          trailing: const Icon(Icons.visibility_outlined),
                          onTap: () async {
                            await visibility.show(entry);
                            update(() {});
                          },
                        );
                      },
                    ),
            ),
            actions: [
              if (entries.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await visibility.showAll();
                    update(() {});
                  },
                  child: Text(strings.v50('showAll')),
                ),
              FilledButton(
                autofocus: entries.isEmpty,
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(strings.close),
              ),
            ],
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _showAboutDialog(AppStrings s) async {
    Map<dynamic, dynamic> tvStatus = const {};
    try {
      tvStatus = await const MethodChannel('aladin/exoplayer')
              .invokeMapMethod<dynamic, dynamic>('getTvIntegrationStatus') ??
          const {};
    } catch (_) {}
    if (!mounted) return;
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tv, color: AppTheme.accent),
              title: Text(s.v50('watchNextStatus')),
              subtitle: Text(tvStatus['watchNextEnabled'] == true
                  ? s.v50('watchNextEnabled')
                  : s.v50('watchNextUnavailable')),
              trailing: tvStatus['permissionRejected'] == true
                  ? TextButton(
                      onPressed: () async {
                        await const MethodChannel('aladin/exoplayer')
                            .invokeMethod('retryWatchNext');
                        if (context.mounted) Navigator.pop(context);
                        _showAboutDialog(s);
                      },
                      child: Text(s.retry),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
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
