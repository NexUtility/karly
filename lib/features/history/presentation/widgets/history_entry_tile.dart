import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/format.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../theme/calm_widgets.dart';
import '../../../../theme/colors.dart';
import '../../../calculator/data/category.dart';
import '../../../calculator/data/marketplaces.dart';
import '../../../calculator/presentation/marketplace_emoji.dart';
import '../../data/saved_calculation.dart';

/// Calm history row — flag tile · name + subline · net + margin.
/// Matches the prototype's `HistoryRow` layout, condensed for Flutter.
class HistoryEntryTile extends StatelessWidget {
  const HistoryEntryTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  final SavedCalculation entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final locale = Localizations.localeOf(context);

    final marketplace = defaultMarketplaces.firstWhere(
      (m) => m.id == entry.marketplaceId,
      orElse: () => defaultMarketplaces.last,
    );
    final category = Category.byId(entry.categoryId);
    final dateStr =
        DateFormat.MMMd(locale.toString()).format(entry.savedAt);

    final net = entry.result.netProfit;
    final color = entry.result.isLoss ? p.neg : p.pos;
    final subline = [
      marketplace.name,
      if (category != null) category.displayName(l10n),
      dateStr,
    ].join(' · ');

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, l10n),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: p.neg.withValues(alpha: 0.15),
        child: Icon(Icons.delete_rounded, color: p.neg),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: p.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.border),
              ),
              alignment: Alignment.center,
              child: Text(
                emojiFor(marketplace),
                style: const TextStyle(fontSize: 18, height: 1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.itemName ?? category?.displayName(l10n) ?? marketplace.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.07,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.subtle,
                      fontSize: 12,
                      letterSpacing: -0.06,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                CalmNum(
                  _signed(net, entry.inputs.currency),
                  color: color,
                  size: 14,
                ),
                const SizedBox(height: 2),
                CalmNum(
                  '${entry.result.marginPct >= 0 ? '+' : ''}${entry.result.marginPct.toStringAsFixed(1)}%',
                  color: p.subtle,
                  size: 12,
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _signed(double v, String ccy) {
    final base = formatCurrency(v.abs(), currency: ccy);
    return v >= 0 ? '+$base' : '−$base';
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: CalmPalette.of(context).sheetScrim,
      builder: (ctx) {
        final p = CalmPalette.of(ctx);
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
                  l10n.historyDeleteConfirmTitle,
                  style: TextStyle(
                    color: p.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.36,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.historyDeleteConfirmBody,
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
                        label: l10n.actionCancel,
                        variant: CalmBtnVariant.ghost,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CalmButton(
                        label: l10n.actionDelete,
                        variant: CalmBtnVariant.danger,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return ok ?? false;
  }
}
