import 'package:flutter_test/flutter_test.dart';
import 'package:karly/features/calculator/domain/calculate.dart';
import 'package:karly/features/calculator/domain/inputs.dart';

void main() {
  group('calculateProfit', () {
    test('zero costs and zero sale gives zero profit', () {
      const inputs = CalcInputs(
        itemCost: 0,
        sellPrice: 0,
        commissionRate: 0,
      );
      final r = calculateProfit(inputs);
      expect(r.netProfit, 0);
      expect(r.marginPct, 0);
      expect(r.roiPct, 0);
      expect(r.isLoss, isFalse);
    });

    test('simple Trendyol-like calculation: 100 TRY cost, 200 sell, 18% comm, 20% KDV', () {
      const inputs = CalcInputs(
        itemCost: 100,
        sellPrice: 200,
        commissionRate: 0.18,
        vatRate: 0.20,
        currency: 'TRY',
      );
      final r = calculateProfit(inputs);
      expect(r.commissionAmount, closeTo(36, 0.001));
      expect(r.vatAmount, closeTo(40, 0.001));
      expect(r.netProfit, closeTo(24, 0.001));
      expect(r.marginPct, closeTo(12, 0.001));
      expect(r.roiPct, closeTo(24, 0.001));
      expect(r.isLoss, isFalse);
    });

    test('flags loss when costs exceed revenue', () {
      const inputs = CalcInputs(
        itemCost: 80,
        sellPrice: 100,
        commissionRate: 0.30,
        shippingCost: 10,
      );
      final r = calculateProfit(inputs);
      expect(r.netProfit, lessThan(0));
      expect(r.isLoss, isTrue);
    });

    test('Etsy fixed listing fee is added on top of commission', () {
      const inputs = CalcInputs(
        itemCost: 5,
        sellPrice: 20,
        commissionRate: 0.065,
        fixedListingFee: 0.20,
        currency: 'USD',
      );
      final r = calculateProfit(inputs);
      // commission = 20 * 0.065 + 0.20 = 1.50
      expect(r.commissionAmount, closeTo(1.50, 0.001));
      // net = 20 - 5 - 1.50 = 13.50
      expect(r.netProfit, closeTo(13.50, 0.001));
    });

    test('breakeven price covers all costs at zero profit', () {
      const inputs = CalcInputs(
        itemCost: 50,
        sellPrice: 0, // not used in breakeven
        commissionRate: 0.20,
        vatRate: 0.20,
        shippingCost: 10,
      );
      final r = calculateProfit(inputs);
      // (50 + 10) / (1 - 0.20 - 0.20) = 60 / 0.6 = 100
      expect(r.breakevenPrice, closeTo(100, 0.001));
    });

    test('breakeven is infinity when commission + vat consume entire revenue', () {
      const inputs = CalcInputs(
        itemCost: 10,
        sellPrice: 100,
        commissionRate: 0.6,
        vatRate: 0.4,
      );
      final r = calculateProfit(inputs);
      expect(r.breakevenPrice, double.infinity);
    });
  });
}
