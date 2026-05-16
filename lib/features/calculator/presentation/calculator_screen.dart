import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/subscription_provider.dart';
import '../../../core/usage_quota_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/calm_widgets.dart';
import '../../../theme/colors.dart';
import '../../compare/presentation/compare_screen.dart';
import '../../history/providers.dart';
import '../../paywall/presentation/pro_gate_dialogs.dart';
import '../data/category.dart';
import '../data/marketplace.dart';
import '../data/marketplaces.dart';
import '../domain/calculate.dart';
import '../domain/inputs.dart';
import '../domain/report_pdf.dart';
import 'widgets/category_picker.dart';
import 'widgets/marketplace_picker.dart';
import 'widgets/result_card.dart';

/// Calculator screen — the primary surface of the app.
///
/// Calm-redesign layout (mirrors `prototype-calm/calculator.jsx` and
/// `result.jsx` in a single scroll view, since Flutter routes the
/// calculator and result as one tab):
///
///   1. Calm section title ("New entry" / sub)
///   2. Marketplace chip
///   3. Item name underline + inline category chip
///   4. Cost / Sell — two large prefixed Fields side by side
///   5. Collapsible "Fees & shipping" with commission/VAT and the
///      two extra-cost rows
///   6. "See the breakdown" accent CTA + tertiary "Start over"
///   7. After Calculate: the colored hero result card + Share / Save CTAs
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
  bool _showAdvanced = false;
  bool _sharing = false;
  bool _saving = false;
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_marketplace == null) {
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
      _showAdvanced = false;
      _saved = false;
    });
  }

  Future<void> _onSharePdf() async {
    final result = _result;
    final inputs = _lastInputs;
    final m = _marketplace;
    if (result == null || inputs == null || m == null || _sharing) return;

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

  Future<void> _onCompare() async {
    final m = _marketplace;
    if (m == null) return;
    // Build inputs from the current form even if Calculate hasn't been
    // tapped yet — Compare needs the user's cost/sell to do its thing.
    final inputs = _lastInputs ?? _buildInputs(m);
    final picked = await Navigator.of(context).push<Marketplace>(
      MaterialPageRoute(
        builder: (_) => CompareScreen(
          inputs: inputs,
          currentMarketplaceId: m.id,
        ),
        fullscreenDialog: false,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _applyMarketplace(picked);
      // Recompute if we already have a result so the hero number
      // reflects the new marketplace's defaults.
      if (_lastInputs != null) {
        final newInputs = _buildInputs(picked);
        _result = calculateProfit(newInputs);
        _lastInputs = newInputs;
        _saved = false;
      }
    });
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

  String _currencyPrefix(String ccy) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    final marketplace = _marketplace;
    final subscription = ref.watch(subscriptionProvider);
    final quotaAsync = ref.watch(usageQuotaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const CalmBrandTitle(),
        toolbarHeight: 64,
        backgroundColor: p.bg,
      ),
      backgroundColor: p.bg,
      body: marketplace == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              children: [
                CalmSectionTitle(
                  title: l10n.calcHeaderTitle,
                  subtitle: l10n.calcHeaderSub,
                ),

                MarketplacePicker(
                  selectedId: marketplace.id,
                  onChanged: _onMarketplaceChanged,
                ),
                const SizedBox(height: 28),

                // Item name underline + inline category chip
                _ItemNameRow(
                  controller: _itemNameCtrl,
                  placeholder: l10n.itemNamePlaceholder,
                  category: _category,
                  onCategoryChanged: _onCategoryChanged,
                ),
                const SizedBox(height: 28),

                // Cost & Sell side-by-side, large
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CalmField(
                        controller: _costCtrl,
                        label: l10n.labelWhatYouPaid,
                        prefix: _currencyPrefix(marketplace.defaultCurrency),
                        large: true,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'))
                        ],
                        placeholder: '0',
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: CalmField(
                        controller: _sellCtrl,
                        label: l10n.labelSellingFor,
                        prefix: _currencyPrefix(marketplace.defaultCurrency),
                        large: true,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'))
                        ],
                        placeholder: '0',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // Collapsible advanced section
                _AdvancedToggle(
                  expanded: _showAdvanced,
                  onTap: () =>
                      setState(() => _showAdvanced = !_showAdvanced),
                ),

                if (_showAdvanced) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CalmField(
                          controller: _commissionCtrl,
                          label: l10n.labelCommission,
                          suffix: '%',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'))
                          ],
                          hint: _fieldHint(
                            current: _parse(_commissionCtrl.text),
                            defaultValue: marketplace.defaultCommissionRate * 100,
                            l10n: l10n,
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: CalmField(
                          controller: _vatCtrl,
                          label: l10n.labelVat,
                          suffix: '%',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'))
                          ],
                          hint: marketplace.defaultVatRate == 0
                              ? '—'
                              : _fieldHint(
                                  current: _parse(_vatCtrl.text),
                                  defaultValue: marketplace.defaultVatRate * 100,
                                  l10n: l10n,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CalmField(
                          controller: _shippingCtrl,
                          label: l10n.inputShipping,
                          prefix: _currencyPrefix(marketplace.defaultCurrency),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'))
                          ],
                          placeholder: '0',
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: CalmField(
                          controller: _opCostsCtrl,
                          label: l10n.labelAdsPackaging,
                          prefix: _currencyPrefix(marketplace.defaultCurrency),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'))
                          ],
                          placeholder: '0',
                        ),
                      ),
                    ],
                  ),
                  if (marketplace.fixedListingFee > 0) ...[
                    const SizedBox(height: 18),
                    Text(
                      l10n.fixedListingFeeNote(
                        _currencyPrefix(marketplace.defaultCurrency),
                        marketplace.fixedListingFee.toStringAsFixed(2),
                      ),
                      style: TextStyle(
                        color: p.subtle,
                        fontSize: 12,
                        height: 1.5,
                        letterSpacing: -0.06,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    height: 1,
                    color: p.border,
                  ),
                ],
                const SizedBox(height: 26),

                CalmButton(
                  label: l10n.actionSeeBreakdown,
                  variant: CalmBtnVariant.accent,
                  size: CalmBtnSize.lg,
                  onPressed: _onCalculate,
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: _onReset,
                    child: Text(
                      l10n.actionStartOver,
                      style: TextStyle(
                        color: p.subtle,
                        fontSize: 13,
                        letterSpacing: -0.07,
                      ),
                    ),
                  ),
                ),

                if (_result != null && _lastInputs != null) ...[
                  const SizedBox(height: 26),
                  ResultCard(
                    result: _result!,
                    inputs: _lastInputs!,
                    marketplace: marketplace,
                    onCompare: _onCompare,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: CalmButton(
                          label: l10n.actionSharePdf,
                          variant: CalmBtnVariant.ghost,
                          onPressed: _sharing ? null : _onSharePdf,
                          icon: _sharing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.ios_share_rounded),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CalmButton(
                          label: _saved
                              ? l10n.savedToHistory
                              : l10n.actionSave,
                          variant: CalmBtnVariant.primary,
                          onPressed: _saving || _saved ? null : _onSave,
                          icon: _saving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _saved
                                      ? Icons.check_rounded
                                      : Icons.bookmark_add_outlined,
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (!subscription.isPro)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: quotaAsync.when(
                        data: (q) {
                          final remaining =
                              (kDailyFreeReportCap - q.reportsToday).clamp(
                            0,
                            kDailyFreeReportCap,
                          );
                          return Center(
                            child: Text(
                              l10n.dailyCapCounter(
                                q.reportsToday,
                                kDailyFreeReportCap,
                              ),
                              style: TextStyle(
                                color: remaining == 0 ? p.warn : p.subtle,
                                fontSize: 12.5,
                                letterSpacing: -0.06,
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  String? _fieldHint({
    required double current,
    required double defaultValue,
    required AppLocalizations l10n,
  }) {
    if ((current - defaultValue).abs() < 0.01) return l10n.fieldHintDefault;
    return l10n.fieldHintEdited;
  }
}

/// Item name underline input + inline category chip beneath. Mirrors
/// the prototype's "What are you selling?" + folder chip pair.
class _ItemNameRow extends StatelessWidget {
  const _ItemNameRow({
    required this.controller,
    required this.placeholder,
    required this.category,
    required this.onCategoryChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final Category? category;
  final ValueChanged<Category> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final p = CalmPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.border)),
          ),
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: p.accent,
            style: TextStyle(
              color: p.fg,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: placeholder,
              hintStyle: TextStyle(
                color: p.subtle.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: CategoryPicker(
            selected: category,
            onChanged: onCategoryChanged,
          ),
        ),
      ],
    );
  }
}

class _AdvancedToggle extends StatelessWidget {
  const _AdvancedToggle({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = CalmPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.actionShowFees,
                    style: TextStyle(
                      color: p.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.07,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expanded
                        ? l10n.actionShowFeesShown
                        : l10n.actionShowFeesHidden,
                    style: TextStyle(
                      color: p.subtle,
                      fontSize: 12,
                      letterSpacing: -0.06,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: p.subtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
