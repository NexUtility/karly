import 'package:flutter/foundation.dart';

import 'inputs.dart';

@immutable
class CalcResult {
  const CalcResult({
    required this.netProfit,
    required this.marginPct,
    required this.roiPct,
    required this.commissionAmount,
    required this.vatAmount,
    required this.totalCosts,
    required this.breakevenPrice,
  });

  /// Net profit in the input currency. Negative if the sale loses money.
  final double netProfit;

  /// Margin as a percentage of the sell price (net / sell * 100).
  final double marginPct;

  /// Return on investment — net / item cost * 100.
  final double roiPct;

  final double commissionAmount;
  final double vatAmount;
  final double totalCosts;

  /// Sell price at which net profit equals zero, given the same costs.
  final double breakevenPrice;

  bool get isLoss => netProfit < 0;
}

/// Pure profit calculation. No I/O, no state — safe for unit testing.
///
/// Computes:
///   commission = sellPrice * commissionRate + fixedListingFee
///   vat        = sellPrice * vatRate
///   totalCosts = itemCost + shippingCost + operationalCosts + commission + vat
///   netProfit  = sellPrice - totalCosts
CalcResult calculateProfit(CalcInputs i) {
  final commission = i.sellPrice * i.commissionRate + i.fixedListingFee;
  final vat = i.sellPrice * i.vatRate;
  final totalCosts =
      i.itemCost + i.shippingCost + i.operationalCosts + commission + vat;
  final netProfit = i.sellPrice - totalCosts;

  final marginPct = i.sellPrice == 0 ? 0.0 : (netProfit / i.sellPrice) * 100;
  final roiPct = i.itemCost == 0 ? 0.0 : (netProfit / i.itemCost) * 100;

  // Solve sellPrice for netProfit = 0:
  //   sellPrice * (1 - commissionRate - vatRate)
  //     = itemCost + shippingCost + operationalCosts + fixedListingFee
  final variableFraction = 1 - i.commissionRate - i.vatRate;
  final fixedCosts =
      i.itemCost + i.shippingCost + i.operationalCosts + i.fixedListingFee;
  final breakeven = variableFraction <= 0
      ? double.infinity
      : fixedCosts / variableFraction;

  return CalcResult(
    netProfit: netProfit,
    marginPct: marginPct,
    roiPct: roiPct,
    commissionAmount: commission,
    vatAmount: vat,
    totalCosts: totalCosts,
    breakevenPrice: breakeven,
  );
}
