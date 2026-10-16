import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/repositories/product_catalog.dart';

/// Real products sold in Pakistan, used to build routines.
///
/// Prices are a GUIDE in rupees, taken from Pakistani online shops and price
/// comparison sites (derma.pk, qeemat.com.pk, foodpanda.pk, brand stores) in
/// October 2026. Shops differ and prices move, so the app shows them as "about"
/// and always sends the user to a shop to check. Prices marked "estimate" had
/// no Pakistani listing and follow the brand's other products there.
///
/// Ingredient flags are simplified (the clash rules need only a few actives) and
/// follow each product's published formula; they still need a dermatologist's
/// review before release (see handoff.md). When the formula was not confirmed,
/// the product is NOT marked fragrance-free.
class RealProductCatalog implements ProductCatalog {
  const RealProductCatalog();

  /// When the prices above were looked up.
  static final DateTime pricesCheckedOn = DateTime(2026, 10, 17);

  static const _both = {RoutineTime.morning, RoutineTime.night};
  static const _morning = {RoutineTime.morning};
  static const _night = {RoutineTime.night};

  static const List<Product> products = [
    // ── Cleansers ──────────────────────────────────────────────────────────
    Product(
      id: 'cleanser-himalaya-neem',
      name: 'Himalaya Purifying Neem Face Wash',
      category: ProductCategory.cleanser,
      pricePkr: 540,
      times: _both,
      skinTypes: {SkinType.oily, SkinType.combination},
      targets: {SkinConcern.acne, SkinConcern.oiliness},
    ),
    Product(
      id: 'cleanser-garnier-neem',
      name: 'Garnier Pure Active Neem Face Wash',
      category: ProductCategory.cleanser,
      pricePkr: 600,
      times: _both,
      skinTypes: {SkinType.oily, SkinType.combination},
      targets: {SkinConcern.acne, SkinConcern.oiliness},
    ),
    Product(
      id: 'cleanser-simple-gel',
      name: 'Simple Kind to Skin Refreshing Facial Wash Gel',
      category: ProductCategory.cleanser,
      pricePkr: 1380,
      times: _both,
      fragranceFree: true,
    ),
    Product(
      id: 'cleanser-cetaphil-gentle',
      name: 'Cetaphil Gentle Skin Cleanser',
      category: ProductCategory.cleanser,
      pricePkr: 5249,
      times: _both,
      skinTypes: {SkinType.dry, SkinType.normal},
      targets: {SkinConcern.dryness},
      fragranceFree: true,
    ),
    Product(
      id: 'cleanser-cerave-foaming',
      name: 'CeraVe Foaming Facial Cleanser',
      category: ProductCategory.cleanser,
      pricePkr: 5775,
      times: _both,
      skinTypes: {SkinType.oily, SkinType.combination},
      targets: {SkinConcern.oiliness, SkinConcern.acne},
      ingredients: {Ingredient.ceramides, Ingredient.hyaluronicAcid},
      fragranceFree: true,
    ),
    Product(
      id: 'cleanser-cerave-hydrating',
      name: 'CeraVe Hydrating Facial Cleanser',
      category: ProductCategory.cleanser,
      pricePkr: 6195,
      times: _both,
      skinTypes: {SkinType.dry, SkinType.normal},
      targets: {SkinConcern.dryness},
      ingredients: {Ingredient.ceramides, Ingredient.hyaluronicAcid},
      fragranceFree: true,
    ),

    // ── Treatments (The Ordinary: fragrance-free, simple single actives) ───
    Product(
      id: 'treatment-to-niacinamide-zinc',
      name: 'The Ordinary Niacinamide 10% + Zinc 1%',
      category: ProductCategory.treatment,
      pricePkr: 3500, // estimate
      times: _both,
      ingredients: {Ingredient.niacinamide, Ingredient.zinc},
      targets: {SkinConcern.oiliness, SkinConcern.acne, SkinConcern.unevenTone},
      fragranceFree: true,
    ),
    Product(
      id: 'treatment-to-vitamin-c',
      name: 'The Ordinary Ascorbyl Glucoside Solution 12%',
      category: ProductCategory.treatment,
      pricePkr: 3500, // estimate
      times: _morning,
      ingredients: {Ingredient.vitaminC},
      targets: {SkinConcern.darkSpots, SkinConcern.unevenTone},
      isStrongActive: true,
      fragranceFree: true,
    ),
    Product(
      id: 'treatment-to-hyaluronic',
      name: 'The Ordinary Hyaluronic Acid 2% + B5',
      category: ProductCategory.treatment,
      pricePkr: 4100,
      times: _both,
      ingredients: {Ingredient.hyaluronicAcid},
      targets: {SkinConcern.dryness},
      fragranceFree: true,
    ),
    Product(
      id: 'treatment-to-salicylic',
      name: 'The Ordinary Salicylic Acid 2% Solution',
      category: ProductCategory.treatment,
      pricePkr: 5450,
      times: _night,
      ingredients: {Ingredient.salicylicAcid},
      targets: {SkinConcern.acne, SkinConcern.oiliness},
      isStrongActive: true,
      avoidInPregnancy: true,
      fragranceFree: true,
    ),
    Product(
      id: 'treatment-to-retinol',
      name: 'The Ordinary Retinol 0.5% in Squalane',
      category: ProductCategory.treatment,
      pricePkr: 5450,
      times: _night,
      ingredients: {Ingredient.retinol},
      targets: {
        SkinConcern.darkSpots,
        SkinConcern.acne,
        SkinConcern.unevenTone,
      },
      isStrongActive: true,
      avoidInPregnancy: true,
      fragranceFree: true,
    ),
    Product(
      id: 'treatment-to-azelaic',
      name: 'The Ordinary Azelaic Acid Suspension 10%',
      category: ProductCategory.treatment,
      pricePkr: 3150,
      times: _night,
      ingredients: {Ingredient.azelaicAcid},
      targets: {
        SkinConcern.darkSpots,
        SkinConcern.acne,
        SkinConcern.unevenTone,
      },
      fragranceFree: true,
    ),

    // ── Moisturisers ───────────────────────────────────────────────────────
    Product(
      id: 'moisturiser-nivea-soft',
      name: 'Nivea Soft Moisturising Cream',
      category: ProductCategory.moisturiser,
      pricePkr: 1800,
      times: _both,
      skinTypes: {SkinType.normal, SkinType.combination},
    ),
    Product(
      id: 'moisturiser-simple-light',
      name: 'Simple Hydrating Light Moisturiser',
      category: ProductCategory.moisturiser,
      pricePkr: 3000,
      times: _both,
      skinTypes: {SkinType.combination, SkinType.normal},
      fragranceFree: true,
    ),
    Product(
      id: 'moisturiser-hydro-boost',
      name: 'Neutrogena Hydro Boost Water Gel',
      category: ProductCategory.moisturiser,
      pricePkr: 4395,
      times: _both,
      skinTypes: {SkinType.oily, SkinType.combination, SkinType.normal},
      targets: {SkinConcern.oiliness},
      ingredients: {Ingredient.hyaluronicAcid},
    ),
    Product(
      id: 'moisturiser-cetaphil-cream',
      name: 'Cetaphil Moisturizing Cream (fragrance-free)',
      category: ProductCategory.moisturiser,
      pricePkr: 5396,
      times: _both,
      skinTypes: {SkinType.dry, SkinType.normal},
      targets: {SkinConcern.dryness},
      fragranceFree: true,
    ),
    Product(
      id: 'moisturiser-cerave-cream',
      name: 'CeraVe Moisturising Cream',
      category: ProductCategory.moisturiser,
      pricePkr: 5400,
      times: _both,
      skinTypes: {SkinType.dry},
      targets: {SkinConcern.dryness},
      ingredients: {Ingredient.ceramides, Ingredient.hyaluronicAcid},
      fragranceFree: true,
    ),

    // ── Sunscreens ─────────────────────────────────────────────────────────
    Product(
      id: 'sunscreen-daneen-spf60',
      name: 'Daneen Advance Sun Block SPF 60',
      category: ProductCategory.sunscreen,
      pricePkr: 1100,
      times: _morning,
    ),
    Product(
      id: 'sunscreen-kashees-glow',
      name: 'Kashee’s Derma Glow SPF 50',
      category: ProductCategory.sunscreen,
      pricePkr: 1350,
      times: _morning,
    ),
    Product(
      id: 'sunscreen-cosmotics-hydrator',
      name: 'Cosmotics Hydrator SPF 50 Sunscreen Lotion',
      category: ProductCategory.sunscreen,
      pricePkr: 1800,
      times: _morning,
      skinTypes: {SkinType.dry, SkinType.normal},
      targets: {SkinConcern.dryness},
    ),
    Product(
      id: 'sunscreen-davis-oil-control',
      name: 'Davis & Co Oil Control SPF 50',
      category: ProductCategory.sunscreen,
      pricePkr: 2800,
      times: _morning,
      skinTypes: {SkinType.oily, SkinType.combination},
      targets: {SkinConcern.oiliness, SkinConcern.acne},
    ),
    Product(
      id: 'sunscreen-biore-aqua-rich',
      name: 'Bioré UV Aqua Rich Watery Essence SPF 50+',
      category: ProductCategory.sunscreen,
      pricePkr: 4932,
      times: _morning,
    ),
  ];

  @override
  Future<List<Product>> all() async => products;
}
