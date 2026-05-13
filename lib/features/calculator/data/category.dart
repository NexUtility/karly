import '../../../l10n/generated/app_localizations.dart';

/// Top-level item categories shown in the category picker.
///
/// Designed to be marketplace-agnostic — a single set that covers
/// everything a small seller would list on Trendyol, Hepsiburada, n11,
/// Çiçek Sepeti, Amazon, Etsy, eBay, or Shopify. The user picks once
/// per calculation and can later filter History by this value.
///
/// String identifiers are persisted, so adding new categories is safe
/// but renaming existing ones requires a data migration.
enum Category {
  electronics('electronics'),
  phones('phones'),
  computers('computers'),
  tvAudio('tv-audio'),
  fashion('fashion'),
  shoes('shoes'),
  bags('bags'),
  jewelryWatches('jewelry-watches'),
  beauty('beauty'),
  health('health'),
  homeLiving('home-living'),
  kitchen('kitchen'),
  furniture('furniture'),
  garden('garden'),
  sports('sports'),
  automotive('automotive'),
  tools('tools'),
  toys('toys'),
  babyKids('baby-kids'),
  pet('pet'),
  books('books'),
  stationery('stationery'),
  food('food'),
  supermarket('supermarket'),
  hobby('hobby'),
  handmade('handmade'),
  art('art'),
  digital('digital'),
  other('other');

  const Category(this.id);

  /// Stable identifier used for storage. Never change after release.
  final String id;

  static Category? byId(String? id) {
    if (id == null) return null;
    for (final c in Category.values) {
      if (c.id == id) return c;
    }
    return null;
  }

  String displayName(AppLocalizations l10n) {
    switch (this) {
      case Category.electronics:
        return l10n.categoryElectronics;
      case Category.phones:
        return l10n.categoryPhones;
      case Category.computers:
        return l10n.categoryComputers;
      case Category.tvAudio:
        return l10n.categoryTvAudio;
      case Category.fashion:
        return l10n.categoryFashion;
      case Category.shoes:
        return l10n.categoryShoes;
      case Category.bags:
        return l10n.categoryBags;
      case Category.jewelryWatches:
        return l10n.categoryJewelryWatches;
      case Category.beauty:
        return l10n.categoryBeauty;
      case Category.health:
        return l10n.categoryHealth;
      case Category.homeLiving:
        return l10n.categoryHomeLiving;
      case Category.kitchen:
        return l10n.categoryKitchen;
      case Category.furniture:
        return l10n.categoryFurniture;
      case Category.garden:
        return l10n.categoryGarden;
      case Category.sports:
        return l10n.categorySports;
      case Category.automotive:
        return l10n.categoryAutomotive;
      case Category.tools:
        return l10n.categoryTools;
      case Category.toys:
        return l10n.categoryToys;
      case Category.babyKids:
        return l10n.categoryBabyKids;
      case Category.pet:
        return l10n.categoryPet;
      case Category.books:
        return l10n.categoryBooks;
      case Category.stationery:
        return l10n.categoryStationery;
      case Category.food:
        return l10n.categoryFood;
      case Category.supermarket:
        return l10n.categorySupermarket;
      case Category.hobby:
        return l10n.categoryHobby;
      case Category.handmade:
        return l10n.categoryHandmade;
      case Category.art:
        return l10n.categoryArt;
      case Category.digital:
        return l10n.categoryDigital;
      case Category.other:
        return l10n.categoryOther;
    }
  }
}
