import 'package:flutter/material.dart';

import '../../core/platform/aladin_device_profile.dart';
import '../theme/aladin_app_theme.dart';

/// Keeps section actions available on television, where [AladinAppBar] is
/// intentionally hidden to preserve vertical space.
class AladinSectionHeader extends StatelessWidget {
  const AladinSectionHeader({
    super.key,
    required this.categoryButton,
    required this.onSearch,
    required this.onRefresh,
    required this.searchTooltip,
    required this.refreshTooltip,
  });

  final Widget categoryButton;
  final VoidCallback onSearch;
  final VoidCallback onRefresh;
  final String searchTooltip;
  final String refreshTooltip;

  @override
  Widget build(BuildContext context) {
    final isTv = AladinDeviceProfile.of(context).isTelevision;
    return Row(
      children: [
        categoryButton,
        if (isTv) ...[
          const Spacer(),
          _SectionAction(
            icon: Icons.search,
            tooltip: searchTooltip,
            onPressed: onSearch,
          ),
          const SizedBox(width: 8),
          _SectionAction(
            icon: Icons.refresh,
            tooltip: refreshTooltip,
            onPressed: onRefresh,
          ),
        ],
      ],
    );
  }
}

class _SectionAction extends StatefulWidget {
  const _SectionAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_SectionAction> createState() => _SectionActionState();
}

class _SectionActionState extends State<_SectionAction> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) => Focus(
        onFocusChange: (value) => setState(() => _focused = value),
        child: IconButton.filled(
          tooltip: widget.tooltip,
          onPressed: widget.onPressed,
          style: IconButton.styleFrom(
            backgroundColor: _focused ? Colors.white : AppTheme.card,
            foregroundColor: _focused ? Colors.black : AppTheme.accent,
            side: BorderSide(
              color: _focused ? Colors.white : Colors.white12,
              width: 2,
            ),
          ),
          icon: Icon(widget.icon),
        ),
      );
}
