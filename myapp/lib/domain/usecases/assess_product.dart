import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';

/// How a scanned product fits the user.
enum ProductFit {
  /// Nothing in the answers says otherwise.
  good,

  /// Worth checking: made for another skin type, or a strong active on
  /// sensitive skin.
  careful,

  /// The safety answers say it is usually avoided.
  avoid,
}

/// Compares one product with the quiz answers. The safety answers only ever
/// make the advice more careful, and it is guidance, not a diagnosis.
class AssessProduct {
  const AssessProduct();

  ProductFit call(Product product, SkinProfile profile) {
    final flags = profile.safetyFlags ?? const <SafetyFlag>{};

    if (flags.contains(SafetyFlag.pregnantOrBreastfeeding) &&
        product.avoidInPregnancy) {
      return ProductFit.avoid;
    }
    if (flags.contains(SafetyFlag.ingredientAllergy) &&
        !product.fragranceFree) {
      return ProductFit.avoid;
    }
    if (flags.contains(SafetyFlag.prescriptionTreatment) &&
        product.isStrongActive) {
      return ProductFit.avoid;
    }

    if (product.isStrongActive && profile.sensitivity == Sensitivity.high) {
      return ProductFit.careful;
    }
    final type = profile.skinType;
    if (type != null &&
        type != SkinType.notSure &&
        product.skinTypes.isNotEmpty &&
        !product.skinTypes.contains(type)) {
      return ProductFit.careful;
    }
    return ProductFit.good;
  }
}
