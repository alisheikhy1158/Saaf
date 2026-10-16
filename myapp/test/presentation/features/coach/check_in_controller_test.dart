// Covers: 11 Weekly check-in — the conversation: two questions, quick replies or
// typed text, then an outcome that is saved on the phone
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_check_in_repository.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/check_in.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/presentation/features/coach/controllers/check_in_controller.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/check_in_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';

class _Clock implements Clock {
  const _Clock(this.value);
  final DateTime value;

  @override
  DateTime now() => value;
}

void main() {
  late InMemoryCheckInRepository repository;

  ProviderContainer make({DateTime? now, DateTime? scanDate, String? name}) {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(
          _Clock(now ?? DateTime(2026, 10, 15, 9)),
        ),
        checkInRepositoryProvider.overrideWithValue(repository),
        completedScanProvider.overrideWithBuild(
          (ref, n) => scanDate == null
              ? null
              : CompletedScan(id: 's', takenAt: scanDate, photos: const []),
        ),
        authSessionControllerProvider.overrideWithBuild(
          (ref, n) =>
              name == null ? null : AuthSession(userId: 'u', displayName: name),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(checkInControllerProvider, (_, _) {});
    return container;
  }

  CheckInState read(ProviderContainer c) => c.read(checkInControllerProvider);
  CheckInController notifier(ProviderContainer c) =>
      c.read(checkInControllerProvider.notifier);

  setUp(() => repository = InMemoryCheckInRepository());

  group('start', () {
    test('the coach greets and asks how the skin felt', () {
      final c = make(name: 'Ayesha Khan');
      final state = read(c);
      expect(state.step, CheckInStep.skinFeel);
      expect(state.messages.single, isA<CoachGreeting>());
      expect((state.messages.single as CoachGreeting).name, 'Ayesha');
      expect(state.outcome, isNull);
    });

    test('with no name the greeting has none', () {
      expect((read(make()).messages.single as CoachGreeting).name, isNull);
    });

    test('the week counts from the first scan', () {
      final c = make(
        now: DateTime(2026, 10, 15),
        scanDate: DateTime(2026, 10, 1),
      );
      expect(read(c).week, 3);
    });

    test('with no scan yet it is week 1', () {
      expect(read(make()).week, 1);
    });
  });

  group('answering', () {
    test('a quick reply is shown and the coach asks about breakouts', () {
      final c = make();
      notifier(c).answerSkinFeel(SkinFeel.lessOily);
      final state = read(c);
      expect(state.step, CheckInStep.breakouts);
      expect(state.messages.map((m) => m.runtimeType), [
        CoachGreeting,
        UserSkinFeel,
        CoachBreakoutsQuestion,
      ]);
      expect((state.messages[1] as UserSkinFeel).value, SkinFeel.lessOily);
      expect(
        (state.messages[2] as CoachBreakoutsQuestion).after,
        SkinFeel.lessOily,
      );
    });

    test('the second answer finishes the check-in with an outcome', () {
      final c = make(
        now: DateTime(2026, 10, 15),
        scanDate: DateTime(2026, 10, 1),
      );
      notifier(c).answerSkinFeel(SkinFeel.lessOily);
      notifier(c).answerBreakouts(BreakoutChange.fewSmall);
      final state = read(c);
      expect(state.step, CheckInStep.done);
      expect(state.outcome, CheckInOutcome.onTrack);
      expect(state.nextPhotoCheck, DateTime(2026, 10, 31));
    });

    test('with no scan the next photo date is not invented', () {
      final c = make();
      notifier(c).answerSkinFeel(SkinFeel.same);
      notifier(c).answerBreakouts(BreakoutChange.none);
      expect(read(c).nextPhotoCheck, isNull);
    });

    test('a reply to a question already answered is ignored', () {
      final c = make();
      notifier(c).answerSkinFeel(SkinFeel.lessOily);
      notifier(c).answerSkinFeel(SkinFeel.drier);
      expect(read(c).answers.skinFeel, SkinFeel.lessOily);
      expect(read(c).messages.length, 3);
    });

    test('the breakouts answer cannot come before the skin answer', () {
      final c = make();
      notifier(c).answerBreakouts(BreakoutChange.none);
      expect(read(c).step, CheckInStep.skinFeel);
      expect(read(c).answers.breakouts, isNull);
    });

    test('a safety-first outcome is shown for painful breakouts', () {
      final c = make();
      notifier(c).answerSkinFeel(SkinFeel.same);
      notifier(c).answerBreakouts(BreakoutChange.severe);
      expect(read(c).outcome, CheckInOutcome.seeProfessional);
    });
  });

  group('typing instead of tapping', () {
    test('typed text answers the open question as "other"', () {
      final c = make();
      notifier(c).sendText('  a bit tight on my cheeks ');
      final state = read(c);
      expect(state.answers.skinFeel, SkinFeel.other);
      expect(state.answers.note, 'a bit tight on my cheeks');
      expect((state.messages[1] as UserText).text, 'a bit tight on my cheeks');
      expect(state.step, CheckInStep.breakouts);
    });

    test('blank text does nothing', () {
      final c = make();
      notifier(c).sendText('   ');
      expect(read(c).messages.length, 1);
    });

    test('a note after the result is saved and acknowledged', () {
      final c = make();
      notifier(c).answerSkinFeel(SkinFeel.same);
      notifier(c).answerBreakouts(BreakoutChange.none);
      notifier(c).sendText('chin is better');
      final state = read(c);
      expect(state.messages.last, isA<CoachNoteSaved>());
      expect(state.answers.note, 'chin is better');
    });

    test('notes typed along the way are kept together', () {
      final c = make();
      notifier(c).sendText('first');
      notifier(c).sendText('second');
      expect(read(c).answers.note, 'first\nsecond');
    });
  });

  group('saving', () {
    test('the finished check-in is stored on the phone', () async {
      final c = make(
        now: DateTime(2026, 10, 15, 9),
        scanDate: DateTime(2026, 10, 1),
      );
      notifier(c).answerSkinFeel(SkinFeel.lessOily);
      notifier(c).answerBreakouts(BreakoutChange.fewSmall);
      await Future<void>.delayed(Duration.zero);
      final saved = await repository.all();
      expect(saved, hasLength(1));
      expect(saved.single.week, 3);
      expect(saved.single.outcome, CheckInOutcome.onTrack);
      expect(saved.single.date, DateTime(2026, 10, 15, 9));
      expect(saved.single.answers.skinFeel, SkinFeel.lessOily);
    });

    test('nothing is stored before the check-in is finished', () async {
      final c = make();
      notifier(c).answerSkinFeel(SkinFeel.same);
      await Future<void>.delayed(Duration.zero);
      expect(await repository.all(), isEmpty);
    });
  });
}
