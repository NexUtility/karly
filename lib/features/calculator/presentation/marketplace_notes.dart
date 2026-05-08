import '../../../l10n/generated/app_localizations.dart';
import '../data/marketplace.dart';

/// Returns the localized fee/commission note for a marketplace, or
/// `null` when the marketplace has no extra commentary worth surfacing.
///
/// Notes are presentation strings, not data — they live here instead of
/// on the [Marketplace] config so adding a new locale doesn't require
/// touching the marketplace presets.
String? marketplaceNotesFor(Marketplace marketplace, AppLocalizations l10n) {
  switch (marketplace.id) {
    case 'trendyol':
      return l10n.marketplaceNotesTrendyol;
    case 'hepsiburada':
      return l10n.marketplaceNotesHepsiburada;
    case 'amazon-us':
      return l10n.marketplaceNotesAmazonUs;
    case 'etsy':
      return l10n.marketplaceNotesEtsy;
    case 'ebay':
      return l10n.marketplaceNotesEbay;
    case 'shopify':
      return l10n.marketplaceNotesShopify;
    case 'custom':
      return l10n.marketplaceNotesCustom;
    default:
      return null;
  }
}
