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
    this.itemName,
    this.categoryId,
    this.shippingCost = 0,
    this.operationalCosts = 0,
    this.fixedListingFee = 0,
    this.vatRate = 0,
    this.currency = 'USD',
  });

  /// Optional human-readable name of the item being sold (e.g. "Black hoodie XL").
  /// Shown in the PDF report header and the History list.
  final String? itemName;

  /// Optional category id drawn from [Category.id]. Persisted on
  /// saved entries and used as the History filter key.
  final String? categoryId;

  final double itemCost;
  final double sellPrice;

  /// Commission as a decimal fraction (0.18 = 18%).
  final double commissionRate;

  final double shippingCost;

  /// Per-sale operational costs that aren't already separate fields —
  /// ad spend, packaging, returns, fulfillment, etc. The user enters
  /// the total they want to allocate to this single sale.
  final double operationalCosts;

  final double fixedListingFee;

  /// VAT / KDV as a decimal fraction (0.20 = 20%).
  final double vatRate;

  /// ISO 4217 currency code.
  final String currency;

  CalcInputs copyWith({
    String? itemName,
    String? categoryId,
    double? itemCost,
    double? sellPrice,
    double? commissionRate,
    double? shippingCost,
    double? operationalCosts,
    double? fixedListingFee,
    double? vatRate,
    String? currency,
  }) {
    return CalcInputs(
      itemName: itemName ?? this.itemName,
      categoryId: categoryId ?? this.categoryId,
      itemCost: itemCost ?? this.itemCost,
      sellPrice: sellPrice ?? this.sellPrice,
      commissionRate: commissionRate ?? this.commissionRate,
      shippingCost: shippingCost ?? this.shippingCost,
      operationalCosts: operationalCosts ?? this.operationalCosts,
      fixedListingFee: fixedListingFee ?? this.fixedListingFee,
      vatRate: vatRate ?? this.vatRate,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'categoryId': categoryId,
        'itemCost': itemCost,
        'sellPrice': sellPrice,
        'commissionRate': commissionRate,
        'shippingCost': shippingCost,
        'operationalCosts': operationalCosts,
        'fixedListingFee': fixedListingFee,
        'vatRate': vatRate,
        'currency': currency,
      };

  factory CalcInputs.fromJson(Map<String, dynamic> json) => CalcInputs(
        itemName: json['itemName'] as String?,
        categoryId: json['categoryId'] as String?,
        itemCost: (json['itemCost'] as num).toDouble(),
        sellPrice: (json['sellPrice'] as num).toDouble(),
        commissionRate: (json['commissionRate'] as num).toDouble(),
        shippingCost: (json['shippingCost'] as num? ?? 0).toDouble(),
        operationalCosts: (json['operationalCosts'] as num? ?? 0).toDouble(),
        fixedListingFee: (json['fixedListingFee'] as num? ?? 0).toDouble(),
        vatRate: (json['vatRate'] as num? ?? 0).toDouble(),
        currency: json['currency'] as String? ?? 'USD',
      );
}
