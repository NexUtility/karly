import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale_provider.dart';
import '../../../core/subscription_provider.dart';
import '../../../core/usage_quota_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/calm_widgets.dart';
import '../../../theme/colors.dart';
import '../../paywall/presentation/paywall_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _privacyUrl = 'https://nexutility.com/privacy';
  static const _termsUrl = 'https://nexutility.com/terms';
  static const _supportUrl = 'https://nexutility.com/support';
  static const _version = '0.2.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final locale = ref.watch(localeProvider);
    final subscription = ref.watch(subscriptionProvider);
    final quotaAsync = ref.watch(usageQuotaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const CalmBrandTitle(),
        toolbarHeight: 64,
        backgroundColor: p.bg,
      ),
      backgroundColor: p.bg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        children: [
          CalmSectionTitle(eyebrow: l10n.settingsAbout, title: l10n.navSettings),

          // Subscription card — accent for Pro, panel for Free
          _SubscriptionCard(
            isPro: subscription.isPro,
            onUpgrade: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PaywallScreen(),
                fullscreenDialog: true,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Usage card
          _UsageCard(
            isPro: subscription.isPro,
            quotaAsync: quotaAsync,
          ),
          const SizedBox(height: 22),

          _SectionLabel(text: _preferencesLabel(l10n)),
          const SizedBox(height: 10),

          // Theme toggle row (system-only — kept as a single read-only row)
          _ToggleRow(
            label: l10n.settingsTheme,
            value: Theme.of(context).brightness == Brightness.dark
                ? l10n.settingsThemeDark
                : l10n.settingsThemeLight,
          ),
          const SizedBox(height: 10),

          // Language sheet trigger
          _SettingsRow(
            label: l10n.settingsLanguage,
            value: _languageLabel(locale, l10n),
            onTap: () => _openLanguageSheet(context, ref),
          ),

          const SizedBox(height: 22),
          _SectionLabel(text: l10n.settingsAbout),
          const SizedBox(height: 4),
          _AboutRow(
            label: l10n.settingsPrivacy,
            url: _privacyUrl,
            isLast: false,
          ),
          _AboutRow(
            label: l10n.settingsTerms,
            url: _termsUrl,
            isLast: false,
          ),
          _AboutRow(
            label: l10n.settingsSupport,
            url: _supportUrl,
            isLast: true,
          ),

          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onLongPress: kDebugMode
                  ? () {
                      final next = subscription.isPro
                          ? SubscriptionTier.free
                          : SubscriptionTier.proAnnual;
                      ref.read(subscriptionProvider.notifier).debugSetTier(next);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('DEBUG: tier = ${next.name}'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              child: Text(
                'Kârly ${l10n.settingsVersion(_version)} · by NexUtility',
                style: TextStyle(
                  color: p.subtle,
                  fontSize: 12,
                  letterSpacing: -0.06,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _languageLabel(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.settingsLanguageSystem;
    switch (locale.languageCode) {
      case 'tr':
        return l10n.settingsLanguageTurkish;
      case 'en':
        return l10n.settingsLanguageEnglish;
      default:
        return locale.languageCode;
    }
  }

  String _preferencesLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Tercihler' : 'Preferences';

  void _openLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: CalmPalette.of(context).sheetScrim,
      builder: (ctx) => _LanguageSheet(
        current: ref.read(localeProvider),
        onSelect: (loc) {
          ref.read(localeProvider.notifier).set(loc);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.isPro, required this.onUpgrade});

  final bool isPro;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);

    if (isPro) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: p.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.settingsSubscription,
                  style: TextStyle(
                    color: p.accentFg.withValues(alpha: 0.7),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.paywallAnnualTitle,
                  style: TextStyle(
                    color: p.accentFg.withValues(alpha: 0.65),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.settingsSubscriptionPro,
              style: TextStyle(
                color: p.accentFg,
                fontSize: 26,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.78,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.localeName == 'tr' ? 'Plan' : 'Plan',
                style: TextStyle(
                  color: p.muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CalmPill(label: l10n.settingsSubscriptionFree),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kârly',
            style: TextStyle(
              color: p.fg,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.55,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.localeName == 'tr'
                ? '10 pazaryeri. Günde 3 hesaplama. Sınırsız hesaplama ve Geçmiş için Pro\'ya geç.'
                : 'All 10 marketplaces. 3 calculations a day. Upgrade for unlimited calculations + History.',
            style: TextStyle(
              color: p.muted,
              fontSize: 13.5,
              height: 1.5,
              letterSpacing: -0.067,
            ),
          ),
          const SizedBox(height: 16),
          CalmButton(
            label: l10n.settingsSubscriptionUpgrade,
            variant: CalmBtnVariant.accent,
            onPressed: onUpgrade,
          ),
        ],
      ),
    );
  }
}

class _UsageCard extends ConsumerWidget {
  const _UsageCard({required this.isPro, required this.quotaAsync});

  final bool isPro;
  final AsyncValue<UsageQuotaState> quotaAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: quotaAsync.when(
        loading: () => const SizedBox(height: 60),
        error: (_, _) => const SizedBox.shrink(),
        data: (q) {
          final cap = kDailyFreeReportCap;
          final used = q.reportsToday;
          final atCap = !isPro && used >= cap;
          final pct = isPro
              ? (used / 10).clamp(0.0, 1.0)
              : (used / cap).clamp(0.0, 1.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.localeName == 'tr'
                            ? 'Bugünkü hesaplamalar'
                            : 'Calculations today',
                        style: TextStyle(
                          color: p.muted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPro
                            ? (l10n.localeName == 'tr'
                                ? 'Sınırsız'
                                : 'Unlimited')
                            : '$used / $cap',
                        style: TextStyle(
                          color: p.fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.24,
                        ),
                      ),
                    ],
                  ),
                  CalmNum(
                    '$used',
                    color: p.subtle,
                    size: 13,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Stack(
                  children: [
                    Container(
                      height: 5,
                      color: p.fg.withValues(alpha: 0.10),
                    ),
                    LayoutBuilder(
                      builder: (ctx, c) {
                        return Container(
                          width: c.maxWidth * pct,
                          height: 5,
                          color: atCap ? p.warn : p.accent,
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (!isPro) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.localeName == 'tr'
                      ? 'Gece yarısı sıfırlanır.'
                      : 'Resets at midnight your time.',
                  style: TextStyle(
                    color: p.subtle,
                    fontSize: 12,
                    letterSpacing: -0.06,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: p.muted,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.065,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: p.fg,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.07,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: p.muted,
              fontSize: 13.5,
              letterSpacing: -0.067,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Material(
      color: p.panel,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: p.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: p.fg,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.07,
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: p.muted,
                      fontSize: 13.5,
                      letterSpacing: -0.067,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: p.subtle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.label,
    required this.url,
    required this.isLast,
  });

  final String label;
  final String url;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link copied: $url'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: p.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: p.fg,
                fontSize: 14.5,
                letterSpacing: -0.07,
              ),
            ),
            Icon(Icons.north_east_rounded, size: 13, color: p.muted),
          ],
        ),
      ),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current, required this.onSelect});

  final Locale? current;
  final ValueChanged<Locale?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final media = MediaQuery.of(context);
    final options = <({Locale? loc, String label, String? native})>[
      (loc: null, label: l10n.settingsLanguageSystem, native: null),
      (
        loc: const Locale('en'),
        label: l10n.settingsLanguageEnglish,
        native: 'English'
      ),
      (
        loc: const Locale('tr'),
        label: l10n.settingsLanguageTurkish,
        native: 'Türkçe'
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.settingsLanguage,
                    style: TextStyle(
                      color: p.fg,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final o in options)
            _LangRow(
              option: o,
              selected: (current == null && o.loc == null) ||
                  (current != null &&
                      o.loc?.languageCode == current!.languageCode),
              onTap: () => onSelect(o.loc),
            ),
          SizedBox(height: 18 + media.padding.bottom),
        ],
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  const _LangRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ({Locale? loc, String label, String? native}) option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? p.accentSoft : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      color: selected ? p.accent : p.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.15,
                    ),
                  ),
                  if (option.native != null && option.native != option.label)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        option.native!,
                        style: TextStyle(
                          color: p.subtle,
                          fontSize: 12,
                          letterSpacing: -0.06,
                        ),
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
}
