import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/subscription_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/calm_widgets.dart';
import '../../../theme/colors.dart';

/// Calm paywall — three honest promises + pricing cards.
/// Ported from `prototype-calm/pickers.jsx::PaywallSheet`.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.embedded = false});

  /// `true` when the screen renders inside another tab (History gate
  /// for free users). Hides the close button and trims top padding.
  final bool embedded;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionTier _selected = SubscriptionTier.proAnnual;

  void _onContinue() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.paywallStubMessage),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onRestore() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.paywallStubMessage),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);

    final body = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(26, widget.embedded ? 14 : 28, 26, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.embedded)
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                shape: CircleBorder(side: BorderSide(color: p.border)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: p.fg,
                    ),
                  ),
                ),
              ),
            ),
          if (!widget.embedded) const SizedBox(height: 8),

          // Eyebrow
          Text(
            l10n.paywallTitle,
            style: TextStyle(
              color: p.accent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.06,
            ),
          ),
          const SizedBox(height: 8),

          // Headline (use a two-line, hand-broken phrase)
          Text(
            l10n.paywallSubtitle,
            style: TextStyle(
              color: p.fg,
              fontSize: 32,
              fontWeight: FontWeight.w500,
              letterSpacing: -1.28,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _calmIntro(l10n),
            style: TextStyle(
              color: p.muted,
              fontSize: 14,
              height: 1.55,
              letterSpacing: -0.07,
            ),
          ),
          const SizedBox(height: 20),

          _FeatureRow(
            title: l10n.paywallFeatureUnlimitedReports,
            sub: _calmFeatureSub1(l10n),
          ),
          _Divider(),
          _FeatureRow(
            title: l10n.paywallFeatureSaveHistory,
            sub: _calmFeatureSub2(l10n),
          ),
          _Divider(),
          _FeatureRow(
            title: l10n.paywallFeatureFilter,
            sub: _calmFeatureSub3(l10n),
            isLast: true,
          ),

          const SizedBox(height: 22),

          // Pricing cards
          Row(
            children: [
              Expanded(
                child: _PricingCard(
                  title: l10n.paywallMonthlyTitle,
                  price: l10n.paywallMonthlyPrice,
                  caption: _cancelAnytime(l10n),
                  selected: _selected == SubscriptionTier.proMonthly,
                  onTap: () => setState(
                    () => _selected = SubscriptionTier.proMonthly,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PricingCard(
                  title: l10n.paywallAnnualTitle,
                  price: l10n.paywallAnnualPrice,
                  caption: l10n.paywallAnnualPerMonth,
                  captionAccent: true,
                  badge: l10n.paywallAnnualBadge,
                  selected: _selected == SubscriptionTier.proAnnual,
                  onTap: () => setState(
                    () => _selected = SubscriptionTier.proAnnual,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          CalmButton(
            label: l10n.paywallContinue,
            variant: CalmBtnVariant.accent,
            onPressed: _onContinue,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(
                l10n.actionLater,
                style: TextStyle(color: p.muted, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: _onRestore,
              child: Text(
                l10n.paywallRestore,
                style: TextStyle(
                  color: p.subtle,
                  fontSize: 12.5,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.paywallDisclaimer,
            style: TextStyle(
              color: p.subtle,
              fontSize: 11.5,
              height: 1.5,
              letterSpacing: -0.058,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(child: body),
    );
  }

  String _calmIntro(AppLocalizations l10n) =>
      l10n.localeName == 'tr'
          ? 'Pro\'da elde edeceğin üç dürüst şey. Hiçbir planda reklam yok, hiçbir zaman.'
          : 'Three honest things you get with Pro. No ads, ever, on any plan.';
  String _calmFeatureSub1(AppLocalizations l10n) => l10n.localeName == 'tr'
      ? 'Ücretsiz plan günde 3 ile sınırlı. Pro limiti kaldırır.'
      : 'Free is capped at 3 a day. Pro removes the limit.';
  String _calmFeatureSub2(AppLocalizations l10n) => l10n.localeName == 'tr'
      ? 'Pazaryeri ve kategoriye göre etiketlenmiş, aranabilir geçmiş.'
      : 'Searchable history tagged by marketplace and category.';
  String _calmFeatureSub3(AppLocalizations l10n) => l10n.localeName == 'tr'
      ? 'Pazaryeri, kategori, kâr ya da tarihe göre.'
      : 'By marketplace, category, profit, or date.';
  String _cancelAnytime(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'istediğinde iptal' : 'cancel anytime';
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.title,
    required this.sub,
    this.isLast = false,
  });

  final String title;
  final String sub;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: p.accentSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check_rounded, color: p.accent, size: 12),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: TextStyle(
                    color: p.muted,
                    fontSize: 13,
                    height: 1.45,
                    letterSpacing: -0.065,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Container(height: 1, color: p.border);
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.title,
    required this.price,
    required this.caption,
    this.captionAccent = false,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String price;
  final String caption;
  final bool captionAccent;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: selected ? p.accentSoft : p.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? p.accent : p.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: p.subtle,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: TextStyle(
                        color: p.fg,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.55,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caption,
                      style: TextStyle(
                        color: captionAccent ? p.pos : p.muted,
                        fontSize: 12,
                        fontWeight: captionAccent
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  color: p.accentFg,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.06,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Helper that opens the full-screen paywall.
Future<void> openPaywall(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const PaywallScreen(),
      fullscreenDialog: true,
    ),
  );
}
