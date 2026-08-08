import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/aladin_channel_model.dart';
import '../../core/services/aladin_channel_service.dart';
import '../../core/state/aladin_app_state.dart';
import '../../shared/theme/aladin_app_theme.dart';
import '../../shared/widgets/aladin_app_bar.dart';
import '../../shared/widgets/aladin_channel_card.dart';
import '../../shared/widgets/aladin_input_dialog.dart';
import '../../shared/widgets/aladin_channel_options.dart';
import '../player/aladin_player_page.dart';

class SearchPage extends StatefulWidget {
  final bool isActive;
  const SearchPage({super.key, this.isActive = false});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchFocusNode = FocusNode(debugLabel: 'search_field_focus');
  final _controller = TextEditingController();
  String _query = '';
  List<ChannelModel> _results = [];
  List<ChannelModel> _similarResults = [];
  bool _searching = false;
  Timer? _deb;
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _triggerFocus();
  }

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _triggerFocus();
  }

  void _triggerFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _controller.dispose();
    _deb?.cancel();
    super.dispose();
  }

  void _onChanged(String val) {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 500), () {
      setState(() => _query = val);
      _doSearch(val);
    });
  }

  void _clearSearch() {
    _searchGeneration++;
    _controller.clear();
    setState(() {
      _query = '';
      _results = [];
      _similarResults = [];
      _searching = false;
    });
    _searchFocusNode.requestFocus();
  }

  Future<void> _doSearch(String q) async {
    final generation = ++_searchGeneration;
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _similarResults = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    final active = context.read<AppState>().active;
    if (active == null) return;

    final r = await ChannelService.instance
        .search(playlistId: active.id, query: query);

    List<ChannelModel> similar = [];
    if (r.isEmpty) {
      similar = await ChannelService.instance
          .searchSimilar(playlistId: active.id, query: query);
    }

    if (mounted && generation == _searchGeneration)
      setState(() {
        _results = r;
        _similarResults = similar;
        _searching = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AladinAppBar(),
      body: Column(
        children: [
          // ⚡ ELITE SEARCH UX: Direct TextField for TV
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _searchFocusNode,
                    onChanged: _onChanged,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: s.searchHint,
                      prefixIcon:
                          const Icon(Icons.search, color: AppTheme.accent),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white54),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.card,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Voice Search Button
                _VoiceBtn(onResult: (val) {
                  _controller.text = val;
                  _onChanged(val);
                }),
              ],
            ),
          ),

          Expanded(
            child: FocusScope(
              child: _searching
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent))
                  : (_results.isEmpty && _similarResults.isEmpty)
                      ? _buildEmptyState(s)
                      : _buildResultGrid(s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultGrid(dynamic s) {
    final all = [..._results, ..._similarResults];
    final isSimilarOnly = _results.isEmpty && _similarResults.isNotEmpty;

    return CustomScrollView(
      slivers: [
        if (isSimilarOnly)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                'Benzer Seçenekler', // I should use s.similarOptions if exists
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: AppTheme.cardWidth + 40,
              mainAxisSpacing: 30,
              crossAxisSpacing: 20,
              mainAxisExtent: AppTheme.gridHeight,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final ch = all[i];
                return ChannelCard(
                  channel: ch,
                  onLongPress: () async {
                    final changed = await showAladinChannelOptions(context, ch);
                    if (changed && mounted) await _doSearch(_query);
                  },
                  onTap: () => _openResult(ch),
                );
              },
              childCount: all.length,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openResult(ChannelModel channel) async {
    final activePlaylist = context.read<AppState>().active;
    final playbackQueue =
        await ChannelService.instance.getPlaybackQueue(channel);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          channel: channel,
          playlist: playbackQueue,
          playlistModel: activePlaylist,
        ),
      ),
    );
  }

  Widget _buildEmptyState(dynamic s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.white10),
          const SizedBox(height: 24),
          Text(_query.isNotEmpty ? s.noResultsFound : s.typeToSearch,
              style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _VoiceBtn extends StatefulWidget {
  final ValueChanged<String> onResult;
  const _VoiceBtn({required this.onResult});

  @override
  State<_VoiceBtn> createState() => _VoiceBtnState();
}

class _VoiceBtnState extends State<_VoiceBtn> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>().s;
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          _openMic();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _openMic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _focused ? Colors.white : AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _focused ? Colors.white : Colors.white10, width: 2),
          ),
          child:
              Icon(Icons.mic, color: _focused ? Colors.black : AppTheme.accent),
        ),
      ),
    );
  }

  void _openMic() async {
    final state = context.read<AppState>();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AladinInputDialog(
        title: state.s.searchHint,
        icon: Icons.mic,
      ),
    );
    if (result != null) widget.onResult(result);
  }
}
