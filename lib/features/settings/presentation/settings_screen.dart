import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale_provider.dart';
import '../../../core/subscription_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../paywall/presentation/paywall_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _privacyUrl = 'https://nexutility.com/privacy';
  static const _termsUrl = 'https://nexutility.com/terms';
  static const _supportUrl = 'https://nexutility.com/support';
  static const _version = '0.1.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _section(theme, l10n.settingsSubscription),
          _SubscriptionTile(state: subscription),
          const SizedBox(height: 8),
          _section(theme, l10n.settingsLanguage),
          _LanguageOption(
            label: l10n.settingsLanguageSystem,
            selected: locale == null,
            onTap: () => ref.read(localeProvider.notifier).set(null),
          ),
          _LanguageOption(
            label: l10n.settingsLanguageEnglish,
            selected: locale?.languageCode == 'en',
            onTap: () =>
                ref.read(localeProvider.notifier).set(const Locale('en')),
          ),
          _LanguageOption(
            label: l10n.settingsLanguageTurkish,
            selected: locale?.languageCode == 'tr',
            onTap: () =>
                ref.read(localeProvider.notifier).set(const Locale('tr')),
          ),
          const SizedBox(height: 8),
          _section(theme, l10n.settingsAbout),
          _LinkTile(
            icon: Icons.shield_outlined,
            label: l10n.settingsPrivacy,
            url: _privacyUrl,
          ),
          _LinkTile(
            icon: Icons.description_outlined,
            label: l10n.settingsTerms,
            url: _termsUrl,
          ),
          _LinkTile(
            icon: Icons.help_outline_rounded,
            label: l10n.settingsSupport,
            url: _supportUrl,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              l10n.settingsVersion(_version),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.state});

  final SubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPro = state.isPro;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isPro
              ? BrandColors.accent
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.workspace_premium_rounded,
          size: 18,
          color: isPro
              ? BrandColors.accentForeground
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      title: Text(
        isPro ? l10n.settingsSubscriptionPro : l10n.settingsSubscriptionFree,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: isPro
          ? null
          : Text(
              l10n.settingsSubscriptionUpgrade,
              style: theme.textTheme.bodySmall?.copyWith(
                color: BrandColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
      trailing: isPro
          ? Icon(
              Icons.check_circle_rounded,
              color: BrandColors.accent,
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
      onTap: isPro
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaywallScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon),
      title: Text(label),
      trailing: Icon(
        Icons.north_east_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
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
    );
  }
}
