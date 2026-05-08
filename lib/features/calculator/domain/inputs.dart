import 'package:flutter/foundation.dart';

/// Inputs the user provides on the calculator screen.
///
/// All monetary fields are in the same currency. VAT and commission
/// are decimal fractions (0.18 == 18%).
@immutable
class CalcInputs {
  const CalcInputs({
    required this.itemCost,
    required this.sellPrice,
    required this.commissionRate,
    this.shippingCost = 0,
    this.adSpend = 0,
    this.fixedListingFee = 0,
    this.vatRate = 0,
    this.currency = 'USD',
  });

  final double itemCost;
  final double sellPrice;

  /// Commission as a decimal fraction (0.18 = 18%).
  final double commissionRate;

  final double shippingCost;
  final double adSpend;
  final double fixedListingFee;

  /// VAT / KDV as a decimal fraction (0.20 = 20%).
  final double vatRate;

  /// ISO 4217 currency code.
  final String currency;

  CalcInputs copyWith({
    double? itemCost,
    double? sellPrice,
    double? commissionRate,
    double? shippingCost,
    double? adSpend,
    double? fixedListingFee,
    double? vatRate,
    String? currency,
  }) {
    return CalcInputs(
      itemCost: itemCost ?? this.itemCost,
      sellPrice: sellPrice ?? this.sellPrice,
      commissionRate: commissionRate ?? this.commissionRate,
      shippingCost: shippingCost ?? this.shippingCost,
      adSpend: adSpend ?? this.adSpend,
      fixedListingFee: fixedListingFee ?? this.fixedListingFee,
      vatRate: vatRate ?? this.vatRate,
      currency: currency ?? this.currency,
    );
  }
}
