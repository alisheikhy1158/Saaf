// Covers: 09 Home — today's checklist, progress and the week strip
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_routine_log_repository.dart';
import 'package:saaf/data/repositories/seed_product_catalog.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/repositories/product_catalog.dart';
import 'package:saaf/domain/repositories/routine_log_repository.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/presentation/features/home/controllers/home_controller.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/home_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

class _Clock implements Clock {
  _Clock(this.value);
  final DateTime value;

  @override
  DateTime now() => value;
}

const _profile = SkinProfile(
  skinType: SkinType.oily,
  concerns: {SkinConcern.darkSpots, SkinConcern.acne},
  budget: BudgetBand.balanced,
);

void main() {
  late InMemoryRoutineLogRepository log;

  ProviderContainer make({DateTime? now}) {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(
          _Clock(now ?? DateTime(2026, 10, 15, 9, 41)),
        ),
        routineLogRepositoryProvider.overrideWithValue(log),
        productCatalogProvider.overrideWithValue(const SeedProductCatalog()),
        skinProfileControllerProvider.overrideWithBuild((ref, n) => _profile),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<HomeState> load(ProviderContainer c) async {
    c.listen(homeControllerProvider, (_, _) {});
    return c.read(homeControllerProvider.future);
  }

  HomeController controller(ProviderContainer c) =>
      c.read(homeControllerProvider.notifier);

  setUp(() => log = InMemoryRoutineLogRepository());

  group('loading', () {
    test('starts today, with the morning routine in the morning', () async {
      final state = await load(make());
      expect(state.today, DateTime(2026, 10, 15));
      expect(state.time, RoutineTime.morning);
      expect(state.steps.length, 4);
      expect(state.doneCount, 0);
      expect(state.progress, 0);
    });

    test('shows the night routine in the evening', () async {
      final state = await load(make(now: DateTime(2026, 10, 15, 20)));
      expect(state.time, RoutineTime.night);
      expect(state.steps.length, 3);
    });

    test('the week is Monday to Sunday around today', () async {
      final state = await load(make());
      expect(state.week.map((d) => d.day), [12, 13, 14, 15, 16, 17, 18]);
    });

    test('steps done earlier today are ticked', () async {
      final routine = await make().read(routineProvider.future);
      final first = routine.morning.first.product;
      await log.setDone(
        DateTime(2026, 10, 15),
        routineStepKey(RoutineTime.morning, first),
        true,
      );
      final state = await load(make());
      expect(state.doneCount, 1);
      expect(state.isDone(state.steps.first), isTrue);
    });
  });

  group('ticking steps', () {
    test('ticking a step counts it and saves it', () async {
      final c = make();
      final before = await load(c);
      await controller(c).toggle(before.steps[0]);
      final after = c.read(homeControllerProvider).requireValue;
      expect(after.doneCount, 1);
      expect(after.progress, 0.25);
      expect(await log.doneKeys(DateTime(2026, 10, 15)), {
        routineStepKey(RoutineTime.morning, before.steps[0].product),
      });
    });

    test('ticking again unticks it', () async {
      final c = make();
      final before = await load(c);
      await controller(c).toggle(before.steps[0]);
      await controller(c).toggle(before.steps[0]);
      expect(c.read(homeControllerProvider).requireValue.doneCount, 0);
      expect(await log.doneKeys(DateTime(2026, 10, 15)), isEmpty);
    });

    test('2 of 4 is 50 %', () async {
      final c = make();
      final before = await load(c);
      await controller(c).toggle(before.steps[0]);
      await controller(c).toggle(before.steps[1]);
      expect(c.read(homeControllerProvider).requireValue.progress, 0.5);
    });

    test('the morning and night cleanser are separate ticks', () async {
      final c = make();
      final morning = await load(c);
      await controller(c).toggle(morning.steps.first);
      controller(c).selectTime(RoutineTime.night);
      final night = c.read(homeControllerProvider).requireValue;
      expect(night.doneCount, 0);
    });
  });

  group('time of day', () {
    test(
      'switching shows the other routine and keeps what was ticked',
      () async {
        final c = make();
        final morning = await load(c);
        await controller(c).toggle(morning.steps.first);
        controller(c).selectTime(RoutineTime.night);
        expect(c.read(homeControllerProvider).requireValue.steps.length, 3);
        controller(c).selectTime(RoutineTime.morning);
        expect(c.read(homeControllerProvider).requireValue.doneCount, 1);
      },
    );
  });

  group('week strip', () {
    test(
      'a day is complete when every morning and night step is done',
      () async {
        final c = make();
        final state = await load(c);
        final routine = state.routine;
        final monday = DateTime(2026, 10, 12);
        for (final time in RoutineTime.values) {
          for (final step in routine.stepsFor(time)) {
            await log.setDone(monday, routineStepKey(time, step.product), true);
          }
        }
        final reloaded = await load(make());
        expect(reloaded.isDayComplete(monday), isTrue);
        expect(reloaded.isDayComplete(DateTime(2026, 10, 13)), isFalse);
      },
    );

    test('a day with only some steps done is not complete', () async {
      final state = await load(make());
      await log.setDone(
        DateTime(2026, 10, 13),
        routineStepKey(RoutineTime.morning, state.steps.first.product),
        true,
      );
      final reloaded = await load(make());
      expect(reloaded.isDayComplete(DateTime(2026, 10, 13)), isFalse);
    });

    test('today becomes complete as the last step is ticked', () async {
      final c = make();
      var state = await load(c);
      for (final time in RoutineTime.values) {
        controller(c).selectTime(time);
        state = c.read(homeControllerProvider).requireValue;
        for (final step in state.steps) {
          await controller(c).toggle(step);
        }
      }
      expect(
        c
            .read(homeControllerProvider)
            .requireValue
            .isDayComplete(DateTime(2026, 10, 15)),
        isTrue,
      );
    });
  });

  group('no routine', () {
    test('an empty catalogue gives empty steps and no progress', () async {
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(_Clock(DateTime(2026, 10, 15, 9))),
          routineLogRepositoryProvider.overrideWithValue(log),
          productCatalogProvider.overrideWithValue(const _Empty()),
          skinProfileControllerProvider.overrideWithBuild((ref, n) => _profile),
        ],
      );
      addTearDown(container.dispose);
      final state = await load(container);
      expect(state.steps, isEmpty);
      expect(state.progress, 0);
      expect(state.hasRoutine, isFalse);
    });
  });
}

class _Empty implements ProductCatalog {
  const _Empty();

  @override
  Future<List<Product>> all() async => const [];
}
