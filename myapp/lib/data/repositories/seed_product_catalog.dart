import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/repositories/product_catalog.dart';

/// PLACEHOLDER catalogue. Generic product descriptions with ballpark Pakistani
/// prices (PKR) so the routine can be built and tested end to end. The real
/// catalogue (named products, current prices, buy links) comes from the backend
/// later; ingredient flags here are simplified and must be reviewed with a
/// dermatologist before release (see handoff.md).
class SeedProductCatalog implements ProductCatalog {
  const SeedProductCatalog();

  static const _both = {RoutineTime.morning, RoutineTime.night};
  static const _morning = {RoutineTime.morning};
  static const _night = {RoutineTime.night};

  static const List<Product> products = [
    // Cleansers
    Product(
      id: 'cleanser-neem',
      name: 'Neem Face Wash',
      category: ProductCategory.cleanser,
      pricePkr: 650,
      times: _both,
      skinTypes: {SkinType.oily, SkinType.combination},
      targets: {SkinConcern.acne, SkinConcern.oiliness},
    ),
    Product(
      id: 'cleanser-cream',
      name: 'Gentle Cream Cleanser',
      category: ProductCategory.cleanser,
      pricePkr: 700,
      times: _both,
      skinTypes: {SkinType.dry, SkinType.normal},
      targets: {SkinConcern.dryness},
      fragranceFree: true,
    ),
    Product(
      id: 'cleanser-gel',
      name: 'Gel Cleanser',
      category: ProductCategory.cleanser,
      pricePkr: 600,
      times: _both,
      fragranceFree: true,
    ),

    // Treatments
    Product(
      id: 'treatment-niacinamide',
      name: 'Niacinamide Serum',
      category: ProductCategory.treatment,
      pricePkr: 1450,
      times: _both,
      ingredients: {Ingredient.niacinamide},
      targets: {
        SkinConcern.darkSpots,
        SkinConcern.oiliness,
        SkinConcern.unevenTone,
      },
      fragranceFree: true,
    ),
    Product(
      id: 'treatment-vitamin-c',
      name: 'Vitamin C Serum',
      category: ProductCategory.treatment,
      pricePkr: 1900,
      times: _morning,
      ingredients: {Ingredient.vitaminC},
      targets: {SkinConcern.darkSpots, SkinConcern.unevenTone},
      isStrongActive: true,
    ),
    Product(
      id: 'treatment-hyaluronic',
      name: 'Hyaluronic Acid Serum',
      category: ProductCategory.treatment,
      pricePkr: 1300,
      times: _both,
      ingredients: {Ingredient.hyaluronicAcid},
      targets: {SkinConcern.dryness},
      fragranceFree: true,
    ),
    Product(
      id: 'treatment-salicylic',
      name: 'Salicylic Acid Treatment',
      category: ProductCategory.treatment,
      pricePkr: 1200,
      times: _night,
      ingredients: {Ingredient.salicylicAcid},
      targets: {SkinConcern.acne, SkinConcern.oiliness},
      isStrongActive: true,
      avoidInPregnancy: true,
    ),
    Product(
      id: 'treatment-retinol',
      name: 'Retinol Night Serum',
      category: ProductCategory.treatment,
      pricePkr: 2200,
      times: _night,
      ingredients: {Ingredient.retinol},
      targets: {
        SkinConcern.darkSpots,
        SkinConcern.acne,
        SkinConcern.unevenTone,
      },
      isStrongActive: true,
      avoidInPregnancy: true,
    ),
    Product(
      id: 'treatment-azelaic',
      name: 'Azelaic Acid Serum',
      category: ProductCategory.treatment,
      pricePkr: 1800,
      times: _night,
      ingredients: {Ingredient.azelaicAcid},
      targets: {
        SkinConcern.darkSpots,
        SkinConcern.acne,
        SkinConcern.unevenTone,
      },
      fragranceFree: true,
    ),
    Product(
      id: 'treatment-barrier',
      name: 'Barrier Repair Night Cream',
      category: ProductCategory.treatment,
      pricePkr: 1700,
      times: _night,
      ingredients: {Ingredient.ceramides},
      targets: {SkinConcern.dryness},
      fragranceFree: true,
    ),

    // Moisturisers
    Product(
      id: 'moisturiser-gel',
      name: 'Oil-free Gel Moisturiser',
      category: ProductCategory.moisturiser,
      pricePkr: 1100,
      times: _both,
      skinTypes: {SkinType.oily, SkinType.combination},
      targets: {SkinConcern.oiliness},
    ),
    Product(
      id: 'moisturiser-rich',
      name: 'Rich Barrier Cream',
      category: ProductCategory.moisturiser,
      pricePkr: 1400,
      times: _both,
      skinTypes: {SkinType.dry},
      targets: {SkinConcern.dryness},
      fragranceFree: true,
    ),
    Product(
      id: 'moisturiser-light',
      name: 'Light Everyday Lotion',
      category: ProductCategory.moisturiser,
      pricePkr: 1000,
      times: _both,
      fragranceFree: true,
    ),

    // Sunscreens
    Product(
      id: 'sunscreen-matte',
      name: 'Matte SPF 50 Sunscreen',
      category: ProductCategory.sunscreen,
      pricePkr: 1850,
      times: _morning,
      skinTypes: {SkinType.oily, SkinType.combination},
      targets: {SkinConcern.oiliness, SkinConcern.acne},
    ),
    Product(
      id: 'sunscreen-hydrating',
      name: 'Hydrating SPF 50 Sunscreen',
      category: ProductCategory.sunscreen,
      pricePkr: 1750,
      times: _morning,
      skinTypes: {SkinType.dry, SkinType.normal},
      targets: {SkinConcern.dryness},
    ),
    Product(
      id: 'sunscreen-mineral',
      name: 'Mineral SPF 50 Sunscreen',
      category: ProductCategory.sunscreen,
      pricePkr: 2000,
      times: _morning,
      fragranceFree: true,
    ),
    Product(
      id: 'sunscreen-everyday',
      name: 'Everyday SPF 30 Sunscreen',
      category: ProductCategory.sunscreen,
      pricePkr: 900,
      times: _morning,
      fragranceFree: true,
    ),
  ];

  @override
  Future<List<Product>> all() async => products;
}
