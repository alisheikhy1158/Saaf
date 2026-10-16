// Covers: the tissue (blotting) method for finding the skin type — oil on the
// tissue from the T-zone and the cheeks, and how the skin feels
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/usecases/classify_tissue_test.dart';

SkinType classify({
  bool forehead = false,
  bool nose = false,
  bool cheeks = false,
  bool tight = false,
}) => classifyTissueTest(
  foreheadOil: forehead,
  noseOil: nose,
  cheeksOil: cheeks,
  feelsTight: tight,
);

void main() {
  group('oil everywhere is oily skin', () {
    test('forehead, nose and cheeks', () {
      expect(classify(forehead: true, nose: true, cheeks: true), SkinType.oily);
    });

    test('forehead and cheeks is still oily', () {
      expect(classify(forehead: true, cheeks: true), SkinType.oily);
    });

    test('feeling tight does not change an oily tissue', () {
      expect(
        classify(forehead: true, nose: true, cheeks: true, tight: true),
        SkinType.oily,
      );
    });
  });

  group('oil only in the T-zone is combination skin', () {
    test('forehead and nose', () {
      expect(classify(forehead: true, nose: true), SkinType.combination);
    });

    test('just the nose', () {
      expect(classify(nose: true), SkinType.combination);
    });

    test('just the forehead, even with tight cheeks', () {
      expect(classify(forehead: true, tight: true), SkinType.combination);
    });
  });

  group('a clean tissue', () {
    test('and comfortable skin is normal', () {
      expect(classify(), SkinType.normal);
    });

    test('and tight or flaky skin is dry', () {
      expect(classify(tight: true), SkinType.dry);
    });
  });

  group('a mixed result we cannot read', () {
    test('oil on the cheeks only is "not sure": try again another day', () {
      expect(classify(cheeks: true), SkinType.notSure);
    });
  });
}
