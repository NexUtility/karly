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
    notes: 'Category-specific rates apply. KDV/VAT charged separately.',
  ),
  Marketplace(
    id: 'hepsiburada',
    name: 'Hepsiburada',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.155,
    notes: 'Category-specific rates apply.',
  ),
  Marketplace(
    id: 'n11',
    name: 'n11',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.13,
  ),
  Marketplace(
    id: 'ciceksepeti',
    name: 'Çiçek Sepeti',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.18,
  ),
  Marketplace(
    id: 'pazarama',
    name: 'Pazarama',
    region: MarketplaceRegion.tr,
    defaultCurrency: 'TRY',
    defaultCommissionRate: 0.12,
  ),

  // --- Global ---
  Marketplace(
    id: 'amazon-us',
    name: 'Amazon US',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0.15,
    notes: 'Referral fee. FBA fees not included by default.',
  ),
  Marketplace(
    id: 'etsy',
    name: 'Etsy',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0.065,
    fixedListingFee: 0.20,
    notes: '6.5% transaction + \$0.20 listing fee. Payment processing extra.',
  ),
  Marketplace(
    id: 'ebay',
    name: 'eBay',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0.135,
    notes: 'Final value fee — varies by category.',
  ),
  Marketplace(
    id: 'shopify',
    name: 'Shopify (own store)',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0.029,
    notes: '2.9% + \$0.30 payment processing on Shopify Payments.',
  ),
  Marketplace(
    id: 'custom',
    name: 'Custom',
    region: MarketplaceRegion.global,
    defaultCurrency: 'USD',
    defaultCommissionRate: 0,
    notes: 'Set commission and fees manually.',
  ),
];
