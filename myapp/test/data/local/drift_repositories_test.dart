// Covers: OFF-1 — the drift repositories keep what the user said and did, and
// give it back unchanged after a restart
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/local/app_database.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/check_in.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/consent_record.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/entities/stored_photo.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('consent', () {
    test('nothing at first, then what was saved', () async {
      final repo = DriftConsentRepository(db);
      expect(await repo.current(), isNull);
      final record = ConsentRecord(
        acceptedAt: DateTime(2026, 10, 16, 9, 41),
        policyVersion: '2026-10-16',
      );
      await repo.save(record);
      final read = (await repo.current())!;
      expect(read.acceptedAt, record.acceptedAt);
      expect(read.policyVersion, '2026-10-16');
    });

    test('saving again replaces it; clear forgets it', () async {
      final repo = DriftConsentRepository(db);
      await repo.save(
        ConsentRecord(acceptedAt: DateTime(2026), policyVersion: 'a'),
      );
      await repo.save(
        ConsentRecord(acceptedAt: DateTime(2027), policyVersion: 'b'),
      );
      expect((await repo.current())!.policyVersion, 'b');
      await repo.clear();
      expect(await repo.current(), isNull);
    });
  });

  group('skin profile', () {
    test('a full profile comes back the same', () async {
      final repo = DriftSkinProfileRepository(db);
      const profile = SkinProfile(
        skinType: SkinType.combination,
        concerns: {SkinConcern.acne, SkinConcern.darkSpots},
        sensitivity: Sensitivity.sometimes,
        safetyFlags: {SafetyFlag.pregnantOrBreastfeeding},
        budget: BudgetBand.balanced,
      );
      await repo.save(profile);
      expect(await repo.current(), profile);
    });

    test(
      'unanswered stays unanswered and "none of these" stays empty',
      () async {
        final repo = DriftSkinProfileRepository(db);
        await repo.save(const SkinProfile());
        expect((await repo.current())!.safetyFlags, isNull);
        expect((await repo.current())!.skinType, isNull);

        await repo.save(const SkinProfile(safetyFlags: <SafetyFlag>{}));
        expect((await repo.current())!.safetyFlags, isEmpty);
        expect((await repo.current())!.safetyFlags, isNotNull);
      },
    );

    test('nothing at first; clear forgets it', () async {
      final repo = DriftSkinProfileRepository(db);
      expect(await repo.current(), isNull);
      await repo.save(const SkinProfile(skinType: SkinType.oily));
      await repo.clear();
      expect(await repo.current(), isNull);
    });

    test('an unknown stored name is read as unanswered, not a crash', () async {
      await db
          .into(db.skinProfileRows)
          .insert(
            SkinProfileRowsCompanion.insert(
              id: const Value(1),
              skinType: const Value('from-the-future'),
            ),
          );
      expect(
        (await DriftSkinProfileRepository(db).current())!.skinType,
        isNull,
      );
    });
  });

  group('routine log', () {
    final day = DateTime(2026, 10, 15);

    test('tick, untick, and days stay apart', () async {
      final repo = DriftRoutineLogRepository(db);
      expect(await repo.doneKeys(day), isEmpty);
      await repo.setDone(day, 'morning:a', true);
      await repo.setDone(day, 'morning:a', true);
      await repo.setDone(DateTime(2026, 10, 16), 'morning:b', true);
      expect(await repo.doneKeys(DateTime(2026, 10, 15, 22)), {'morning:a'});
      await repo.setDone(day, 'morning:a', false);
      expect(await repo.doneKeys(day), isEmpty);
      expect(await repo.doneKeys(DateTime(2026, 10, 16)), {'morning:b'});
    });
  });

  group('check-ins', () {
    test('saved in order and read back whole', () async {
      final repo = DriftCheckInRepository(db);
      await repo.save(
        CheckIn(
          date: DateTime(2026, 10, 8),
          week: 2,
          answers: const CheckInAnswers(
            skinFeel: SkinFeel.same,
            breakouts: BreakoutChange.none,
          ),
          outcome: CheckInOutcome.onTrack,
        ),
      );
      await repo.save(
        CheckIn(
          date: DateTime(2026, 10, 15),
          week: 3,
          answers: const CheckInAnswers(
            skinFeel: SkinFeel.lessOily,
            breakouts: BreakoutChange.fewSmall,
            note: 'chin',
          ),
          outcome: CheckInOutcome.onTrack,
        ),
      );
      final all = await repo.all();
      expect(all.map((c) => c.week), [2, 3]);
      expect(all.last.answers.note, 'chin');
      expect(all.last.answers.skinFeel, SkinFeel.lessOily);
      expect(all.first.answers.note, isNull);
      expect(all.last.outcome, CheckInOutcome.onTrack);
    });
  });

  group('scan history', () {
    CompletedScan scan(String id, DateTime date) => CompletedScan(
      id: id,
      takenAt: date,
      photos: [
        for (final pose in FacePose.values)
          StoredPhoto(
            scanId: id,
            pose: pose,
            reference: 'scans/$id/${pose.name}.jpg',
          ),
      ],
    );

    test('oldest first, with the photos in pose order', () async {
      final repo = DriftScanHistoryRepository(db);
      await repo.add(scan('b', DateTime(2026, 10, 14)));
      await repo.add(scan('a', DateTime(2026, 9, 14)));
      final all = await repo.all();
      expect(all.map((s) => s.id), ['a', 'b']);
      expect(all.first.photos.map((p) => p.pose), FacePose.values);
      expect(all.first.photos.first.reference, 'scans/a/front.jpg');
    });

    test('adding the same scan twice keeps one', () async {
      final repo = DriftScanHistoryRepository(db);
      await repo.add(scan('a', DateTime(2026, 9, 14)));
      await repo.add(scan('a', DateTime(2026, 9, 14)));
      expect(await repo.all(), hasLength(1));
    });

    test('empty at first', () async {
      expect(await DriftScanHistoryRepository(db).all(), isEmpty);
    });
  });

  group('onboarding flag', () {
    test('false until the quiz is done, and it can be reset', () async {
      final repo = DriftOnboardingRepository(db);
      expect(await repo.quizDone(), isFalse);
      await repo.setQuizDone(done: true);
      expect(await repo.quizDone(), isTrue);
      await repo.setQuizDone(done: false);
      expect(await repo.quizDone(), isFalse);
    });
  });

  group('settings', () {
    test('read, replace and forget', () async {
      final repo = DriftSettingsRepository(db);
      expect(await repo.read('language'), isNull);
      await repo.write('language', 'ur');
      await repo.write('language', 'en');
      expect(await repo.read('language'), 'en');
      await repo.write('language', null);
      expect(await repo.read('language'), isNull);
    });
  });
}
