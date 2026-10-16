// Covers: reading a real INCI ingredient list (as printed on the pack) into the
// few actives the app's advice rules care about
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/usecases/read_ingredients.dart';

// From Open Beauty Facts: CeraVe Hydrating cream-to-foam cleanser.
const _ceraveCleanser =
    'AQUA/WATER, GLYCERIN, SODIUM METHYL COCOYL TAURATE, COCO-BETAINE, '
    'SODIUM COCOYL ISETHIONATE, SODIUM CHLORIDE, PCA, CERAMIDE NP, '
    'CERAMIDE AP, CERAMIDE EOP, SALICYLIC ACID, SODIUM PCA, SODIUM LACTATE, '
    'SODIUM HYALURONATE, PHENOXYETHANOL, CITRIC ACID, BENZOIC ACID. '
    '(F.I.L. Code D253447/1) 743563';

void main() {
  const reader = IngredientReader();

  group('actives', () {
    test('a real list: ceramides, hyaluronic acid and salicylic acid', () {
      expect(reader.read(_ceraveCleanser).actives, {
        Ingredient.ceramides,
        Ingredient.hyaluronicAcid,
        Ingredient.salicylicAcid,
      });
    });

    test('niacinamide and zinc', () {
      expect(reader.read('Aqua, Niacinamide, Zinc PCA, Glycerin').actives, {
        Ingredient.niacinamide,
        Ingredient.zinc,
      });
    });

    test('vitamin C in its common forms', () {
      for (final name in [
        'ASCORBIC ACID',
        'ASCORBYL GLUCOSIDE',
        'SODIUM ASCORBYL PHOSPHATE',
        'ETHYL ASCORBIC ACID',
        'TETRAHEXYLDECYL ASCORBATE',
      ]) {
        expect(
          reader.read('AQUA, $name').actives,
          contains(Ingredient.vitaminC),
          reason: name,
        );
      }
    });

    test('retinol and its strong cousins, but not the mild esters', () {
      expect(
        reader.read('AQUA, RETINOL').actives,
        contains(Ingredient.retinol),
      );
      expect(
        reader.read('AQUA, RETINAL').actives,
        contains(Ingredient.retinol),
      );
      expect(
        reader.read('AQUA, ADAPALENE').actives,
        contains(Ingredient.retinol),
      );
      expect(
        reader.read('AQUA, RETINYL PALMITATE, TOCOPHEROL').actives,
        isNot(contains(Ingredient.retinol)),
      );
    });

    test('exfoliating acids count, pH adjusters and salts do not', () {
      expect(
        reader.read('AQUA, GLYCOLIC ACID').actives,
        contains(Ingredient.aha),
      );
      expect(
        reader.read('AQUA, MANDELIC ACID').actives,
        contains(Ingredient.aha),
      );
      expect(
        reader.read('AQUA, LACTIC ACID').actives,
        contains(Ingredient.aha),
      );
      expect(reader.read('AQUA, CITRIC ACID, SODIUM LACTATE').actives, isEmpty);
    });

    test('azelaic acid and benzoyl peroxide', () {
      expect(
        reader.read('AQUA, AZELAIC ACID').actives,
        contains(Ingredient.azelaicAcid),
      );
      expect(
        reader.read('AQUA, BENZOYL PEROXIDE').actives,
        contains(Ingredient.benzoylPeroxide),
      );
    });

    test('zinc oxide in a sunscreen is not the zinc active', () {
      expect(
        reader.read('AQUA, ZINC OXIDE, TITANIUM DIOXIDE').actives,
        isEmpty,
      );
    });

    test('is not fooled by case, spacing or full stops', () {
      expect(
        reader.read('aqua,   niacinamide .  glycerin').actives,
        contains(Ingredient.niacinamide),
      );
    });

    test('nothing, or an empty list, means no actives', () {
      expect(reader.read(null).actives, isEmpty);
      expect(reader.read('').actives, isEmpty);
    });
  });

  group('fragrance', () {
    test('Parfum or Fragrance means fragranced', () {
      expect(reader.read('AQUA, PARFUM').hasFragrance, isTrue);
      expect(reader.read('Aqua, Fragrance, Glycerin').hasFragrance, isTrue);
      expect(reader.read('AQUA, AROMA').hasFragrance, isTrue);
    });

    test('a list without it is fragrance-free', () {
      expect(reader.read(_ceraveCleanser).hasFragrance, isFalse);
    });

    test('an unknown list is NOT called fragrance-free', () {
      expect(reader.read(null).knownList, isFalse);
      expect(reader.read('').knownList, isFalse);
      expect(reader.read(_ceraveCleanser).knownList, isTrue);
    });
  });

  group('category from the name and shop tags', () {
    ProductCategory category(String name, [List<String> tags = const []]) =>
        reader.category(name: name, categoryTags: tags);

    test('from the open data tags', () {
      expect(category('X', ['en:cleansers']), ProductCategory.cleanser);
      expect(category('X', ['en:sunscreens']), ProductCategory.sunscreen);
      expect(category('X', ['en:moisturizers']), ProductCategory.moisturiser);
      expect(category('X', ['en:serums']), ProductCategory.treatment);
    });

    test('from the name when there are no tags', () {
      expect(
        category('Hydrating cream-to-foam cleanser'),
        ProductCategory.cleanser,
      );
      expect(category('Gentle Face Wash'), ProductCategory.cleanser);
      expect(
        category('Ultra Sheer Sunblock SPF 50+'),
        ProductCategory.sunscreen,
      );
      expect(category('Vitamin C Serum'), ProductCategory.treatment);
      expect(category('Moisturising Cream'), ProductCategory.moisturiser);
    });

    test('unknown things are treated as a moisturiser', () {
      expect(category('Mystery product'), ProductCategory.moisturiser);
    });
  });
}
