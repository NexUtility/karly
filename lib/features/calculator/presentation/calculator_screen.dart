import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/marketplace.dart';
import '../data/marketplaces.dart';
import '../domain/calculate.dart';
import '../domain/inputs.dart';
import '../domain/report_pdf.dart';
import 'widgets/marketplace_picker.dart';
import 'widgets/result_card.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  static const _initialMarketplaceId = 'trendyol';

  late Marketplace _marketplace;
  final _costCtrl = TextEditingController();
  final _sellCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  final _shippingCtrl = TextEditingController();
  final _adSpendCtrl = TextEditingController();
  final _vatCtrl = TextEditingController(text: '20');

  CalcResult? _result;
  CalcInputs? _lastInputs;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _marketplace = defaultMarketplaces.firstWhere(
      (m) => m.id == _initialMarketplaceId,
    );
    _commissionCtrl.text = (_marketplace.defaultCommissionRate * 100)
        .toStringAsFixed(1);
  }

  @override
  void dispose() {
    _costCtrl.dispose();
    _sellCtrl.dispose();
    _commissionCtrl.dispose();
    _shippingCtrl.dispose();
    _adSpendCtrl.dispose();
    _vatCtrl.dispose();
    super.dispose();
  }

  void _onMarketplaceChanged(Marketplace m) {
    setState(() {
      _marketplace = m;
      _commissionCtrl.text = (m.defaultCommissionRate * 100).toStringAsFixed(1);
    });
  }

  void _onCalculate() {
    final inputs = CalcInputs(
      itemCost: _parse(_costCtrl.text),
      sellPrice: _parse(_sellCtrl.text),
      commissionRate: _parse(_commissionCtrl.text) / 100,
      shippingCost: _parse(_shippingCtrl.text),
      adSpend: _parse(_adSpendCtrl.text),
      fixedListingFee: _marketplace.fixedListingFee,
      vatRate: _parse(_vatCtrl.text) / 100,
      currency: _marketplace.defaultCurrency,
    );
    setState(() {
      _result = calculateProfit(inputs);
      _lastInputs = inputs;
    });
  }

  void _onReset() {
    setState(() {
      _costCtrl.clear();
      _sellCtrl.clear();
      _shippingCtrl.clear();
      _adSpendCtrl.clear();
      _commissionCtrl.text = (_marketplace.defaultCommissionRate * 100)
          .toStringAsFixed(1);
      _vatCtrl.text = '20';
      _result = null;
      _lastInputs = null;
    });
  }

  Future<void> _onSharePdf() async {
    final result = _result;
    final inputs = _lastInputs;
    if (result == null || inputs == null || _sharing) return;

    setState(() => _sharing = true);
    try {
      final l10n = AppLocalizations.of(context);
      final locale = Localizations.localeOf(context);
      final dateStr = DateFormat.yMMMMd(locale.toString()).add_Hm().format(
        DateTime.now(),
      );

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
        adSpend: l10n.inputAdSpend,
        commission: l10n.resultCommission,
        vat: l10n.resultVat,
        totalCosts: l10n.pdfTotalCosts,
        breakeven: l10n.resultBreakeven,
        footer: l10n.pdfFooter,
      );

      final bytes = await buildReportPdf(
        marketplace: _marketplace,
        inputs: inputs,
        result: result,
        labels: labels,
      );

      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final filename = 'karly-${_marketplace.id}-$ts.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
        subject: l10n.pdfShareSubject,
      );
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

  double _parse(String raw) {
    if (raw.trim().isEmpty) return 0;
    return double.tryParse(raw.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calculatorTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          MarketplacePicker(
            selectedId: _marketplace.id,
            onChanged: _onMarketplaceChanged,
          ),
          if (_marketplace.notes != null) ...[
            const SizedBox(height: 6),
            Text(_marketplace.notes!, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 18),
          _amountField(
            controller: _costCtrl,
            label: l10n.inputCost,
            hint: l10n.inputCostHint,
            currency: _marketplace.defaultCurrency,
          ),
          const SizedBox(height: 12),
          _amountField(
            controller: _sellCtrl,
            label: l10n.inputSellPrice,
            hint: l10n.inputSellPriceHint,
            currency: _marketplace.defaultCurrency,
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
                  currency: _marketplace.defaultCurrency,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _amountField(
                  controller: _adSpendCtrl,
                  label: l10n.inputAdSpend,
                  currency: _marketplace.defaultCurrency,
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
            ResultCard(result: _result!, currency: _marketplace.defaultCurrency),
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
