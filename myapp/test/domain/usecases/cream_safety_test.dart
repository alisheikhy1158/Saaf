// Covers: "Is this cream safe?" — fixed rules on the phone flag mercury,
// hydroquinone and steroids in a printed ingredient list, and can only make
// Saaf AI's verdict stricter, never softer; consent comes first
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/safety_check.dart';
import 'package:saaf/domain/services/ai_safety_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/check_cream_safety.dart';
import 'package:saaf/domain/usecases/flag_ingredients.dart';

class _Service implements AiSafetyService {
  int calls = 0;
  Result<SafetyCheck> answer = const Ok(
    SafetyCheck(
      found: true,
      title: 'Glow Cream',
      level: SafetyLevel.noKnownProblem,
      ingredients: ['Water', 'Mercurous Chloride'],
      ingredientsPrinted: true,
    ),
  );

  @override
  Future<Result<SafetyCheck>> checkSafety({
    required CreamQuery query,
    required AiContext context,
  }) async {
    calls++;
    return answer;
  }
}

void main() {
  group('ingredient rules', () {
    List<IngredientRisk> risks(List<String> list) => [
      for (final flag in const FlagIngredients()(list)) flag.risk,
    ];

    test('mercury in any of its names', () {
      for (final name in [
        'Mercurous chloride',
        'CALOMEL',
        'Ammoniated mercury',
        'Hydrargyrum',
        'mercury',
      ]) {
        expect(risks([name]), [IngredientRisk.mercury], reason: name);
      }
    });

    test('hydroquinone, strong steroids and milder ones', () {
      expect(risks(['Hydroquinone 2%']), [IngredientRisk.hydroquinone]);
      expect(risks(['Clobetasol propionate']), [IngredientRisk.strongSteroid]);
      expect(risks(['Betamethasone valerate']), [IngredientRisk.strongSteroid]);
      expect(risks(['Hydrocortisone acetate']), [IngredientRisk.steroid]);
      expect(risks(['Tretinoin']), [IngredientRisk.prescriptionRetinoid]);
    });

    test('ordinary ingredients are not flagged, and each risk once', () {
      expect(risks(['Water', 'Niacinamide', 'Glycerin']), isEmpty);
      expect(risks(['Mercury', 'Calomel']), [IngredientRisk.mercury]);
    });

    test('a flag says which printed ingredient it came from', () {
      final flag = const FlagIngredients()(['Water', 'Clobetasol']).single;
      expect(flag.ingredient, 'Clobetasol');
    });
  });

  group('CheckCreamSafety', () {
    late _Service service;
    setUp(() => service = _Service());

    Future<Result<SafetyCheck>> check(
      CreamQuery query, {
      bool consent = true,
    }) async {
      final c = AiConsent(InMemorySettingsRepository());
      if (consent) await c.give();
      return CheckCreamSafety(service: service, consent: c)(
        query: query,
        languageCode: 'en',
      );
    }

    test('nothing is sent without consent', () async {
      expect(
        (await check(
          const CreamNameQuery('Glow'),
          consent: false,
        )).failureOrNull,
        const ConsentMissing(),
      );
      expect(service.calls, 0);
    });

    test(
      'the phone’s rules make the verdict stricter (never softer)',
      () async {
        final result = (await check(const CreamNameQuery('Glow'))).valueOrNull!;
        expect(result.level, SafetyLevel.danger);
        expect(result.flags.single.risk, IngredientRisk.mercury);
      },
    );

    test('Saaf AI’s danger stays danger whatever the rules say', () async {
      service.answer = const Ok(
        SafetyCheck(found: true, title: 'X', level: SafetyLevel.danger),
      );
      expect(
        (await check(const CreamNameQuery('X'))).valueOrNull!.level,
        SafetyLevel.danger,
      );
    });

    test('no ingredient list printed is at least "be careful"', () async {
      service.answer = const Ok(
        SafetyCheck(
          found: true,
          title: 'Formula cream',
          level: SafetyLevel.noKnownProblem,
          ingredientsPrinted: false,
        ),
      );
      expect(
        (await check(
          CreamPhotoQuery(Uint8List.fromList([1])),
        )).valueOrNull!.level,
        SafetyLevel.caution,
      );
    });

    test('refuses an empty name or photo without sending', () async {
      expect(
        (await check(const CreamNameQuery('  '))).failureOrNull,
        isA<ValidationFailure>(),
      );
      expect(
        (await check(CreamPhotoQuery(Uint8List(0)))).failureOrNull,
        isA<ValidationFailure>(),
      );
      expect(service.calls, 0);
    });
  });
}
