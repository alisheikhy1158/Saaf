import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';

/// Builds a morning and a night routine from what the user told us: one product
/// per step, matched to skin type and concerns, filtered by the safety answers
/// and fitted to the monthly budget.
///
/// Pure and deterministic. The safety answers only remove products; they are
/// never a diagnosis. A step with no safe product is left out rather than forced.
///
/// [preferred] are the ids Saaf AI chose: they come first in their step, but
/// the safety answers and the budget still apply to them like to any product.
/// [rank] is Saaf AI's order (best first), used when two products score the
/// same and cost the same.
/// [owned] are the user's own products: they come before everything else, and
/// a strong one stays even without a matching concern (they already use it),
/// but the safety answers still apply.
class BuildRoutine {
  const BuildRoutine(
    this._catalog, {
    Set<String> preferred = const {},
    Set<String> owned = const {},
    List<String> rank = const [],
  }) : _preferred = preferred,
       _owned = owned,
       _rank = rank;

  final List<Product> _catalog;
  final Set<String> _preferred;
  final Set<String> _owned;
  final List<String> _rank;

  /// Score bonus that puts a Saaf AI pick ahead of every rule-based choice.
  static const int _preferredBonus = 100;

  /// And the user's own product ahead of a Saaf AI pick.
  static const int _ownedBonus = 200;

  /// Every product the safety answers allow for [profile] (what Saaf AI may
  /// choose from).
  List<Product> allowedFor(SkinProfile profile) =>
      _catalog.where((p) => _isAllowed(p, profile)).toList();

  /// Cost of losing a treatment compared with swapping it for a cheaper one:
  /// the budget drops a treatment only after cheaper swaps run out.
  static const int _removalPenalty = 5;

  Routine call(SkinProfile profile) {
    final slots = <_Slot, List<Product>>{
      for (final slot in _Slot.values) slot: _candidates(slot, profile),
    };
    final chosen = <_Slot, Product>{
      for (final entry in slots.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value.first,
    };

    final limit = profile.budget?.maxMonthlyPkr;
    if (limit != null) _fitToBudget(chosen, slots, profile, limit);

    List<RoutineStep> steps(List<_Slot> order) {
      final products = [
        for (final slot in order)
          if (chosen[slot] != null) chosen[slot]!,
      ];
      return [
        for (final (i, product) in products.indexed)
          RoutineStep(number: i + 1, product: product),
      ];
    }

    return Routine(
      morning: steps(_Slot.morningOrder),
      night: steps(_Slot.nightOrder),
      concerns: profile.concerns.toList(),
      budget: profile.budget,
    );
  }

  // ── Choosing ─────────────────────────────────────────────────────────────

  List<Product> _candidates(_Slot slot, SkinProfile profile) {
    final list = _catalog
        .where((p) => p.category == slot.category)
        .where((p) => slot.times.every(p.times.contains))
        .where((p) => _isAllowed(p, profile))
        .toList();
    list.sort((a, b) {
      final byScore = _score(b, profile).compareTo(_score(a, profile));
      if (byScore != 0) return byScore;
      final byPrice = a.pricePkr.compareTo(b.pricePkr);
      if (byPrice != 0) return byPrice;
      final byRank = _rankOf(a).compareTo(_rankOf(b));
      return byRank != 0 ? byRank : a.id.compareTo(b.id);
    });
    return list;
  }

  int _rankOf(Product p) {
    final i = _rank.indexOf(p.id);
    return i < 0 ? _rank.length : i;
  }

  bool _isAllowed(Product p, SkinProfile profile) {
    final flags = profile.safetyFlags ?? const <SafetyFlag>{};
    if (flags.contains(SafetyFlag.pregnantOrBreastfeeding) &&
        p.avoidInPregnancy) {
      return false;
    }
    if (flags.contains(SafetyFlag.ingredientAllergy) && !p.fragranceFree) {
      return false;
    }
    if (p.isStrongActive) {
      if (flags.contains(SafetyFlag.prescriptionTreatment)) return false;
      if (profile.sensitivity == Sensitivity.high) return false;
      // A strong active is only worth it for a concern the user has (unless
      // they already use it).
      if (!_owned.contains(p.id) && !p.targets.any(profile.concerns.contains)) {
        return false;
      }
    }
    return true;
  }

  int _score(Product p, SkinProfile profile) {
    final type = profile.skinType;
    final knowsType = type != null && type != SkinType.notSure;
    final typeScore = p.skinTypes.isEmpty
        ? 1
        : (knowsType && p.skinTypes.contains(type) ? 3 : 0);
    final concernScore = 2 * p.targets.where(profile.concerns.contains).length;
    final aiScore = _preferred.contains(p.id) ? _preferredBonus : 0;
    final ownScore = _owned.contains(p.id) ? _ownedBonus : 0;
    return typeScore + concernScore + aiScore + ownScore;
  }

  // ── Budget ───────────────────────────────────────────────────────────────

  int _cost(Map<_Slot, Product> chosen) =>
      chosen.values.toSet().fold(0, (sum, p) => sum + p.pricePkr);

  /// Repeats the cheapest-to-lose saving until the routine fits: swap a product
  /// (everywhere it is used) for a cheaper one, or drop a treatment.
  void _fitToBudget(
    Map<_Slot, Product> chosen,
    Map<_Slot, List<Product>> slots,
    SkinProfile profile,
    int limit,
  ) {
    while (_cost(chosen) > limit) {
      final before = _cost(chosen);
      _Move? best;

      for (final current in chosen.values.toSet()) {
        // The user's own products stay: they already have them.
        if (_owned.contains(current.id)) continue;
        final where = [
          for (final e in chosen.entries)
            if (e.value == current) e.key,
        ];

        // Swap for any cheaper product that suits every slot it is used in.
        final cheaper = slots[where.first]!
            .where((c) => c.pricePkr < current.pricePkr)
            .where((c) => where.every((s) => slots[s]!.contains(c)));
        for (final replacement in cheaper) {
          final trial = {...chosen};
          for (final s in where) {
            trial[s] = replacement;
          }
          final saving = before - _cost(trial);
          if (saving > 0) {
            final loss =
                where.length *
                (_score(current, profile) - _score(replacement, profile));
            best = _better(best, _Move(where, replacement, saving, loss));
          }
        }

        // Or drop a treatment altogether.
        if (current.category == ProductCategory.treatment) {
          final trial = {...chosen}..removeWhere((s, p) => p == current);
          final saving = before - _cost(trial);
          if (saving > 0) {
            final loss =
                where.length * (_score(current, profile) + _removalPenalty);
            best = _better(best, _Move(where, null, saving, loss));
          }
        }
      }

      if (best == null) return; // nothing left to save
      for (final s in best.slots) {
        if (best.replacement == null) {
          chosen.remove(s);
        } else {
          chosen[s] = best.replacement!;
        }
      }
    }
  }

  /// The move that loses least per rupee saved; ties go to the bigger saving.
  _Move _better(_Move? a, _Move b) {
    if (a == null) return b;
    final left = a.loss * b.saving;
    final right = b.loss * a.saving;
    if (left != right) return left < right ? a : b;
    return a.saving >= b.saving ? a : b;
  }
}

class _Move {
  const _Move(this.slots, this.replacement, this.saving, this.loss);

  final List<_Slot> slots;

  /// null = drop it.
  final Product? replacement;
  final int saving;
  final int loss;
}

enum _Slot {
  cleanser(ProductCategory.cleanser, {RoutineTime.morning, RoutineTime.night}),
  treatmentMorning(ProductCategory.treatment, {RoutineTime.morning}),
  treatmentNight(ProductCategory.treatment, {RoutineTime.night}),
  moisturiser(ProductCategory.moisturiser, {
    RoutineTime.morning,
    RoutineTime.night,
  }),
  sunscreen(ProductCategory.sunscreen, {RoutineTime.morning});

  const _Slot(this.category, this.times);

  final ProductCategory category;

  /// The product must be usable at all of these times.
  final Set<RoutineTime> times;

  static const morningOrder = [
    cleanser,
    treatmentMorning,
    moisturiser,
    sunscreen,
  ];
  static const nightOrder = [cleanser, treatmentNight, moisturiser];
}
