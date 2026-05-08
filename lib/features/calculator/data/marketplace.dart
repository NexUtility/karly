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
    this.fixedListingFee = 0,
    this.notes,
  });

  /// Stable identifier used in storage.
  final String id;

  /// Display name (e.g. "Trendyol", "Amazon US").
  final String name;

  final MarketplaceRegion region;

  /// ISO 4217 currency code (TRY, USD, EUR, ...).
  final String defaultCurrency;

  /// Default commission as a decimal fraction (0.18 = 18%).
  final double defaultCommissionRate;

  /// Fixed per-listing fee in the marketplace's default currency
  /// (e.g. Etsy's $0.20 listing fee).
  final double fixedListingFee;

  /// Free-form notes (e.g. "+ KDV", "Per-category rates vary").
  final String? notes;
}

enum MarketplaceRegion { tr, global }
