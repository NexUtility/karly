import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../theme/colors.dart';
import '../../../calculator/data/category.dart';
import '../../../calculator/data/marketplaces.dart';
import '../../providers.dart';
import '../../data/saved_calculation.dart';

/// Calm dropdown-style filter chips for History. Mirrors the
/// "Market / Category" pair in `prototype-calm/history.jsx`.
class HistoryFilterBar extends ConsumerWidget {
  const HistoryFilterBar({super.key, required this.entries});

  final List<SavedCalculation> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(historyFilterProvider);

    final categoryIds = <String>{
      for (final e in entries) if (e.categoryId != null) e.categoryId!,
    };
    final marketplaceIds = <String>{
      for (final e in entries) e.marketplaceId,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
      child: Row(
        children: [
          Expanded(
            child: _CalmDropdown(
              label: l10n.localeName == 'tr' ? 'Pazaryeri' : 'Market',
              value: filter.marketplaceId == null
                  ? l10n.historyFilterAllMarketplaces
                  : _marketplaceName(filter.marketplaceId!),
              active: filter.marketplaceId != null,
              onTap: () => _pickMarketplace(context, ref, marketplaceIds, l10n),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _CalmDropdown(
              label: l10n.categoryLabel,
              value: filter.categoryId == null
                  ? l10n.historyFilterAllCategories
                  : (Category.byId(filter.categoryId)?.displayName(l10n) ??
                      l10n.historyFilterAllCategories),
              active: filter.categoryId != null,
              onTap: () => _pickCategory(context, ref, categoryIds, l10n),
            ),
          ),
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
      backgroundColor: Colors.transparent,
      barrierColor: CalmPalette.of(context).sheetScrim,
      builder: (ctx) {
        final options = Category.values
            .where((c) => available.contains(c.id))
            .toList()
          ..sort((a, b) =>
              a.displayName(l10n).compareTo(b.displayName(l10n)));
        return _CalmPickerSheet(
          title: l10n.localeName == 'tr'
              ? 'Kategoriye göre filtrele'
              : 'Filter by category',
          allLabel: l10n.historyFilterAllCategories,
          items: [
            for (final c in options)
              _PickerItem(id: c.id, label: c.displayName(l10n)),
          ],
        );
      },
    );
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
      backgroundColor: Colors.transparent,
      barrierColor: CalmPalette.of(context).sheetScrim,
      builder: (ctx) {
        final options = defaultMarketplaces
            .where((m) => available.contains(m.id))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        return _CalmPickerSheet(
          title: l10n.localeName == 'tr'
              ? 'Pazaryerine göre filtrele'
              : 'Filter by marketplace',
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

class _CalmDropdown extends StatelessWidget {
  const _CalmDropdown({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Material(
      color: active ? p.accentSoft : p.panel,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: active ? p.accent.withValues(alpha: 0.33) : p.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: p.subtle,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.058,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? p.accent : p.fg,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.068,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more_rounded,
                size: 14,
                color: p.subtle,
              ),
            ],
          ),
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

class _CalmPickerSheet extends StatelessWidget {
  const _CalmPickerSheet({
    required this.title,
    required this.allLabel,
    required this.items,
  });

  final String title;
  final String allLabel;
  final List<_PickerItem> items;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
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
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
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
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 18 + media.padding.bottom),
                children: [
                  _Row(
                    label: allLabel,
                    onTap: () => Navigator.of(context).pop('__all__'),
                  ),
                  for (final i in items)
                    _Row(
                      label: i.label,
                      onTap: () => Navigator.of(context).pop(i.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Text(
          label,
          style: TextStyle(
            color: p.fg,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.15,
          ),
        ),
      ),
    );
  }
}
