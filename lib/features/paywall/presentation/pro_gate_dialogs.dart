import 'package:flutter/material.dart';

import '../../../core/usage_quota_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/calm_widgets.dart';
import '../../../theme/colors.dart';
import 'paywall_screen.dart';

/// Shown when a free user hits their daily PDF report cap.
Future<void> showDailyCapDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<_GateAction>(
    context: context,
    barrierColor: CalmPalette.of(context).sheetScrim,
    builder: (ctx) => _GateDialog(
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
    barrierColor: CalmPalette.of(context).sheetScrim,
    builder: (ctx) => _GateDialog(
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
  const _GateDialog({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    return Dialog(
      backgroundColor: p.bg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: p.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                color: p.fg,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.36,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                color: p.muted,
                fontSize: 14,
                height: 1.5,
                letterSpacing: -0.07,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: CalmButton(
                    label: l10n.actionLater,
                    variant: CalmBtnVariant.ghost,
                    onPressed: () =>
                        Navigator.of(context).pop(_GateAction.later),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CalmButton(
                    label: l10n.actionUpgrade,
                    variant: CalmBtnVariant.primary,
                    onPressed: () =>
                        Navigator.of(context).pop(_GateAction.upgrade),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
