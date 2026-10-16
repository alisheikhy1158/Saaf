import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';

/// What was found in an ingredient list.
class IngredientReading {
  const IngredientReading({
    required this.actives,
    required this.hasFragrance,
    required this.knownList,
  });

  /// The actives the advice rules care about.
  final Set<Ingredient> actives;

  /// Perfume ("Parfum", "Fragrance") is listed.
  final bool hasFragrance;

  /// There was a list to read at all. Without one nothing can be said, and a
  /// product must NOT be called fragrance-free.
  final bool knownList;
}

/// Reads a printed (INCI) ingredient list, e.g. from Open Beauty Facts, into
/// the few actives that change advice. Conservative: it counts only strong
/// forms, so a trace of a pH adjuster (citric acid, sodium lactate) or a mild
/// ester (retinyl palmitate) does not make a product a "strong active".
class IngredientReader {
  const IngredientReader();

  IngredientReading read(String? list) {
    final tokens = _tokens(list);
    final actives = <Ingredient>{};
    for (final token in tokens) {
      final ingredient = _active(token);
      if (ingredient != null) actives.add(ingredient);
    }
    return IngredientReading(
      actives: actives,
      hasFragrance: tokens.any(_isFragrance),
      knownList: tokens.isNotEmpty,
    );
  }

  /// The kind of product, from the shop tags first and then its name.
  ProductCategory category({
    required String name,
    List<String> categoryTags = const [],
  }) {
    final tags = categoryTags.join(' ').toLowerCase();
    final words = name.toLowerCase();
    bool any(Iterable<String> keys, String text) => keys.any(text.contains);

    const sun = ['sunscreen', 'sun-protection', 'sunblock', 'sun block', 'spf'];
    const clean = [
      'cleanser',
      'cleansing',
      'face wash',
      'facewash',
      'micellar',
      'foam',
    ];
    const treat = [
      'serum',
      'treatment',
      'ampoule',
      'essence',
      'acid',
      'retinol',
      'spot',
    ];
    const moist = ['moisturi', 'cream', 'lotion', 'gel'];

    if (any(sun, tags) || any(sun, words)) return ProductCategory.sunscreen;
    if (any(clean, tags) || any(clean, words)) return ProductCategory.cleanser;
    if (any(treat, tags) || any(treat, words)) return ProductCategory.treatment;
    if (any(moist, tags) || any(moist, words)) {
      return ProductCategory.moisturiser;
    }
    return ProductCategory.moisturiser;
  }

  static List<String> _tokens(String? list) {
    if (list == null) return const [];
    return list
        .toUpperCase()
        .split(RegExp(r'[,;./\n]'))
        .map((t) => t.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  static Ingredient? _active(String t) {
    if (t == 'NIACINAMIDE') return Ingredient.niacinamide;
    if (t.startsWith('CERAMIDE')) return Ingredient.ceramides;
    if (t.contains('HYALURONIC ACID') || t.contains('HYALURONATE')) {
      return Ingredient.hyaluronicAcid;
    }
    if (t == 'SALICYLIC ACID') return Ingredient.salicylicAcid;
    if (t == 'AZELAIC ACID') return Ingredient.azelaicAcid;
    if (t == 'BENZOYL PEROXIDE') return Ingredient.benzoylPeroxide;
    if (const {
      'RETINOL',
      'RETINAL',
      'RETINALDEHYDE',
      'ADAPALENE',
      'TRETINOIN',
    }.contains(t)) {
      return Ingredient.retinol;
    }
    if (const {
      'ASCORBIC ACID',
      'L-ASCORBIC ACID',
      'ETHYL ASCORBIC ACID',
      '3-O-ETHYL ASCORBIC ACID',
      'ASCORBYL GLUCOSIDE',
      'SODIUM ASCORBYL PHOSPHATE',
      'MAGNESIUM ASCORBYL PHOSPHATE',
      'TETRAHEXYLDECYL ASCORBATE',
    }.contains(t)) {
      return Ingredient.vitaminC;
    }
    if (const {'GLYCOLIC ACID', 'LACTIC ACID', 'MANDELIC ACID'}.contains(t)) {
      return Ingredient.aha;
    }
    if (const {'ZINC PCA', 'ZINC GLUCONATE', 'ZINC SULFATE'}.contains(t)) {
      return Ingredient.zinc;
    }
    return null;
  }

  static bool _isFragrance(String t) =>
      t.contains('PARFUM') || t == 'FRAGRANCE' || t == 'AROMA';
}
