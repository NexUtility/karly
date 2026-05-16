import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/calm_widgets.dart';
import '../../../theme/colors.dart';
import '../../calculator/data/marketplace.dart';
import '../../calculator/data/marketplaces.dart';
import '../../calculator/domain/calculate.dart';
import '../../calculator/domain/inputs.dart';
import '../../calculator/presentation/marketplace_emoji.dart';

/// Calm Compare screen — ports `prototype-calm/compare.jsx`.
///
/// Takes the user's current inputs (cost / sell / shipping / ops),
/// re-runs `calculateProfit` against every marketplace's defaults
/// (skipping `custom`), then ranks them by net profit or margin.
///
/// Tapping a row pops with the picked [Marketplace]; the calculator
/// applies it and recomputes.
class CompareScreen extends StatefulWidget {
  const CompareScreen({
    super.key,
    required this.inputs,
    required this.currentMarketplaceId,
  });

  /// Last-built inputs from the calculator. `commissionRate` and
  /// `vatRate` here are ignored — the whole point of Compare is to
  /// swap in each marketplace's defaults — but the rest carry over.
  final CalcInputs inputs;
  final String currentMarketplaceId;

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

enum _Sort { net, margin }

class _CompareScreenState extends State<CompareScreen> {
  _Sort _sort = _Sort.net;

  bool get _hasData =>
      widget.inputs.sellPrice > 0 && widget.inputs.itemCost > 0;

  List<({Marketplace m, CalcResult r})> _ranked() {
    final rows = defaultMarketplaces
        .where((m) => m.id != 'custom')
        .map((m) {
      final inputs = CalcInputs(
        itemCost: widget.inputs.itemCost,
        sellPrice: widget.inputs.sellPrice,
        commissionRate: m.defaultCommissionRate,
        vatRate: m.defaultVatRate,
        shippingCost: widget.inputs.shippingCost,
        operationalCosts: widget.inputs.operationalCosts,
        fixedListingFee: m.fixedListingFee,
        currency: m.defaultCurrency,
      );
      return (m: m, r: calculateProfit(inputs));
    }).toList();
    rows.sort((a, b) {
      switch (_sort) {
        case _Sort.net:
          return b.r.netProfit.compareTo(a.r.netProfit);
        case _Sort.margin:
          return b.r.marginPct.compareTo(a.r.marginPct);
      }
    });
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);

    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        toolbarHeight: 64,
        titleSpacing: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 0, 14),
          child: _BackButton(onTap: () => Navigator.of(context).maybePop()),
        ),
        title: const CalmBrandTitle(title: 'Kârly'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 22, 0),
            child: Center(
              child: CalmPill(
                label: l10n.compareBadgeBeta,
                tone: CalmTone.accent,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
        children: [
          CalmSectionTitle(
            eyebrow: l10n.compareEyebrow,
            title: l10n.compareTitle,
            subtitle: _hasData
                ? l10n.compareSubReady
                : l10n.compareSubMissing,
          ),
          if (!_hasData)
            _EmptyState(onBack: () => Navigator.of(context).maybePop())
          else ..._buildBody(context, l10n, p),
        ],
      ),
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    CalmPalette p,
  ) {
    final ranked = _ranked();
    final best = ranked.isNotEmpty && !ranked.first.r.isLoss
        ? ranked.first
        : null;
    final suggestion = best != null && best.m.id != widget.currentMarketplaceId
        ? best
        : null;

    return [
      // Sort tabs (pill-shaped chips)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            _SortChip(
              label: l10n.compareSortNet,
              selected: _sort == _Sort.net,
              onTap: () => setState(() => _sort = _Sort.net),
            ),
            const SizedBox(width: 8),
            _SortChip(
              label: l10n.compareSortMargin,
              selected: _sort == _Sort.margin,
              onTap: () => setState(() => _sort = _Sort.margin),
            ),
          ],
        ),
      ),
      for (var i = 0; i < ranked.length; i++)
        _RankedRow(
          marketplace: ranked[i].m,
          result: ranked[i].r,
          isBest: i == 0 && !ranked[i].r.isLoss,
          isCurrent: ranked[i].m.id == widget.currentMarketplaceId,
          isLast: i == ranked.length - 1,
          onTap: () => Navigator.of(context).pop(ranked[i].m),
        ),
      if (suggestion != null) ...[
        const SizedBox(height: 18),
        _SuggestionFooter(
          marketplace: suggestion.m,
          marginPct: suggestion.r.marginPct,
          onPick: () => Navigator.of(context).pop(suggestion.m),
        ),
      ],
    ];
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(side: BorderSide(color: p.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.chevron_left_rounded, size: 18, color: p.fg),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 36, 14, 28),
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.compareEmptyTitle,
            style: TextStyle(
              color: p.muted,
              fontSize: 14,
              letterSpacing: -0.07,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          CalmButton(
            label: l10n.compareEmptyCta,
            variant: CalmBtnVariant.ghost,
            fullWidth: false,
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Material(
      color: selected ? p.fg : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? p.fg : p.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? p.bg : p.muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.065,
            ),
          ),
        ),
      ),
    );
  }
}

class _RankedRow extends StatelessWidget {
  const _RankedRow({
    required this.marketplace,
    required this.result,
    required this.isBest,
    required this.isCurrent,
    required this.isLast,
    required this.onTap,
  });

  final Marketplace marketplace;
  final CalcResult result;
  final bool isBest;
  final bool isCurrent;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final ccy = marketplace.defaultCurrency;
    final netColor = result.isLoss
        ? p.neg
        : isBest
            ? p.accent
            : p.fg;
    final commPct = (marketplace.defaultCommissionRate * 100)
        .toStringAsFixed(1);
    final fixedFee = marketplace.fixedListingFee;
    final sub = '$commPct% fee · $ccy${fixedFee > 0 ? ' · +${_sym(ccy)}${fixedFee.toStringAsFixed(2)}' : ''}';

    final card = Container(
      decoration: BoxDecoration(
        color: isBest ? p.accentSoft : Colors.transparent,
        border: isBest
            ? Border.all(color: p.accent.withValues(alpha: 0.33))
            : Border(
                bottom: BorderSide(
                  color: isLast ? Colors.transparent : p.border,
                ),
              ),
        borderRadius: isBest ? BorderRadius.circular(18) : BorderRadius.zero,
      ),
      margin: EdgeInsets.only(bottom: isBest ? 8 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.panel,
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              emojiFor(marketplace),
              style: const TextStyle(fontSize: 16, height: 1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      marketplace.name,
                      style: TextStyle(
                        color: p.fg,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.07,
                      ),
                    ),
                    if (isBest)
                      CalmPill(
                        label: l10n.compareBadgeBest,
                        tone: CalmTone.accent,
                      ),
                    if (isCurrent && !isBest)
                      CalmPill(label: l10n.compareBadgeCurrent),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
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
                _signed(result.netProfit, ccy),
                color: netColor,
                size: 15,
              ),
              const SizedBox(height: 2),
              CalmNum(
                '${result.marginPct >= 0 ? '+' : ''}${result.marginPct.toStringAsFixed(1)}%',
                color: p.subtle,
                size: 12,
                weight: FontWeight.w400,
              ),
            ],
          ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: isBest ? BorderRadius.circular(18) : BorderRadius.zero,
      child: card,
    );
  }

  String _signed(double v, String ccy) {
    final base = formatCurrency(v.abs(), currency: ccy);
    return v >= 0 ? '+$base' : '−$base';
  }

  String _sym(String ccy) {
    switch (ccy) {
      case 'TRY':
        return '₺';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '';
    }
  }
}

class _SuggestionFooter extends StatelessWidget {
  const _SuggestionFooter({
    required this.marketplace,
    required this.marginPct,
    required this.onPick,
  });

  final Marketplace marketplace;
  final double marginPct;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.compareSuggestionEyebrow,
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.06,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.compareSuggestionBody(
                    marketplace.name,
                    marginPct.toStringAsFixed(1),
                  ),
                  style: TextStyle(
                    color: p.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.07,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: p.accent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPick,
              child: SizedBox(
                width: 38,
                height: 38,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: p.accentFg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
