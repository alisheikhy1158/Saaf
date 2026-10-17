import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/usecases/active_rules.dart';

/// Reads and writes a Saaf AI routine plan as JSON: the shape our server sends
/// (`/v1/routine`) and the shape the phone keeps it in. Anything unexpected is
/// skipped; a plan without a single usable pick is null.
abstract final class AiRoutinePlanJson {
  static AiRoutinePlan? decode(Object? json) {
    if (json is! Map<String, Object?>) return null;

    final picks = <AiPick>[];
    final rawNames = <String, String>{}; // name as sent -> full name
    if (json['picks'] case final List<Object?> list) {
      for (final item in list) {
        final pick = _pick(item);
        if (pick == null) continue;
        picks.add(pick.$1);
        rawNames[pick.$2] = pick.$1.product.name;
        rawNames[pick.$1.product.name] = pick.$1.product.name;
      }
    }
    if (picks.isEmpty) return null;

    final current = <CurrentProductReview>[];
    if (json['current'] case final List<Object?> list) {
      for (final item in list) {
        if (item case {
          'name': final String name,
          'verdict': final String verdict,
        } when name.trim().isNotEmpty) {
          final kind = ProductVerdict.values.asNameMap()[verdict];
          if (kind == null) continue;
          final replaceWith = rawNames[_string(item['replaceWith'])];
          current.add(
            CurrentProductReview(
              name: name.trim(),
              verdict: kind,
              why: _string(item['why']),
              reviews: _string(item['reviews']),
              actives: _actives(item['actives']),
              replaceWith: kind == ProductVerdict.keep ? null : replaceWith,
            ),
          );
        }
      }
    }

    return AiRoutinePlan(
      summary: _string(json['summary']),
      picks: picks,
      current: current,
    );
  }

  static Map<String, Object?> encode(AiRoutinePlan plan) => {
    'summary': plan.summary,
    'picks': [
      for (final pick in plan.picks)
        {
          'id': pick.product.id,
          'step': pick.product.category.name,
          'brand': pick.brand,
          'name': pick.product.name,
          'pricePkr': pick.product.pricePkr,
          'times': [for (final t in pick.product.times) t.name],
          'actives': [for (final a in pick.product.ingredients) a.name],
          'fragranceFree': pick.product.fragranceFree,
          'why': pick.why,
          'reviews': pick.reviews,
          'sources': pick.sources,
        },
    ],
    'current': [
      for (final review in plan.current)
        {
          'name': review.name,
          'verdict': review.verdict.name,
          'why': review.why,
          'reviews': review.reviews,
          'actives': [for (final a in review.actives) a.name],
          'replaceWith': review.replaceWith ?? '',
        },
    ],
  };

  /// The pick and the product name exactly as it was sent.
  static (AiPick, String)? _pick(Object? item) {
    if (item case {
      'id': final String id,
      'step': final String step,
      'name': final String name,
    } when id.startsWith('ai-') && name.trim().isNotEmpty) {
      final category = ProductCategory.values.asNameMap()[step];
      if (category == null) return null;
      final brand = _string(item['brand']);
      final rawName = name.trim();
      final fullName =
          brand.isEmpty || rawName.toLowerCase().startsWith(brand.toLowerCase())
          ? rawName
          : '$brand $rawName';
      final times = {
        if (item['times'] case final List<Object?> list)
          for (final t in list) ?RoutineTime.values.asNameMap()[t],
      };
      final price = item['pricePkr'];
      return (
        AiPick(
          product: ActiveRules.product(
            id: id,
            name: fullName,
            category: category,
            pricePkr: price is int && price > 0 ? price : 0,
            times: category == ProductCategory.sunscreen
                ? const {RoutineTime.morning}
                : times.isEmpty
                ? const {RoutineTime.morning, RoutineTime.night}
                : times,
            actives: _actives(item['actives']),
            fragranceFree: item['fragranceFree'] == true,
          ),
          brand: brand,
          why: _string(item['why']),
          reviews: _string(item['reviews']),
          sources: [
            if (item['sources'] case final List<Object?> list)
              for (final url in list)
                if (url is String && _isWebLink(url)) url,
          ],
        ),
        rawName,
      );
    }
    return null;
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static Set<Ingredient> _actives(Object? value) => {
    if (value case final List<Object?> list)
      for (final a in list) ?Ingredient.values.asNameMap()[a],
  };

  static bool _isWebLink(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }
}
