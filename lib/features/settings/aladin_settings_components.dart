part of 'aladin_settings_page.dart';

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
        /*
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _snack(s.v52('testingStreams'));
              final result =
                  await PlaylistService.instance.testSampleStreams(playlist.id);
              _snack(
                  'Test: ${result['tested']} · Sağlıklı: ${result['healthy']} · Hatalı: ${result['failed']}',
                  error: (result['failed'] ?? 0) > 0);
            },
            child: Text(context.read<AppState>().s.v52('controlledStreamTest')),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.close)),
        ], */
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
