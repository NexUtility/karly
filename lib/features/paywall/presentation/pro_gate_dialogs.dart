import 'package:flutter/material.dart';

import '../../../core/usage_quota_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/colors.dart';
import 'paywall_screen.dart';

/// Shown when a free user hits their daily PDF report cap.
Future<void> showDailyCapDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<_GateAction>(
    context: context,
    builder: (ctx) => _GateDialog(
      icon: Icons.workspace_premium_rounded,
      title: l10n.dailyCapTitle,
      body: l10n.dailyCapBody(kDailyFreeReportCap),
    ),
  );
  if (result == _GateAction.upgrade && context.mounted) {
    await openPaywall(context);
  }
}

/// Shown when a free user taps the "Save to History" button.
Future<void> showSaveProGateDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<_GateAction>(
    context: context,
    builder: (ctx) => _GateDialog(
      icon: Icons.bookmark_added_rounded,
      title: l10n.saveProGateTitle,
      body: l10n.saveProGateBody,
    ),
  );
  if (result == _GateAction.upgrade && context.mounted) {
    await openPaywall(context);
  }
}

enum _GateAction { upgrade, later }

class _GateDialog extends StatelessWidget {
  const _GateDialog({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BrandColors.accent, Color(0xFF8FCB12)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 24, color: BrandColors.accentForeground),
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(
        body,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_GateAction.later),
          child: Text(l10n.actionLater),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_GateAction.upgrade),
          child: Text(l10n.actionUpgrade),
        ),
      ],
    );
  }
}
