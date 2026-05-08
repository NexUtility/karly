/// A marketplace where the user can sell items.
///
/// Each marketplace exposes one or more category-level commission
/// presets. The user can override the rate manually inside the
/// calculator at any time.
class Marketplace {
  const Marketplace({
    required this.id,
    required this.name,
    required this.region,
    required this.defaultCurrency,
    required this.defaultCommissionRate,
    this.defaultVatRate = 0,
    this.fixedListingFee = 0,
  });

  /// Stable identifier used in storage and as the lookup key for
  /// localized presentation strings (notes, descriptions).
  final String id;

  /// Display name (e.g. "Trendyol", "Amazon US").
  final String name;

  final MarketplaceRegion region;

  /// ISO 4217 currency code (TRY, USD, EUR, ...).
  final String defaultCurrency;

  /// Default commission as a decimal fraction (0.18 = 18%).
  final double defaultCommissionRate;

  /// Default VAT/KDV rate as a decimal fraction. Pre-filled when the
  /// user picks the marketplace; can be overridden in the form.
  /// Turkish marketplaces default to 0.20 (KDV), US/EU global ones to 0
  /// because tax handling there is item- or seller-specific.
  final double defaultVatRate;

  /// Fixed per-listing fee in the marketplace's default currency
  /// (e.g. Etsy's $0.20 listing fee).
  final double fixedListingFee;
}

enum MarketplaceRegion { tr, global }
