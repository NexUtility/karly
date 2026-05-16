import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/subscription_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/calm_widgets.dart';
import '../../../theme/colors.dart';
import '../../paywall/presentation/paywall_screen.dart';
import '../providers.dart';
import 'widgets/history_entry_tile.dart';
import 'widgets/history_filter_bar.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final p = CalmPalette.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const CalmBrandTitle(),
        toolbarHeight: 64,
        backgroundColor: p.bg,
      ),
      backgroundColor: p.bg,
      body: subscription.isPro
          ? const _ProHistory()
          : const _FreeHistoryGate(),
    );
  }
}

class _ProHistory extends ConsumerWidget {
  const _ProHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(historyProvider);
    final filter = ref.watch(historyFilterProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (entries) {
        final filtered = entries.where((e) {
          if (filter.categoryId != null && e.categoryId != filter.categoryId) {
            return false;
          }
          if (filter.marketplaceId != null &&
              e.marketplaceId != filter.marketplaceId) {
            return false;
          }
          return true;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
              child: CalmSectionTitle(
                eyebrow: l10n.localeName == 'tr'
                    ? 'Arşivin'
                    : 'Your archive',
                title: l10n.navHistory,
                subtitle: entries.isEmpty
                    ? l10n.historyEmptyTitle
                    : l10n.historyEntryCount(entries.length),
              ),
            ),
            if (entries.isNotEmpty) HistoryFilterBar(entries: entries),
            Expanded(
              child: filtered.isEmpty
                  ? _HistoryEmpty(
                      hasEntries: entries.isNotEmpty,
                      onClear: () => ref
                          .read(historyFilterProvider.notifier)
                          .clearAll(),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(22, 0, 22, 24),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final entry = filtered[i];
                        return HistoryEntryTile(
                          entry: entry,
                          onDelete: () => ref
                              .read(historyProvider.notifier)
                              .remove(entry.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.hasEntries, required this.onClear});

  final bool hasEntries;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: p.panel,
                border: Border.all(color: p.border),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.list_alt_rounded, size: 26, color: p.muted),
            ),
            const SizedBox(height: 18),
            Text(
              hasEntries
                  ? (l10n.localeName == 'tr'
                      ? 'Filtrene uyan kayıt yok'
                      : 'No matches for your filters')
                  : l10n.historyEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.fg,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.24,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                hasEntries
                    ? (l10n.localeName == 'tr'
                        ? 'Hepsini görmek için filtreleri temizle.'
                        : 'Try clearing filters to see everything you\'ve saved.')
                    : l10n.historyEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.muted,
                  fontSize: 13.5,
                  height: 1.5,
                  letterSpacing: -0.067,
                ),
              ),
            ),
            if (hasEntries) ...[
              const SizedBox(height: 16),
              CalmButton(
                label: l10n.historyClearFilters,
                variant: CalmBtnVariant.ghost,
                fullWidth: false,
                onPressed: onClear,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FreeHistoryGate extends StatelessWidget {
  const _FreeHistoryGate();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
      children: [
        CalmSectionTitle(
          eyebrow: l10n.localeName == 'tr'
              ? 'Geçmiş · Pro'
              : 'History · Pro',
          title: l10n.historyProGateTitle,
          subtitle: l10n.historyProGateBody,
        ),
        // Faux blurred preview
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: p.panel,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  for (final r in _previewRows) ...[
                    Opacity(
                      opacity: 0.55,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: p.border),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: p.bg,
                                border: Border.all(color: p.border),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(r.flag,
                                  style: const TextStyle(fontSize: 14)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r.name,
                                style: TextStyle(
                                  color: p.fg.withValues(alpha: 0.6),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.068,
                                ),
                              ),
                            ),
                            Text(
                              r.value,
                              style: TextStyle(
                                color: p.fg.withValues(alpha: 0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x38000000),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 14, color: p.accentFg),
                    const SizedBox(width: 8),
                    Text(
                      l10n.localeName == 'tr'
                          ? 'Pro ile aç'
                          : 'Unlock with Pro',
                      style: TextStyle(
                        color: p.accentFg,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.067,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        CalmButton(
          label: l10n.localeName == 'tr'
              ? 'Pro\'ya geç · ₺49,92/ay\'dan'
              : 'See Pro · from \$1.66/mo',
          variant: CalmBtnVariant.accent,
          size: CalmBtnSize.lg,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PaywallScreen(),
              fullscreenDialog: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            l10n.localeName == 'tr'
                ? '3 gün ücretsiz · istediğinde iptal'
                : '3 days free · cancel anytime',
            style: TextStyle(
              color: p.subtle,
              fontSize: 12.5,
              letterSpacing: -0.063,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewRow {
  const _PreviewRow({required this.flag, required this.name, required this.value});
  final String flag;
  final String name;
  final String value;
}

const _previewRows = [
  _PreviewRow(flag: '🇹🇷', name: 'Linen pillow cover · oat', value: '+₺102.48'),
  _PreviewRow(flag: '🇺🇸', name: 'Walnut spoon set (4)', value: r'+$8.94'),
  _PreviewRow(flag: '🇺🇸', name: 'Wooden puzzle · stars', value: r'+$3.18'),
  _PreviewRow(flag: '🇺🇸', name: 'Vintage Polaroid Sun', value: r'−$12.30'),
  _PreviewRow(flag: '🇹🇷', name: 'Argan hair oil 100ml', value: '+₺22.10'),
];
