import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/usecases/active_rules.dart';

/// One product Saaf AI found on the web for the routine.
class AiPick {
  const AiPick({
    required this.product,
    required this.brand,
    required this.why,
    this.reviews = '',
    this.sources = const [],
  });

  /// Its flags come from [ActiveRules], so the routine's safety checks apply.
  /// A price of 0 means no price was found.
  final Product product;
  final String brand;

  /// Why it suits this user (one sentence).
  final String why;

  /// What real users say about it (Reddit, review pages), in the AI's words.
  final String reviews;

  /// Pages the web research used (opened in the browser, never in the app).
  final List<String> sources;
}

enum ProductVerdict { keep, replace, stop }

/// Why the phone itself warns about a product the user already uses, from the
/// safety answers that never leave it.
enum ProductCaution { pregnancy, prescription, sensitive }

/// Saaf AI's verdict on a product the user uses now.
class CurrentProductReview {
  const CurrentProductReview({
    required this.name,
    required this.verdict,
    required this.why,
    this.reviews = '',
    this.actives = const {},
    this.replaceWith,
  });

  /// As the user typed it.
  final String name;
  final ProductVerdict verdict;
  final String why;
  final String reviews;
  final Set<Ingredient> actives;

  /// The name of the pick to use instead (replace only).
  final String? replaceWith;

  /// A warning the AI could not give, because it never sees the safety answers.
  ProductCaution? cautionFor(SkinProfile profile) {
    if (verdict == ProductVerdict.stop) return null;
    final flags = profile.safetyFlags ?? const <SafetyFlag>{};
    if (flags.contains(SafetyFlag.pregnantOrBreastfeeding) &&
        ActiveRules.avoidInPregnancy(actives)) {
      return ProductCaution.pregnancy;
    }
    if (!ActiveRules.isStrong(actives)) return null;
    if (flags.contains(SafetyFlag.prescriptionTreatment)) {
      return ProductCaution.prescription;
    }
    return profile.sensitivity == Sensitivity.high
        ? ProductCaution.sensitive
        : null;
  }
}

/// The routine Saaf AI researched on the web, and its verdicts on the
/// products the user uses now.
class AiRoutinePlan {
  const AiRoutinePlan({
    required this.summary,
    required this.picks,
    this.current = const [],
  });

  final String summary;
  final List<AiPick> picks;
  final List<CurrentProductReview> current;

  List<Product> get products => [for (final p in picks) p.product];

  Set<String> get productIds => {for (final p in picks) p.product.id};

  AiPick? pickFor(String productId) {
    for (final pick in picks) {
      if (pick.product.id == productId) return pick;
    }
    return null;
  }
}
