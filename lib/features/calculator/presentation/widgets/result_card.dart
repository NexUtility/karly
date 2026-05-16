import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../theme/colors.dart';
import '../../data/marketplace.dart';
import '../../domain/calculate.dart';
import '../../domain/inputs.dart';

/// Calm result card — colored hero with the headline number, a row of
/// metric figures (margin / ROI / breakeven), and a plain-language
/// breakdown beneath. Mirrors the layout in `prototype-calm/result.jsx`,
/// flattened from a full route into a card so the existing calculator
/// flow (form ↑, result ↓) keeps working.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.result,
    required this.inputs,
    required this.marketplace,
    this.onCompare,
  });

  final CalcResult result;
  final CalcInputs inputs;
  final Marketplace marketplace;

  /// Tapping the hero "Compare" chip or the bottom "Would it be better
  /// on Etsy?" panel fires this. The calculator owns the navigation
  /// and the marketplace-swap that follows.
  final VoidCallback? onCompare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final ccy = marketplace.defaultCurrency;
    final loss = result.isLoss;
    final heroBg = loss ? p.neg : p.accent;
    final heroFg = loss
        ? const Color(0xFFFFFFFF)
        : p.accentFg;

    final commissionPct = (inputs.commissionRate * 100);
    final vatPct = (inputs.vatRate * 100);

    final rows = <_BreakdownRow>[
      _BreakdownRow(
        label: l10n.resultRowYouSellFor,
        value: formatCurrency(inputs.sellPrice, currency: ccy),
        bold: true,
      ),
      _BreakdownRow(
        label: l10n.resultRowMarketplaceTakes(
          marketplace.name,
          commissionPct.toStringAsFixed(1),
        ),
        value: formatCurrency(result.commissionAmount, currency: ccy),
        sign: '−',
      ),
      if (vatPct > 0)
        _BreakdownRow(
          label: l10n.resultRowVat(vatPct.toStringAsFixed(0)),
          value: formatCurrency(result.vatAmount, currency: ccy),
          sign: '−',
        ),
      _BreakdownRow(
        label: l10n.resultRowWhatYouPaid,
        value: formatCurrency(inputs.itemCost, currency: ccy),
        sign: '−',
      ),
      if (inputs.shippingCost > 0)
        _BreakdownRow(
          label: l10n.resultRowShipping,
          value: formatCurrency(inputs.shippingCost, currency: ccy),
          sign: '−',
        ),
      if (inputs.operationalCosts > 0)
        _BreakdownRow(
          label: l10n.resultRowAdsPackaging,
          value: formatCurrency(inputs.operationalCosts, currency: ccy),
          sign: '−',
        ),
      if (inputs.fixedListingFee > 0)
        _BreakdownRow(
          label: l10n.resultRowListingFee,
          value: formatCurrency(inputs.fixedListingFee, currency: ccy),
          sign: '−',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HERO
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: heroBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loss ? l10n.resultYouLose : l10n.resultYouKeep,
                    style: TextStyle(
                      color: heroFg.withValues(alpha: 0.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.065,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _HeadlineNumber(
                    value: result.netProfit.abs(),
                    currency: ccy,
                    color: heroFg,
                  ),
                  if (loss) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x2EFFFFFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: heroFg,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.resultLossPill,
                            style: TextStyle(
                              color: heroFg,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.065,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  _MetricRow(
                    fg: heroFg,
                    items: [
                      (label: l10n.resultMargin, value: formatPercent(result.marginPct)),
                      (label: l10n.resultROI, value: formatPercent(result.roiPct)),
                      (
                        label: l10n.resultBreakeven,
                        value: result.breakevenPrice.isFinite
                            ? formatCurrency(
                                result.breakevenPrice,
                                currency: ccy,
                              )
                            : '∞',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onCompare != null)
              Positioned(
                top: 16,
                right: 16,
                child: Material(
                  color: const Color(0x1F000000),
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: onCompare,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart_rounded, size: 13, color: heroFg),
                          const SizedBox(width: 6),
                          Text(
                            l10n.compareHeroChip,
                            style: TextStyle(
                              color: heroFg,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.06,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 18),

        // BREAKDOWN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  l10n.resultBreakdownHeader,
                  style: TextStyle(
                    color: p.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.065,
                  ),
                ),
              ),
              for (var i = 0; i < rows.length; i++)
                _BreakdownRowView(
                  row: rows[i],
                  isLast: i == rows.length - 1,
                ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: p.borderHi, width: 1.5),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        loss
                            ? l10n.resultRowNetLoss
                            : l10n.resultRowNetProfit,
                        style: TextStyle(
                          color: p.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.15,
                        ),
                      ),
                    ),
                    Text(
                      _signed(formatCurrency(result.netProfit, currency: ccy),
                          result.netProfit),
                      style: TextStyle(
                        color: loss ? p.neg : p.pos,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -0.085,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Compare suggestion CTA — quiet panel, opens Compare
        if (onCompare != null) ...[
          const SizedBox(height: 14),
          _CompareEntry(onTap: onCompare!),
        ],
      ],
    );
  }

  String _signed(String formatted, double value) {
    if (value >= 0 && !formatted.startsWith('+')) return '+ $formatted';
    if (value < 0) {
      // formatCurrency may already emit a minus or parentheses; normalize
      final trimmed = formatted.replaceAll('-', '');
      return '− ${trimmed.trim()}';
    }
    return formatted;
  }
}

class _BreakdownRow {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.sign = '',
    this.bold = false,
  });

  final String label;
  final String value;
  final String sign;
  final bool bold;
}

class _BreakdownRowView extends StatelessWidget {
  const _BreakdownRowView({required this.row, required this.isLast});

  final _BreakdownRow row;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: p.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              row.label,
              style: TextStyle(
                color: row.bold ? p.fg : p.muted,
                fontSize: 14,
                fontWeight: row.bold ? FontWeight.w500 : FontWeight.w400,
                letterSpacing: -0.065,
              ),
            ),
          ),
          if (row.sign.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Text(
                row.sign,
                style: TextStyle(
                  color: (row.bold ? p.fg : p.muted).withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: row.bold ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          Text(
            row.value,
            style: TextStyle(
              color: row.bold ? p.fg : p.muted,
              fontSize: 14,
              fontWeight: row.bold ? FontWeight.w500 : FontWeight.w400,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.07,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadlineNumber extends StatelessWidget {
  const _HeadlineNumber({
    required this.value,
    required this.currency,
    required this.color,
  });

  final double value;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final formatted = formatCurrency(value, currency: currency);
    final symbol = _leadingSymbol(formatted);
    final rest = formatted.substring(symbol.length).trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: TextStyle(
            color: color.withValues(alpha: 0.55),
            fontSize: 30,
            height: 1,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          rest,
          style: TextStyle(
            color: color,
            fontSize: 56,
            height: 1,
            fontWeight: FontWeight.w500,
            letterSpacing: -2.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  String _leadingSymbol(String s) {
    final m = RegExp(r'^[^\d\-\(]+').firstMatch(s);
    return m?.group(0)?.trim() ?? '';
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.items, required this.fg});

  final List<({String label, String value})> items;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                items[i].label,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                items[i].value,
                style: TextStyle(
                  color: fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.36,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Recommendation panel below the breakdown — invites the user to
/// open the Compare screen.
class _CompareEntry extends StatelessWidget {
  const _CompareEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    return Material(
      color: p.panel,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: p.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.bg,
                  border: Border.all(color: p.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.bar_chart_rounded, size: 16, color: p.fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.compareEntryTitle,
                      style: TextStyle(
                        color: p.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.07,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.compareEntryBody,
                      style: TextStyle(
                        color: p.subtle,
                        fontSize: 12,
                        letterSpacing: -0.06,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 16, color: p.subtle),
            ],
          ),
        ),
      ),
    );
  }
}
