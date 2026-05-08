import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/marketplace.dart';
import '../../data/marketplaces.dart';

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
    final theme = Theme.of(context);

    final tr = defaultMarketplaces
        .where((m) => m.region == MarketplaceRegion.tr)
        .toList();
    final global = defaultMarketplaces
        .where((m) => m.region == MarketplaceRegion.global)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.marketplaceLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _open(context, tr, global),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayFor(selectedId),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _displayFor(String id) {
    final m = defaultMarketplaces.firstWhere(
      (m) => m.id == id,
      orElse: () => defaultMarketplaces.first,
    );
    return m.name;
  }

  Future<void> _open(
    BuildContext context,
    List<Marketplace> tr,
    List<Marketplace> global,
  ) async {
    final picked = await showModalBottomSheet<Marketplace>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              _sectionHeader(theme, 'Türkiye'),
              ...tr.map((m) => _tile(ctx, m, selectedId)),
              _sectionHeader(theme, 'Global'),
              ...global.map((m) => _tile(ctx, m, selectedId)),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  Widget _sectionHeader(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.2),
      ),
    );
  }

  Widget _tile(BuildContext context, Marketplace m, String selectedId) {
    final theme = Theme.of(context);
    final selected = m.id == selectedId;
    return ListTile(
      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: m.notes != null
          ? Text(
              m.notes!,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: selected
          ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: () => Navigator.of(context).pop(m),
    );
  }
}
