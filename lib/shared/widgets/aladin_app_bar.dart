import 'package:flutter/material.dart';
import '../../core/platform/aladin_device_profile.dart';
import 'package:provider/provider.dart';
import '../../core/state/aladin_app_state.dart';
import '../theme/aladin_app_theme.dart';

/// Simplified branded app bar — left: aladin IPTV logo, right: refresh
class AladinAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onRefresh;
  final VoidCallback? onSearch;
  final List<Widget>? extraActions;
  final PreferredSizeWidget? bottom;

  const AladinAppBar({
    super.key,
    this.title,
    this.onRefresh,
    this.onSearch,
    this.extraActions,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(48 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final isLandscape = AladinDeviceProfile.of(context).isTelevision;
    if (isLandscape) return const SizedBox.shrink();

    final s = context.read<AppState>().s;
    final double safePadding = MediaQuery.of(context).size.width * 0.05;

    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      automaticallyImplyLeading: Navigator.canPop(context),
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: safePadding),
        child: Row(
          children: [
            // Branded Breadcrumb
            Image.asset(
              'assets/images/app_logo_text_transparent.png',
              width: 150,
              height: 42,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              semanticLabel: 'aladin IPTV Player Pro TV',
            ),
            const SizedBox(width: 12),
            Text(
              title ?? s.navHome,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // Butonlar
            if (extraActions != null) ...extraActions!,
            if (onSearch != null)
              _AppBarButton(
                icon: Icons.search,
                tooltip: s.navSearch,
                onPressed: onSearch!,
              ),
            if (onRefresh != null)
              _AppBarButton(
                icon: Icons.refresh,
                tooltip: s.retry,
                onPressed: onRefresh!,
              ),
          ],
        ),
      ),
      bottom: bottom ??
          PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppTheme.divider)),
    );
  }
}

/// TV kumandası için odaklanabilir AppBar butonu
class _AppBarButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  const _AppBarButton(
      {required this.icon, required this.onPressed, this.tooltip});

  @override
  State<_AppBarButton> createState() => _AppBarButtonState();
}

class _AppBarButtonState extends State<_AppBarButton> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: IconButton(
        tooltip: widget.tooltip,
        icon: Icon(widget.icon,
            color: _focused ? AppTheme.accent : AppTheme.textSecondary,
            size: 22),
        onPressed: widget.onPressed,
      ),
    );
  }
}
