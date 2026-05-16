import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'l10n/generated/app_localizations.dart';
import 'theme/colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _routes = ['/', '/history', '/settings'];

  int get _index {
    final i = _routes.indexWhere(
      (r) => r == '/' ? location == '/' : location.startsWith(r),
    );
    return i < 0 ? 0 : i;
  }

  void _onTap(BuildContext context, int index) {
    if (index == _index) return;
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final tabs = [
      _TabData(
        icon: const _CalcIcon(),
        label: l10n.navCalculator,
      ),
      _TabData(
        icon: const _HistoryIcon(),
        label: l10n.navHistory,
      ),
      _TabData(
        icon: const _SettingsIcon(),
        label: l10n.navSettings,
      ),
    ];
    return Scaffold(
      backgroundColor: p.bg,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: p.bg,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _CalmTab(
                    data: tabs[i],
                    active: i == _index,
                    onTap: () => _onTap(context, i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabData {
  const _TabData({required this.icon, required this.label});
  final Widget icon;
  final String label;
}

class _CalmTab extends StatelessWidget {
  const _CalmTab({
    required this.data,
    required this.active,
    required this.onTap,
  });

  final _TabData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    final color = active ? p.fg : p.subtle;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(color: color, size: 22),
              child: data.icon,
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.06,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: active ? p.fg : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcIcon extends StatelessWidget {
  const _CalcIcon();
  @override
  Widget build(BuildContext context) => const Icon(Icons.calculate_outlined);
}

class _HistoryIcon extends StatelessWidget {
  const _HistoryIcon();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.access_time_rounded);
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.settings_outlined);
}
