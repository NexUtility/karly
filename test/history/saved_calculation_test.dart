import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:karly/features/calculator/domain/calculate.dart';
import 'package:karly/features/calculator/domain/inputs.dart';
import 'package:karly/features/history/data/saved_calculation.dart';

void main() {
  group('SavedCalculation JSON roundtrip', () {
    test('preserves inputs, result, and metadata exactly', () {
      const inputs = CalcInputs(
        itemName: 'Black hoodie XL',
        categoryId: 'fashion',
        itemCost: 100,
        sellPrice: 200,
        commissionRate: 0.18,
        shippingCost: 10,
        operationalCosts: 5,
        vatRate: 0.20,
        currency: 'TRY',
      );
      final result = calculateProfit(inputs);
      final entry = SavedCalculation(
        id: 'test-id',
        savedAt: DateTime.utc(2026, 5, 13, 10, 30),
        marketplaceId: 'trendyol',
        inputs: inputs,
        result: result,
      );

      final json = entry.toJson();
      final encoded = jsonEncode(json);
      final decoded =
          SavedCalculation.fromJson(jsonDecode(encoded) as Map<String, dynamic>);

      expect(decoded.id, 'test-id');
      expect(decoded.savedAt, DateTime.utc(2026, 5, 13, 10, 30));
      expect(decoded.marketplaceId, 'trendyol');
      expect(decoded.categoryId, 'fashion');
      expect(decoded.itemName, 'Black hoodie XL');
      expect(decoded.inputs.itemCost, 100);
      expect(decoded.inputs.sellPrice, 200);
      expect(decoded.inputs.commissionRate, closeTo(0.18, 1e-9));
      expect(decoded.inputs.vatRate, closeTo(0.20, 1e-9));
      expect(decoded.result.netProfit, closeTo(result.netProfit, 1e-9));
      expect(decoded.result.marginPct, closeTo(result.marginPct, 1e-9));
    });

    test('survives infinite breakeven price', () {
      const inputs = CalcInputs(
        itemCost: 10,
        sellPrice: 100,
        commissionRate: 0.6,
        vatRate: 0.4,
      );
      final result = calculateProfit(inputs);
      expect(result.breakevenPrice, double.infinity);

      final entry = SavedCalculation(
        id: '1',
        savedAt: DateTime.utc(2026, 1, 1),
        marketplaceId: 'custom',
        inputs: inputs,
        result: result,
      );
      final roundTrip = SavedCalculation.fromJson(
        jsonDecode(jsonEncode(entry.toJson())) as Map<String, dynamic>,
      );
      expect(roundTrip.result.breakevenPrice, double.infinity);
    });

    test('null category and item name are preserved', () {
      const inputs = CalcInputs(
        itemCost: 50,
        sellPrice: 100,
        commissionRate: 0.1,
      );
      final result = calculateProfit(inputs);
      final entry = SavedCalculation(
        id: '2',
        savedAt: DateTime.utc(2026, 1, 1),
        marketplaceId: 'custom',
        inputs: inputs,
        result: result,
      );
      final roundTrip = SavedCalculation.fromJson(
        jsonDecode(jsonEncode(entry.toJson())) as Map<String, dynamic>,
      );
      expect(roundTrip.categoryId, isNull);
      expect(roundTrip.itemName, isNull);
    });
  });
}
