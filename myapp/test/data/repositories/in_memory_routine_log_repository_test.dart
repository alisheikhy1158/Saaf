// Covers: 09 Home checklist — which routine steps were done on which day
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_routine_log_repository.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/repositories/routine_log_repository.dart';

void main() {
  final day = DateTime(2026, 10, 15);
  late InMemoryRoutineLogRepository repository;

  setUp(() => repository = InMemoryRoutineLogRepository());

  test('a day starts with nothing done', () async {
    expect(await repository.doneKeys(day), isEmpty);
  });

  test('marking a step done, and undoing it', () async {
    await repository.setDone(day, 'morning:cleanser-neem', true);
    expect(await repository.doneKeys(day), {'morning:cleanser-neem'});
    await repository.setDone(day, 'morning:cleanser-neem', false);
    expect(await repository.doneKeys(day), isEmpty);
  });

  test('doing the same thing twice is harmless', () async {
    await repository.setDone(day, 'a', true);
    await repository.setDone(day, 'a', true);
    expect(await repository.doneKeys(day), {'a'});
    await repository.setDone(day, 'b', false);
    expect(await repository.doneKeys(day), {'a'});
  });

  test('days are kept apart, and the time of day does not matter', () async {
    await repository.setDone(DateTime(2026, 10, 15, 8), 'a', true);
    expect(await repository.doneKeys(DateTime(2026, 10, 15, 22)), {'a'});
    expect(await repository.doneKeys(DateTime(2026, 10, 16)), isEmpty);
  });

  test('what was returned cannot change the stored data', () async {
    await repository.setDone(day, 'a', true);
    final copy = await repository.doneKeys(day);
    expect(() => copy.add('b'), throwsUnsupportedError);
    expect(await repository.doneKeys(day), {'a'});
  });

  test('the same product in the morning and at night are different steps', () {
    const cleanser = Product(
      id: 'c',
      name: 'c',
      category: ProductCategory.cleanser,
      pricePkr: 1,
      times: {RoutineTime.morning, RoutineTime.night},
    );
    expect(
      routineStepKey(RoutineTime.morning, cleanser),
      isNot(routineStepKey(RoutineTime.night, cleanser)),
    );
    expect(routineStepKey(RoutineTime.morning, cleanser), 'morning:c');
  });
}
