import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _privacyUrl = 'https://nexutility.com/privacy';
  static const _termsUrl = 'https://nexutility.com/terms';
  static const _supportUrl = 'https://nexutility.com/support';
  static const _version = '0.1.0';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _section(theme, l10n.settingsAbout),
          _linkTile(
            context,
            icon: Icons.shield_outlined,
            label: l10n.settingsPrivacy,
            url: _privacyUrl,
          ),
          _linkTile(
            context,
            icon: Icons.description_outlined,
            label: l10n.settingsTerms,
            url: _termsUrl,
          ),
          _linkTile(
            context,
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

  Widget _linkTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Icon(
        Icons.north_east_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: () => _copyToClipboard(context, url),
    );
  }

  void _copyToClipboard(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied: $url'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
