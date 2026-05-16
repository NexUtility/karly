import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../theme/colors.dart';
import '../../data/marketplace.dart';
import '../../data/marketplaces.dart';
import '../marketplace_emoji.dart';

/// Calm marketplace chip + bottom sheet picker.
///
/// The trigger is a single soft pill row showing the current
/// marketplace's emoji, name, and a "fee · VAT · currency" subline.
/// Tapping it opens a sheet grouped by region.
class MarketplacePicker extends StatelessWidget {
  const MarketplacePicker({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  final String selectedId;
  final ValueChanged<Marketplace> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final m = defaultMarketplaces.firstWhere(
      (m) => m.id == selectedId,
      orElse: () => defaultMarketplaces.first,
    );
    final vatPct = (m.defaultVatRate * 100).round();
    final commPct = (m.defaultCommissionRate * 100).toStringAsFixed(1);
    final sub = '$commPct% fee · $vatPct% VAT · ${m.defaultCurrency}';

    return Material(
      color: p.panel,
      shape: StadiumBorder(side: BorderSide(color: p.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: p.bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  emojiFor(m),
                  style: const TextStyle(fontSize: 14, height: 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.14,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.subtle,
                        fontSize: 11.5,
                        letterSpacing: -0.06,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.actionChange,
                style: TextStyle(
                  color: p.subtle,
                  fontSize: 13,
                  letterSpacing: -0.07,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<Marketplace>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: CalmPalette.of(context).sheetScrim,
      builder: (ctx) => _MarketplaceSheet(selectedId: selectedId),
    );
    if (picked != null) onChanged(picked);
  }
}

class _MarketplaceSheet extends StatelessWidget {
  const _MarketplaceSheet({required this.selectedId});

  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final sections = orderedMarketplaceSections(lang);
    final media = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
      child: Container(
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(p: p),
            _SheetHeader(
              p: p,
              eyebrow: l10n.marketplaceLabel,
              title: l10n.marketplacePickHint,
              onClose: () => Navigator.of(context).maybePop(),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  bottom: 22 + media.padding.bottom,
                ),
                children: [
                  for (final s in sections) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
                      child: Text(
                        s.region == MarketplaceRegion.tr
                            ? l10n.regionTurkey
                            : l10n.regionGlobal,
                        style: TextStyle(
                          color: p.subtle,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.06,
                        ),
                      ),
                    ),
                    ...s.items.map(
                      (m) => _MarketplaceRow(
                        marketplace: m,
                        selected: m.id == selectedId,
                        onTap: () => Navigator.of(context).pop(m),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketplaceRow extends StatelessWidget {
  const _MarketplaceRow({
    required this.marketplace,
    required this.selected,
    required this.onTap,
  });

  final Marketplace marketplace;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    final vatPct = (marketplace.defaultVatRate * 100).round();
    final commPct = (marketplace.defaultCommissionRate * 100).toStringAsFixed(1);
    final fixedFee = marketplace.fixedListingFee;
    final sub =
        '$commPct% fee · $vatPct% VAT · ${marketplace.defaultCurrency}'
        '${fixedFee > 0 ? ' · +${_currencySymbol(marketplace.defaultCurrency)}${fixedFee.toStringAsFixed(2)} listing' : ''}';

    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? p.accentSoft : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? p.accent : p.panel,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? p.accent : p.border,
                ),
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
                  Text(
                    marketplace.name,
                    style: TextStyle(
                      color: p.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.15,
                    ),
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
            if (selected)
              Icon(Icons.check_rounded, size: 18, color: p.accent),
          ],
        ),
      ),
    );
  }

  String _currencySymbol(String ccy) {
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

/// Reusable sheet drag handle.
class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.p});

  final CalmPalette p;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: p.borderHi,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

/// Reusable sheet header with eyebrow + title + close button.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.p,
    required this.eyebrow,
    required this.title,
    required this.onClose,
  });

  final CalmPalette p;
  final String eyebrow;
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: p.subtle,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.06,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: p.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: CircleBorder(side: BorderSide(color: p.border)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onClose,
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.close_rounded, size: 14, color: p.fg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
