import '../data/marketplace.dart';

/// Presentation-side helper that maps a [Marketplace.id] to an emoji
/// shown in the Calm chip / picker rows. Kept separate from the data
/// model so the marketplace catalogue stays free of UI concerns.
String emojiFor(Marketplace m) {
  switch (m.id) {
    case 'amazon-us':
      return '🇺🇸';
    case 'shopify':
      return '🌐';
    case 'custom':
      return '⚙';
  }
  if (m.region == MarketplaceRegion.tr) return '🇹🇷';
  return '🌐';
}
