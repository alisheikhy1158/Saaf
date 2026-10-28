import 'dart:convert';

import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/usecases/active_rules.dart';

/// A product the user already uses, as they typed it, and which step of the
/// routine it is ([step] null = something else, like a lip balm), with what
/// it costs them and its shelf details when they gave them. Kept on the phone.
class OwnedProduct {
  const OwnedProduct({
    required this.name,
    this.step,
    this.pricePkr,
    this.openedOn,
    this.paoMonths,
    this.lastsWeeks,
  });

  final String name;
  final ProductCategory? step;

  /// What one pack costs them (counted against the monthly budget).
  final int? pricePkr;

  /// The day it was opened.
  final DateTime? openedOn;

  /// How long it keeps once opened (the open-jar symbol, like "12M").
  final int? paoMonths;

  /// About how long one pack lasts.
  final int? lastsWeeks;

  /// Use it before this day (needs the opened date and [paoMonths]).
  DateTime? get useBy => switch ((openedOn, paoMonths)) {
    (final opened?, final months?) => DateTime(
      opened.year,
      opened.month + months,
      opened.day,
    ),
    _ => null,
  };

  /// It probably runs out around this day.
  DateTime? get runsOutAround => switch ((openedOn, lastsWeeks)) {
    (final opened?, final weeks?) => DateTime(
      opened.year,
      opened.month,
      opened.day + weeks * 7,
    ),
    _ => null,
  };

  OwnedProduct withShelf({
    int? pricePkr,
    DateTime? openedOn,
    int? paoMonths,
    int? lastsWeeks,
  }) => OwnedProduct(
    name: name,
    step: step,
    pricePkr: pricePkr,
    openedOn: openedOn,
    paoMonths: paoMonths,
    lastsWeeks: lastsWeeks,
  );

  static const idPrefix = 'mine-';

  /// Whether [product] is one of the user's own ("Yours").
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
            pricePkr: item.pricePkr ?? 0,
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
    for (final p in list)
      {
        'name': p.name,
        'step': p.step?.name ?? 'other',
        'pricePkr': ?p.pricePkr,
        if (p.openedOn case final d?)
          'openedOn': DateTime(d.year, d.month, d.day).toIso8601String(),
        'paoMonths': ?p.paoMonths,
        'lastsWeeks': ?p.lastsWeeks,
      },
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
              pricePkr: switch (item['pricePkr']) {
                final int price when price > 0 => price,
                _ => null,
              },
              openedOn: switch (item['openedOn']) {
                final String date => DateTime.tryParse(date),
                _ => null,
              },
              paoMonths: switch (item['paoMonths']) {
                final int months when months > 0 => months,
                _ => null,
              },
              lastsWeeks: switch (item['lastsWeeks']) {
                final int weeks when weeks > 0 => weeks,
                _ => null,
              },
            ),
      ];
    } on Object {
      return const [];
    }
  }

  @override
  bool operator ==(Object other) =>
      other is OwnedProduct &&
      other.name == name &&
      other.step == step &&
      other.pricePkr == pricePkr &&
      other.openedOn == openedOn &&
      other.paoMonths == paoMonths &&
      other.lastsWeeks == lastsWeeks;

  @override
  int get hashCode =>
      Object.hash(name, step, pricePkr, openedOn, paoMonths, lastsWeeks);

  @override
  String toString() => 'OwnedProduct($name, ${step?.name ?? 'other'})';
}
