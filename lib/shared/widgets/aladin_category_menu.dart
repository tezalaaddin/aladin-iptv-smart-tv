import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/aladin_category_model.dart';
import '../../core/services/aladin_content_visibility_service.dart';
import '../../core/state/aladin_app_prefs.dart';
import '../../core/state/aladin_app_state.dart';
import '../theme/aladin_app_theme.dart';

class AladinCategoryMenuButton extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel? current;
  final ValueChanged<CategoryModel> onSelected;
  final VoidCallback? onShowAll;
  final VoidCallback? onManageHidden;
  final FocusNode? focusNode;

  const AladinCategoryMenuButton({
    super.key,
    required this.categories,
    required this.onSelected,
    this.current,
    this.onShowAll,
    this.onManageHidden,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Semantics(
      button: true,
      label: s.v51('openCategories'),
      child: OutlinedButton.icon(
        focusNode: focusNode,
        autofocus: true,
        onPressed: categories.isEmpty
            ? null
            : () => showAladinCategoryMenu(
                  context,
                  categories: categories,
                  current: current,
                  onSelected: onSelected,
                  onShowAll: onShowAll,
                  onManageHidden: onManageHidden,
                ),
        icon: const Icon(Icons.grid_view_rounded),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310),
          child: Text(current?.name ?? s.v51('allCategories'),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppTheme.accent),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        ),
      ),
    );
  }
}

Future<void> showAladinCategoryMenu(
  BuildContext context, {
  required List<CategoryModel> categories,
  required ValueChanged<CategoryModel> onSelected,
  CategoryModel? current,
  VoidCallback? onShowAll,
  VoidCallback? onManageHidden,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Categories',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => Align(
      alignment: Alignment.centerRight,
      child: _CategoryPanel(
        categories: categories,
        current: current,
        onSelected: onSelected,
        onShowAll: onShowAll,
        onManageHidden: onManageHidden,
      ),
    ),
    transitionBuilder: (_, animation, __, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    ),
  );
}

Future<void> showAladinHiddenContentManager(BuildContext context) async {
  final service = ContentVisibilityService.instance;
  final s = context.read<AppState>().s;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, update) {
        final entries = service.hiddenEntries;
        return AlertDialog(
          backgroundColor: AppTheme.card,
          title: Text(s.v50('showHidden')),
          content: SizedBox(
            width: 620,
            height: 420,
            child: entries.isEmpty
                ? Center(child: Text(s.v50('noHiddenContent')))
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
                            ? s.v50('hiddenCategory')
                            : s.v50('hiddenChannel')),
                        trailing: const Icon(Icons.visibility_outlined),
                        onTap: () async {
                          await service.show(entry);
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
                  await service.showAll();
                  update(() {});
                },
                child: Text(s.v50('showAll')),
              ),
            FilledButton(
              autofocus: entries.isEmpty,
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(s.close),
            ),
          ],
        );
      },
    ),
  );
}

class _CategoryPanel extends StatefulWidget {
  final List<CategoryModel> categories;
  final CategoryModel? current;
  final ValueChanged<CategoryModel> onSelected;
  final VoidCallback? onShowAll;
  final VoidCallback? onManageHidden;
  const _CategoryPanel({
    required this.categories,
    required this.current,
    required this.onSelected,
    this.onShowAll,
    this.onManageHidden,
  });

  @override
  State<_CategoryPanel> createState() => _CategoryPanelState();
}

class _CategoryPanelState extends State<_CategoryPanel> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  String _query = '';
  late Set<String> _pinned;
  late List<String> _recent;

  String get _scope {
    final first = widget.categories.first;
    return '${first.playlistId}_${first.contentType}';
  }

  String _key(CategoryModel category) => category.name.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _pinned = _readList('category_pins_v51_$_scope').toSet();
    _recent = _readList('category_recent_v51_$_scope');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _ordered.indexWhere((c) => c.id == widget.current?.id);
      if (index >= 0 && _scroll.hasClients) {
        _scroll
            .jumpTo((index * 64.0).clamp(0, _scroll.position.maxScrollExtent));
      }
    });
  }

  List<String> _readList(String key) {
    try {
      return (jsonDecode(AladinPrefs.instance.getString(key) ?? '[]') as List)
          .map((e) => '$e')
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<CategoryModel> get _ordered {
    final query = _query.trim().toLowerCase();
    final result = widget.categories
        .where((c) => query.isEmpty || c.name.toLowerCase().contains(query))
        .toList();
    int rank(CategoryModel c) {
      final key = _key(c);
      if (_pinned.contains(key)) return -10000;
      final recentIndex = _recent.indexOf(key);
      return recentIndex < 0 ? 10000 : recentIndex;
    }

    result.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0
          ? byRank
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return result;
  }

  Future<void> _select(CategoryModel category) async {
    final key = _key(category);
    _recent.remove(key);
    _recent.insert(0, key);
    if (_recent.length > 5) _recent.removeRange(5, _recent.length);
    await AladinPrefs.instance
        .setString('category_recent_v51_$_scope', jsonEncode(_recent));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onSelected(category);
  }

  Future<void> _togglePin(CategoryModel category) async {
    final key = _key(category);
    setState(() {
      if (!_pinned.remove(key)) _pinned.add(key);
    });
    await AladinPrefs.instance
        .setString('category_pins_v51_$_scope', jsonEncode(_pinned.toList()));
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final items = _ordered;
    return Material(
      color: AppTheme.surface,
      elevation: 24,
      child: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width.clamp(420, 510).toDouble(),
          height: double.infinity,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 16, 12),
              child: Row(children: [
                const Icon(Icons.grid_view_rounded, color: AppTheme.accent),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(s.v51('categories'),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800))),
                IconButton(
                    tooltip: s.close,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _search,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: s.v51('searchCategories'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
            ),
            if (widget.onShowAll != null)
              ListTile(
                leading: const Icon(Icons.apps, color: AppTheme.accent),
                title: Text(s.v51('allCategories')),
                onTap: () {
                  Navigator.pop(context);
                  widget.onShowAll!();
                },
              ),
            const Divider(height: 1),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text(s.noResultsFound))
                  : ListView.builder(
                      controller: _scroll,
                      itemCount: items.length,
                      itemExtent: 64,
                      itemBuilder: (context, index) {
                        final category = items[index];
                        final pinned = _pinned.contains(_key(category));
                        final selected = category.id == widget.current?.id;
                        return ListTile(
                          autofocus: selected ||
                              (widget.current == null && index == 0),
                          selected: selected,
                          selectedTileColor:
                              AppTheme.accent.withValues(alpha: 0.18),
                          leading: Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.folder_outlined,
                              color: selected
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary),
                          title: Text(category.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                              '${category.channelCount} ${s.v51('items')}'),
                          trailing: Icon(
                              pinned ? Icons.push_pin : Icons.push_pin_outlined,
                              color: pinned
                                  ? AppTheme.accent
                                  : AppTheme.textMuted),
                          onTap: () => _select(category),
                          onLongPress: () => _togglePin(category),
                        );
                      },
                    ),
            ),
            if (widget.onManageHidden != null ||
                ContentVisibilityService.instance.hiddenCount > 0)
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: Text(s.v51('manageHidden')),
                subtitle:
                    Text('${ContentVisibilityService.instance.hiddenCount}'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onManageHidden?.call();
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.v51('pinHint'),
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ),
          ]),
        ),
      ),
    );
  }
}
