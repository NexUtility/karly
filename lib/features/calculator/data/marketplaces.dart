import 'marketplace.dart';

/// Default marketplace presets shipped with Kârly.
///
/// Commission rates are illustrative defaults. Real rates vary by
/// category and seller agreement — the calculator screen always lets
/// the user override the rate before computing.
const List<Marketplace> defaultMarketplaces = [
  // --- Türkiye ---
  Marketplace(
    id: 'trendyol',
    name: 'Trendyol',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.18,
    defaultVatRate: 0.20,
  ),
  Marketplace(
    id: 'hepsiburada',
    name: 'Hepsiburada',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.155,
    defaultVatRate: 0.20,
  ),
  Marketplace(
    id: 'n11',
    name: 'n11',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.13,
    defaultVatRate: 0.20,
  ),
  Marketplace(
    id: 'ciceksepeti',
    name: 'Çiçek Sepeti',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.18,
    defaultVatRate: 0.20,
  ),
  Marketplace(
    id: 'pazarama',
    name: 'Pazarama',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.12,
    defaultVatRate: 0.20,
  ),

  // --- Global ---
  Marketplace(
    id: 'amazon-us',
    name: 'Amazon US',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0.15,
  ),
  Marketplace(
    id: 'etsy',
    name: 'Etsy',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0.065,
    fixedListingFee: 0.20,
  ),
  Marketplace(
    id: 'ebay',
    name: 'eBay',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0.135,
  ),
  Marketplace(
    id: 'shopify',
    name: 'Shopify (own store)',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0.029,
  ),
  Marketplace(
    id: 'custom',
    name: 'Custom',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0,
  ),
];

/// Returns the marketplace ID we pre-select for a fresh user, based on
/// the active locale. Turkish users land on Trendyol; everyone else
/// lands on Amazon US.
String defaultMarketplaceIdFor(String languageCode) {
  return languageCode == 'tr' ? 'trendyol' : 'amazon-us';
}

/// Region-grouped marketplace list, ordered with the user's region first.
List<({MarketplaceRegion region, List<Marketplace> items})>
orderedMarketplaceSections(String languageCode) {
  final tr = defaultMarketplaces
      .where((m) => m.region == MarketplaceRegion.tr)
      .toList(growable: false);
  final global = defaultMarketplaces
      .where((m) => m.region == MarketplaceRegion.global)
      .toList(growable: false);

  if (languageCode == 'tr') {
    return [
      (region: MarketplaceRegion.tr, items: tr),
      (region: MarketplaceRegion.global, items: global),
    ];
  }
  return [
    (region: MarketplaceRegion.global, items: global),
    (region: MarketplaceRegion.tr, items: tr),
  ];
}
