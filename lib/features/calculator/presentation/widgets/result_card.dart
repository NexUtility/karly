import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../theme/colors.dart';
import '../../domain/calculate.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.result,
    required this.currency,
  });

  final CalcResult result;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loss = result.isLoss;
    final headlineColor = loss ? BrandColors.danger : theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.resultNetProfit, style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            Text(
              formatCurrency(result.netProfit, currency: currency),
              style: theme.textTheme.displayLarge?.copyWith(
                color: headlineColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _pill(
                  context,
                  '${l10n.resultMargin} ${formatPercent(result.marginPct)}',
                ),
                _pill(
                  context,
                  '${l10n.resultROI} ${formatPercent(result.roiPct)}',
                ),
              ],
            ),
            if (loss) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: BrandColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: BrandColors.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: BrandColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.resultLossWarning,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: BrandColors.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 14),
            _row(
              context,
              l10n.resultCommission,
              formatCurrency(result.commissionAmount, currency: currency),
            ),
            _row(
              context,
              l10n.resultVat,
              formatCurrency(result.vatAmount, currency: currency),
            ),
            _row(
              context,
              l10n.resultBreakeven,
              formatCurrency(result.breakevenPrice, currency: currency),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
