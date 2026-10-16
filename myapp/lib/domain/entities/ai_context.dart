import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';

/// What the AI coach is told about the user so its advice fits: skin type,
/// concerns, sensitivity, budget and the routine's product names.
///
/// There is deliberately NO field for the safety answers (pregnancy,
/// prescription treatment, allergy): they are health data that never leaves the
/// phone. The coach asks about such things in the chat if it matters.
class AiContext {
  const AiContext({
    required this.languageCode,
    this.skinType,
    this.concerns = const {},
    this.sensitivity,
    this.budget,
    this.routineProducts = const [],
  });

  final String languageCode;
  final SkinType? skinType;
  final Set<SkinConcern> concerns;
  final Sensitivity? sensitivity;
  final BudgetBand? budget;

  /// Names of the products in the user's routine (morning then night, each once).
  final List<String> routineProducts;

  @override
  bool operator ==(Object other) =>
      other is AiContext &&
      other.languageCode == languageCode &&
      other.skinType == skinType &&
      _sameSet(other.concerns, concerns) &&
      other.sensitivity == sensitivity &&
      other.budget == budget &&
      _sameList(other.routineProducts, routineProducts);

  @override
  int get hashCode => Object.hash(
    languageCode,
    skinType,
    Object.hashAllUnordered(concerns),
    sensitivity,
    budget,
    Object.hashAll(routineProducts),
  );

  static bool _sameSet(Set<Object> a, Set<Object> b) =>
      a.length == b.length && a.containsAll(b);

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
