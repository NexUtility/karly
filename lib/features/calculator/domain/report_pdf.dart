import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/format.dart';
import '../data/marketplace.dart';
import 'calculate.dart';
import 'inputs.dart';

/// Static labels for the PDF report. Caller fills these from
/// [AppLocalizations] so the generated PDF matches the user's locale.
class ReportLabels {
  const ReportLabels({
    required this.title,
    required this.generatedOn,
    required this.sectionInputs,
    required this.sectionResults,
    required this.netProfit,
    required this.margin,
    required this.roi,
    required this.itemCost,
    required this.sellPrice,
    required this.commissionRate,
    required this.vatRate,
    required this.shipping,
    required this.adSpend,
    required this.commission,
    required this.vat,
    required this.totalCosts,
    required this.breakeven,
    required this.footer,
  });

  final String title;
  final String generatedOn; // already formatted with the date
  final String sectionInputs;
  final String sectionResults;
  final String netProfit;
  final String margin;
  final String roi;
  final String itemCost;
  final String sellPrice;
  final String commissionRate;
  final String vatRate;
  final String shipping;
  final String adSpend;
  final String commission;
  final String vat;
  final String totalCosts;
  final String breakeven;
  final String footer;
}

/// Builds an A4 profit report from a single calculation.
///
/// Uses Roboto (via Google Fonts CDN, cached on disk by `printing`)
/// because the default Helvetica that ships with the `pdf` package
/// can't render Turkish characters correctly.
Future<Uint8List> buildReportPdf({
  required Marketplace marketplace,
  required CalcInputs inputs,
  required CalcResult result,
  required ReportLabels labels,
}) async {
  final regular = await PdfGoogleFonts.robotoRegular();
  final medium = await PdfGoogleFonts.robotoMedium();
  final bold = await PdfGoogleFonts.robotoBold();
  final mono = await PdfGoogleFonts.robotoMonoRegular();

  final theme = pw.ThemeData.withFont(
    base: regular,
    bold: bold,
    italic: regular,
    boldItalic: bold,
  );

  // Brand tokens — kept in sync with lib/theme/colors.dart.
  final accent = PdfColor.fromInt(0xFFC5FA1F);
  final ink = PdfColor.fromInt(0xFF09090B);
  final muted = PdfColor.fromInt(0xFF52525B);
  final subtle = PdfColor.fromInt(0xFF71717A);
  final border = PdfColor.fromInt(0xFFE4E4E7);
  final danger = PdfColor.fromInt(0xFFEF4444);

  final currency = inputs.currency;
  final isLoss = result.isLoss;
  final netColor = isLoss ? danger : ink;

  pw.Widget kv(String label, String value, {bool dim = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: dim ? subtle : muted,
                fontSize: 10.5,
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: mono,
              color: ink,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget sectionHeader(String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
      child: pw.Text(
        label.toUpperCase(),
        style: pw.TextStyle(
          color: subtle,
          fontSize: 9,
          letterSpacing: 1.4,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget hr() => pw.Container(height: 1, color: border);

  final doc = pw.Document(theme: theme, title: labels.title);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 28),
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // -------- Header --------
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 22,
                      height: 22,
                      decoration: pw.BoxDecoration(
                        color: accent,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'K',
                        style: pw.TextStyle(
                          font: bold,
                          color: ink,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'Kârly',
                      style: pw.TextStyle(
                        font: bold,
                        color: ink,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  labels.generatedOn,
                  style: pw.TextStyle(color: subtle, fontSize: 9.5),
                ),
              ],
            ),
            pw.SizedBox(height: 22),

            // -------- Title + marketplace --------
            pw.Text(
              labels.title,
              style: pw.TextStyle(
                font: bold,
                color: ink,
                fontSize: 22,
                letterSpacing: -0.6,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.Text(
                  marketplace.name,
                  style: pw.TextStyle(color: muted, fontSize: 11),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1.5,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: border),
                    borderRadius: pw.BorderRadius.circular(99),
                  ),
                  child: pw.Text(
                    marketplace.region == MarketplaceRegion.tr
                        ? 'Türkiye'
                        : 'Global',
                    style: pw.TextStyle(
                      font: medium,
                      color: muted,
                      fontSize: 8.5,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // -------- Net profit headline --------
            pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(20, 16, 20, 18),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFFAFAFA),
                border: pw.Border.all(color: border),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    labels.netProfit.toUpperCase(),
                    style: pw.TextStyle(
                      color: subtle,
                      fontSize: 8.5,
                      letterSpacing: 1.4,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    formatCurrency(result.netProfit, currency: currency),
                    style: pw.TextStyle(
                      font: bold,
                      color: netColor,
                      fontSize: 30,
                      letterSpacing: -1,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      _pill(
                        '${labels.margin} ${formatPercent(result.marginPct)}',
                        regular,
                        muted,
                        border,
                      ),
                      pw.SizedBox(width: 6),
                      _pill(
                        '${labels.roi} ${formatPercent(result.roiPct)}',
                        regular,
                        muted,
                        border,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            sectionHeader(labels.sectionInputs),
            hr(),
            kv(
              labels.itemCost,
              formatCurrency(inputs.itemCost, currency: currency),
            ),
            kv(
              labels.sellPrice,
              formatCurrency(inputs.sellPrice, currency: currency),
            ),
            kv(
              labels.commissionRate,
              formatPercent(inputs.commissionRate * 100),
            ),
            kv(labels.vatRate, formatPercent(inputs.vatRate * 100)),
            kv(
              labels.shipping,
              formatCurrency(inputs.shippingCost, currency: currency),
              dim: inputs.shippingCost == 0,
            ),
            kv(
              labels.adSpend,
              formatCurrency(inputs.adSpend, currency: currency),
              dim: inputs.adSpend == 0,
            ),

            sectionHeader(labels.sectionResults),
            hr(),
            kv(
              labels.commission,
              formatCurrency(result.commissionAmount, currency: currency),
            ),
            kv(
              labels.vat,
              formatCurrency(result.vatAmount, currency: currency),
            ),
            kv(
              labels.totalCosts,
              formatCurrency(result.totalCosts, currency: currency),
            ),
            kv(
              labels.breakeven,
              result.breakevenPrice.isFinite
                  ? formatCurrency(
                      result.breakevenPrice,
                      currency: currency,
                    )
                  : '—',
            ),

            pw.Spacer(),
            hr(),
            pw.SizedBox(height: 8),
            pw.Text(
              labels.footer,
              style: pw.TextStyle(color: subtle, fontSize: 8.5),
            ),
          ],
        );
      },
    ),
  );

  return doc.save();
}

pw.Widget _pill(
  String label,
  pw.Font font,
  PdfColor textColor,
  PdfColor borderColor,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: borderColor),
      borderRadius: pw.BorderRadius.circular(99),
    ),
    child: pw.Text(
      label,
      style: pw.TextStyle(font: font, color: textColor, fontSize: 9),
    ),
  );
}
