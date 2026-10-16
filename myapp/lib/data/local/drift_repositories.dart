import 'package:drift/drift.dart';
import 'package:saaf/core/utils/week.dart';
import 'package:saaf/data/local/app_database.dart';
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
import 'package:saaf/domain/repositories/check_in_repository.dart';
import 'package:saaf/domain/repositories/consent_repository.dart';
import 'package:saaf/domain/repositories/onboarding_repository.dart';
import 'package:saaf/domain/repositories/routine_log_repository.dart';
import 'package:saaf/domain/repositories/scan_history_repository.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';

/// Reads an enum stored by name; an unknown or missing name is null (a value
/// written by a newer app version must not crash an older one).
T? _enumOrNull<T extends Enum>(List<T> values, String? name) =>
    name == null ? null : values.where((v) => v.name == name).firstOrNull;

Set<T> _enumSet<T extends Enum>(List<T> values, String text) => {
  for (final name in text.split(','))
    if (name.isNotEmpty) ?_enumOrNull(values, name),
};

String _join(Iterable<Enum> values) => values.map((v) => v.name).join(',');

class DriftConsentRepository implements ConsentRepository {
  DriftConsentRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ConsentRecord?> current() async {
    final row = await (_db.select(
      _db.consentRows,
    )..where((r) => r.id.equals(1))).getSingleOrNull();
    return row == null
        ? null
        : ConsentRecord(
            acceptedAt: row.acceptedAt,
            policyVersion: row.policyVersion,
          );
  }

  @override
  Future<void> save(ConsentRecord record) => _db
      .into(_db.consentRows)
      .insertOnConflictUpdate(
        ConsentRowsCompanion.insert(
          id: const Value(1),
          acceptedAt: record.acceptedAt,
          policyVersion: record.policyVersion,
        ),
      );

  @override
  Future<void> clear() => _db.delete(_db.consentRows).go();
}

class DriftSkinProfileRepository implements SkinProfileRepository {
  DriftSkinProfileRepository(this._db);

  final AppDatabase _db;

  @override
  Future<SkinProfile?> current() async {
    final row = await (_db.select(
      _db.skinProfileRows,
    )..where((r) => r.id.equals(1))).getSingleOrNull();
    if (row == null) return null;
    return SkinProfile(
      skinType: _enumOrNull(SkinType.values, row.skinType),
      concerns: _enumSet(SkinConcern.values, row.concerns),
      sensitivity: _enumOrNull(Sensitivity.values, row.sensitivity),
      safetyFlags: row.safetyFlags == null
          ? null
          : _enumSet(SafetyFlag.values, row.safetyFlags!),
      budget: _enumOrNull(BudgetBand.values, row.budget),
    );
  }

  @override
  Future<void> save(SkinProfile profile) => _db
      .into(_db.skinProfileRows)
      .insertOnConflictUpdate(
        SkinProfileRowsCompanion(
          id: const Value(1),
          skinType: Value(profile.skinType?.name),
          concerns: Value(_join(profile.concerns)),
          sensitivity: Value(profile.sensitivity?.name),
          safetyFlags: Value(
            profile.safetyFlags == null ? null : _join(profile.safetyFlags!),
          ),
          budget: Value(profile.budget?.name),
        ),
      );

  @override
  Future<void> clear() => _db.delete(_db.skinProfileRows).go();
}

class DriftRoutineLogRepository implements RoutineLogRepository {
  DriftRoutineLogRepository(this._db);

  final AppDatabase _db;

  /// "2026-10-15".
  static String _dayText(DateTime day) {
    final d = dateOnly(day);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  @override
  Future<Set<String>> doneKeys(DateTime day) async {
    final rows = await (_db.select(
      _db.routineLogRows,
    )..where((r) => r.day.equals(_dayText(day)))).get();
    return Set.unmodifiable({for (final r in rows) r.stepKey});
  }

  @override
  Future<void> setDone(DateTime day, String key, bool done) async {
    final text = _dayText(day);
    if (done) {
      await _db
          .into(_db.routineLogRows)
          .insertOnConflictUpdate(
            RoutineLogRowsCompanion.insert(day: text, stepKey: key),
          );
    } else {
      await (_db.delete(
        _db.routineLogRows,
      )..where((r) => r.day.equals(text) & r.stepKey.equals(key))).go();
    }
  }
}

class DriftCheckInRepository implements CheckInRepository {
  DriftCheckInRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> save(CheckIn checkIn) => _db
      .into(_db.checkInRows)
      .insert(
        CheckInRowsCompanion.insert(
          date: checkIn.date,
          week: checkIn.week,
          skinFeel: Value(checkIn.answers.skinFeel?.name),
          breakouts: Value(checkIn.answers.breakouts?.name),
          note: Value(checkIn.answers.note),
          outcome: checkIn.outcome.name,
        ),
      );

  @override
  Future<List<CheckIn>> all() async {
    final rows = await (_db.select(
      _db.checkInRows,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    return [
      for (final r in rows)
        CheckIn(
          date: r.date,
          week: r.week,
          answers: CheckInAnswers(
            skinFeel: _enumOrNull(SkinFeel.values, r.skinFeel),
            breakouts: _enumOrNull(BreakoutChange.values, r.breakouts),
            note: r.note,
          ),
          outcome:
              _enumOrNull(CheckInOutcome.values, r.outcome) ??
              CheckInOutcome.keepGoing,
        ),
    ];
  }
}

class DriftScanHistoryRepository implements ScanHistoryRepository {
  DriftScanHistoryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> add(CompletedScan scan) => _db.transaction(() async {
    await _db
        .into(_db.scanRows)
        .insertOnConflictUpdate(
          ScanRowsCompanion.insert(id: scan.id, takenAt: scan.takenAt),
        );
    for (final photo in scan.photos) {
      await _db
          .into(_db.scanPhotoRows)
          .insertOnConflictUpdate(
            ScanPhotoRowsCompanion.insert(
              scanId: scan.id,
              pose: photo.pose.name,
              reference: photo.reference,
            ),
          );
    }
  });

  @override
  Future<List<CompletedScan>> all() async {
    final scans = await (_db.select(
      _db.scanRows,
    )..orderBy([(r) => OrderingTerm.asc(r.takenAt)])).get();
    final photos = await _db.select(_db.scanPhotoRows).get();

    return [
      for (final scan in scans)
        CompletedScan(
          id: scan.id,
          takenAt: scan.takenAt,
          photos: [
            for (final pose in FacePose.values)
              for (final p in photos.where(
                (p) => p.scanId == scan.id && p.pose == pose.name,
              ))
                StoredPhoto(
                  scanId: scan.id,
                  pose: pose,
                  reference: p.reference,
                ),
          ],
        ),
    ];
  }
}

class DriftOnboardingRepository implements OnboardingRepository {
  DriftOnboardingRepository(this._db);

  final AppDatabase _db;
  static const _quizKey = 'quizDone';

  @override
  Future<bool> quizDone() async {
    final row = await (_db.select(
      _db.flagRows,
    )..where((r) => r.name.equals(_quizKey))).getSingleOrNull();
    return row?.value ?? false;
  }

  @override
  Future<void> setQuizDone({required bool done}) => _db
      .into(_db.flagRows)
      .insertOnConflictUpdate(
        FlagRowsCompanion.insert(name: _quizKey, value: done),
      );
}
