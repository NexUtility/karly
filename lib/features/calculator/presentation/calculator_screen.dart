import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/subscription_provider.dart';
import '../../../core/usage_quota_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../history/providers.dart';
import '../../paywall/presentation/pro_gate_dialogs.dart';
import '../data/category.dart';
import '../data/marketplace.dart';
import '../data/marketplaces.dart';
import '../domain/calculate.dart';
import '../domain/inputs.dart';
import '../domain/report_pdf.dart';
import 'marketplace_notes.dart';
import 'widgets/category_picker.dart';
import 'widgets/marketplace_picker.dart';
import 'widgets/result_card.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  Marketplace? _marketplace;
  Category? _category;
  final _itemNameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _sellCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  final _shippingCtrl = TextEditingController();
  final _opCostsCtrl = TextEditingController();
  final _vatCtrl = TextEditingController();

  CalcResult? _result;
  CalcInputs? _lastInputs;
  bool _sharing = false;
  bool _saving = false;
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_marketplace == null) {
      // First build — pick a marketplace based on the active locale
      // (Trendyol for Turkish users, Amazon US for everyone else).
      final lang = Localizations.localeOf(context).languageCode;
      final defaultId = defaultMarketplaceIdFor(lang);
      _applyMarketplace(
        defaultMarketplaces.firstWhere((m) => m.id == defaultId),
      );
    }
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _costCtrl.dispose();
    _sellCtrl.dispose();
    _commissionCtrl.dispose();
    _shippingCtrl.dispose();
    _opCostsCtrl.dispose();
    _vatCtrl.dispose();
    super.dispose();
  }

  /// Pre-fills commission and VAT based on the marketplace defaults,
  /// without overwriting user-entered values they've already typed.
  void _applyMarketplace(Marketplace m) {
    _marketplace = m;
    _commissionCtrl.text = (m.defaultCommissionRate * 100).toStringAsFixed(1);
    _vatCtrl.text = m.defaultVatRate == 0
        ? ''
        : (m.defaultVatRate * 100).toStringAsFixed(0);
  }

  void _onMarketplaceChanged(Marketplace m) {
    setState(() => _applyMarketplace(m));
  }

  void _onCategoryChanged(Category c) {
    setState(() => _category = c);
  }

  CalcInputs _buildInputs(Marketplace m) {
    return CalcInputs(
      itemName: _itemNameCtrl.text.trim().isEmpty
          ? null
          : _itemNameCtrl.text.trim(),
      categoryId: _category?.id,
      itemCost: _parse(_costCtrl.text),
      sellPrice: _parse(_sellCtrl.text),
      commissionRate: _parse(_commissionCtrl.text) / 100,
      shippingCost: _parse(_shippingCtrl.text),
      operationalCosts: _parse(_opCostsCtrl.text),
      fixedListingFee: m.fixedListingFee,
      vatRate: _parse(_vatCtrl.text) / 100,
      currency: m.defaultCurrency,
    );
  }

  void _onCalculate() {
    final m = _marketplace;
    if (m == null) return;
    final inputs = _buildInputs(m);
    setState(() {
      _result = calculateProfit(inputs);
      _lastInputs = inputs;
      _saved = false;
    });
  }

  void _onReset() {
    final m = _marketplace;
    setState(() {
      _itemNameCtrl.clear();
      _category = null;
      _costCtrl.clear();
      _sellCtrl.clear();
      _shippingCtrl.clear();
      _opCostsCtrl.clear();
      if (m != null) _applyMarketplace(m);
      _result = null;
      _lastInputs = null;
      _saved = false;
    });
  }

  Future<void> _onSharePdf() async {
    final result = _result;
    final inputs = _lastInputs;
    final m = _marketplace;
    if (result == null || inputs == null || m == null || _sharing) return;

    // Gate on daily cap for free users. Pro users skip the check.
    final subscription = ref.read(subscriptionProvider);
    if (!subscription.isPro) {
      final quota = await ref.read(usageQuotaProvider.future);
      if (!quota.freeUserCanShareMore()) {
        if (!mounted) return;
        await showDailyCapDialog(context);
        return;
      }
    }

    if (!mounted) return;
    setState(() => _sharing = true);
    try {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final locale = Localizations.localeOf(context);
      final dateStr = DateFormat.yMMMMd(
        locale.toString(),
      ).add_Hm().format(DateTime.now());

      final labels = ReportLabels(
        title: l10n.pdfTitle,
        generatedOn: l10n.pdfGeneratedOn(dateStr),
        sectionInputs: l10n.pdfSectionInputs,
        sectionResults: l10n.pdfSectionResults,
        netProfit: l10n.resultNetProfit,
        margin: l10n.resultMargin,
        roi: l10n.resultROI,
        itemCost: l10n.inputCost,
        sellPrice: l10n.inputSellPrice,
        commissionRate: l10n.inputCommissionRate,
        vatRate: l10n.inputVatRate,
        shipping: l10n.inputShipping,
        operationalCosts: l10n.inputOperationalCosts,
        commission: l10n.resultCommission,
        vat: l10n.resultVat,
        totalCosts: l10n.pdfTotalCosts,
        breakeven: l10n.resultBreakeven,
        regionTurkey: l10n.regionTurkey,
        regionGlobal: l10n.regionGlobal,
        footer: l10n.pdfFooter,
        categoryName: _category?.displayName(l10n),
      );

      final bytes = await buildReportPdf(
        marketplace: m,
        inputs: inputs,
        result: result,
        labels: labels,
      );

      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final filename = 'karly-${m.id}-$ts.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
        subject: l10n.pdfShareSubject,
      );

      if (!subscription.isPro) {
        await ref.read(usageQuotaProvider.notifier).recordReportShared();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to build PDF: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _onSave() async {
    final result = _result;
    final inputs = _lastInputs;
    final m = _marketplace;
    if (result == null || inputs == null || m == null || _saving) return;

    final subscription = ref.read(subscriptionProvider);
    if (!subscription.isPro) {
      await showSaveProGateDialog(context);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(historyProvider.notifier).add(
            inputs: inputs,
            result: result,
            marketplaceId: m.id,
          );
      if (!mounted) return;
      setState(() => _saved = true);
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.savedToHistory),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double _parse(String raw) {
    if (raw.trim().isEmpty) return 0;
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final marketplace = _marketplace;
    final subscription = ref.watch(subscriptionProvider);
    final quotaAsync = ref.watch(usageQuotaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const _BrandTitle(),
        toolbarHeight: 64,
      ),
      body: marketplace == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                Text(
                  l10n.calculatorBrandSubtitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                MarketplacePicker(
                  selectedId: marketplace.id,
                  onChanged: _onMarketplaceChanged,
                ),
                if (marketplaceNotesFor(marketplace, l10n) != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    marketplaceNotesFor(marketplace, l10n)!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 14),
                CategoryPicker(
                  selected: _category,
                  onChanged: _onCategoryChanged,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _itemNameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.inputItemName,
                    hintText: l10n.inputItemNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                _amountField(
                  controller: _costCtrl,
                  label: l10n.inputCost,
                  hint: l10n.inputCostHint,
                  currency: marketplace.defaultCurrency,
                ),
                const SizedBox(height: 12),
                _amountField(
                  controller: _sellCtrl,
                  label: l10n.inputSellPrice,
                  hint: l10n.inputSellPriceHint,
                  currency: marketplace.defaultCurrency,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _percentField(
                        controller: _commissionCtrl,
                        label: l10n.inputCommissionRate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _percentField(
                        controller: _vatCtrl,
                        label: l10n.inputVatRate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _amountField(
                        controller: _shippingCtrl,
                        label: l10n.inputShipping,
                        currency: marketplace.defaultCurrency,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _amountField(
                        controller: _opCostsCtrl,
                        label: l10n.inputOperationalCosts,
                        hint: l10n.inputOperationalCostsHint,
                        currency: marketplace.defaultCurrency,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _onCalculate,
                        child: Text(l10n.actionCalculate),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _onReset,
                      child: Text(l10n.actionReset),
                    ),
                  ],
                ),
                if (_result != null) ...[
                  const SizedBox(height: 22),
                  ResultCard(
                    result: _result!,
                    currency: marketplace.defaultCurrency,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _sharing ? null : _onSharePdf,
                      icon: _sharing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onSurface,
                              ),
                            )
                          : const Icon(Icons.ios_share_rounded, size: 18),
                      label: Text(l10n.actionSharePdf),
                    ),
                  ),
                  if (!subscription.isPro)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: quotaAsync.when(
                        data: (q) {
                          final remaining =
                              (kDailyFreeReportCap - q.reportsToday).clamp(
                            0,
                            kDailyFreeReportCap,
                          );
                          return Text(
                            l10n.dailyCapCounter(
                              q.reportsToday,
                              kDailyFreeReportCap,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: remaining == 0
                                  ? BrandColors.warning
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _saving || _saved ? null : _onSave,
                      icon: _saving
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onSurface,
                              ),
                            )
                          : Icon(
                              _saved
                                  ? Icons.check_rounded
                                  : Icons.bookmark_add_outlined,
                              size: 18,
                            ),
                      label: Text(
                        _saved ? l10n.savedToHistory : l10n.actionSaveToHistory,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _amountField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required String currency,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: _prefixFor(currency),
      ),
    );
  }

  Widget _percentField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: '%',
      ),
    );
  }

  String _prefixFor(String currency) {
    switch (currency) {
      case 'TRY':
        return '₺ ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      case 'GBP':
        return '£ ';
      default:
        return '';
    }
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: BrandColors.accent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: const Text(
            'K',
            style: TextStyle(
              color: BrandColors.accentForeground,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Kârly',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
