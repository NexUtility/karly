import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../calculator/data/category.dart';
import '../../../calculator/data/marketplaces.dart';
import '../../providers.dart';
import '../../data/saved_calculation.dart';

/// Two filter dropdowns (category, marketplace) above the History list.
///
/// Both default to "all". Each opens a bottom sheet limited to the
/// values actually present in the user's archive so we never offer a
/// filter that would yield zero results.
class HistoryFilterBar extends ConsumerWidget {
  const HistoryFilterBar({super.key, required this.entries});

  final List<SavedCalculation> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final filter = ref.watch(historyFilterProvider);

    final categoryIds = <String>{
      for (final e in entries) if (e.categoryId != null) e.categoryId!,
    };
    final marketplaceIds = <String>{
      for (final e in entries) e.marketplaceId,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _FilterDropdown(
              icon: Icons.local_offer_outlined,
              label: filter.categoryId == null
                  ? l10n.historyFilterAllCategories
                  : (Category.byId(filter.categoryId)?.displayName(l10n) ??
                      l10n.historyFilterAllCategories),
              active: filter.categoryId != null,
              onTap: () => _pickCategory(context, ref, categoryIds, l10n),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _FilterDropdown(
              icon: Icons.storefront_outlined,
              label: filter.marketplaceId == null
                  ? l10n.historyFilterAllMarketplaces
                  : _marketplaceName(filter.marketplaceId!),
              active: filter.marketplaceId != null,
              onTap: () =>
                  _pickMarketplace(context, ref, marketplaceIds, l10n),
            ),
          ),
          if (filter.isActive) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: l10n.historyClearFilters,
              onPressed: () =>
                  ref.read(historyFilterProvider.notifier).clearAll(),
              icon: Icon(
                Icons.filter_alt_off_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _marketplaceName(String id) {
    return defaultMarketplaces
        .firstWhere(
          (m) => m.id == id,
          orElse: () => defaultMarketplaces.last,
        )
        .name;
  }

  Future<void> _pickCategory(
    BuildContext context,
    WidgetRef ref,
    Set<String> available,
    AppLocalizations l10n,
  ) async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final options = Category.values
            .where((c) => available.contains(c.id))
            .toList()
          ..sort((a, b) =>
              a.displayName(l10n).compareTo(b.displayName(l10n)));
        return _PickerSheet(
          allLabel: l10n.historyFilterAllCategories,
          items: [
            for (final c in options)
              _PickerItem(id: c.id, label: c.displayName(l10n)),
          ],
        );
      },
    );
    if (picked != null || picked == null) {
      // distinguish "user dismissed" from "user picked 'all'": we use
      // an empty-string sentinel for "all".
    }
    if (!context.mounted) return;
    if (picked == '__all__') {
      ref.read(historyFilterProvider.notifier).clearCategory();
    } else if (picked != null) {
      ref.read(historyFilterProvider.notifier).setCategory(picked);
    }
  }

  Future<void> _pickMarketplace(
    BuildContext context,
    WidgetRef ref,
    Set<String> available,
    AppLocalizations l10n,
  ) async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final options = defaultMarketplaces
            .where((m) => available.contains(m.id))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        return _PickerSheet(
          allLabel: l10n.historyFilterAllMarketplaces,
          items: [
            for (final m in options) _PickerItem(id: m.id, label: m.name),
          ],
        );
      },
    );
    if (!context.mounted) return;
    if (picked == '__all__') {
      ref.read(historyFilterProvider.notifier).clearMarketplace();
    } else if (picked != null) {
      ref.read(historyFilterProvider.notifier).setMarketplace(picked);
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerItem {
  const _PickerItem({required this.id, required this.label});
  final String id;
  final String label;
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.allLabel, required this.items});

  final String allLabel;
  final List<_PickerItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                allLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.of(context).pop('__all__'),
            ),
            const Divider(height: 1),
            for (final i in items)
              ListTile(
                title: Text(i.label),
                onTap: () => Navigator.of(context).pop(i.id),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
