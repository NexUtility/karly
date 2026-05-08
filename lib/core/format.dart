import 'package:intl/intl.dart';

/// Formats a numeric amount with the user's locale and a currency symbol.
String formatCurrency(double amount, {String currency = 'USD', String? locale}) {
  final fmt = NumberFormat.currency(
    locale: locale,
    name: currency,
    symbol: _symbolFor(currency),
    decimalDigits: 2,
  );
  return fmt.format(amount);
}

/// Formats a value as a percentage with one decimal (e.g. "18.5%").
String formatPercent(double value, {String? locale}) {
  final fmt = NumberFormat.decimalPercentPattern(
    locale: locale,
    decimalDigits: 1,
  );
  return fmt.format(value / 100);
}

String _symbolFor(String currency) {
  switch (currency.toUpperCase()) {
    case 'TRY':
      return '₺';
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    default:
      return '$currency ';
  }
}
