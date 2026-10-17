import 'dart:convert';

import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/usecases/active_rules.dart';

/// A product the user already uses, as they typed it, and which step of the
/// routine it is ([step] null = something else, like a lip balm). Kept on the
/// phone.
class OwnedProduct {
  const OwnedProduct({required this.name, this.step});

  final String name;
  final ProductCategory? step;

  static const idPrefix = 'mine-';

  /// Whether [product] is one of the user's own (no price, "Yours").
  static bool isOwned(Product product) => product.id.startsWith(idPrefix);

  /// The user's products that belong in the routine, as products. One Saaf AI
  /// says to replace or stop is left out; its actives (when Saaf AI reviewed
  /// it) let the safety rules on the phone check it.
  static List<Product> productsFor(
    List<OwnedProduct> owned,
    AiRoutinePlan? plan,
  ) => [
    for (final item in owned)
      if (item.step case final step?)
        if (_review(plan, item.name) case final review
            when review == null || review.verdict == ProductVerdict.keep)
          ActiveRules.product(
            id: '$idPrefix${_slug(item.name)}',
            name: item.name,
            category: step,
            pricePkr: 0,
            times: step == ProductCategory.sunscreen
                ? const {RoutineTime.morning}
                : const {RoutineTime.morning, RoutineTime.night},
            actives: review?.actives ?? const {},
            // Unknown: never claimed fragrance-free.
            fragranceFree: false,
          ),
  ];

  static CurrentProductReview? _review(AiRoutinePlan? plan, String name) {
    for (final review in plan?.current ?? const <CurrentProductReview>[]) {
      if (review.name.toLowerCase() == name.toLowerCase()) return review;
    }
    return null;
  }

  static String _slug(String name) => name
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  static String encodeList(List<OwnedProduct> list) => jsonEncode([
    for (final p in list) {'name': p.name, 'step': p.step?.name ?? 'other'},
  ]);

  /// Also reads the first version of the list, which held names only.
  static List<OwnedProduct> decodeList(String json) {
    try {
      final list = jsonDecode(json);
      if (list is! List) return const [];
      return [
        for (final item in list)
          if (item is String && item.trim().isNotEmpty)
            OwnedProduct(name: item.trim())
          else if (item case {
            'name': final String name,
          } when name.trim().isNotEmpty)
            OwnedProduct(
              name: name.trim(),
              step: ProductCategory.values.asNameMap()[item['step']],
            ),
      ];
    } on Object {
      return const [];
    }
  }

  @override
  bool operator ==(Object other) =>
      other is OwnedProduct && other.name == name && other.step == step;

  @override
  int get hashCode => Object.hash(name, step);

  @override
  String toString() => 'OwnedProduct($name, ${step?.name ?? 'other'})';
}
