// Covers: OFF-1 — the drift database opens, stores and wipes (in memory here)
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/local/app_database.dart';

AppDatabase memory() => AppDatabase(NativeDatabase.memory());

void main() {
  test('stores and reads a row', () async {
    final db = memory();
    addTearDown(db.close);
    await db
        .into(db.flagRows)
        .insert(FlagRowsCompanion.insert(name: 'quizDone', value: true));
    final rows = await db.select(db.flagRows).get();
    expect(rows.single.name, 'quizDone');
    expect(rows.single.value, isTrue);
  });

  test('wipe empties every table', () async {
    final db = memory();
    addTearDown(db.close);
    await db
        .into(db.scanRows)
        .insert(
          ScanRowsCompanion.insert(id: 's', takenAt: DateTime(2026, 10, 1)),
        );
    await db
        .into(db.scanPhotoRows)
        .insert(
          ScanPhotoRowsCompanion.insert(
            scanId: 's',
            pose: 'front',
            reference: 'r',
          ),
        );
    await db
        .into(db.routineLogRows)
        .insert(
          RoutineLogRowsCompanion.insert(day: '2026-10-15', stepKey: 'a'),
        );
    await db.wipe();
    expect(await db.select(db.scanRows).get(), isEmpty);
    expect(await db.select(db.scanPhotoRows).get(), isEmpty);
    expect(await db.select(db.routineLogRows).get(), isEmpty);
  });

  test('a photo cannot point at a scan that does not exist', () async {
    final db = memory();
    addTearDown(db.close);
    await expectLater(
      db
          .into(db.scanPhotoRows)
          .insert(
            ScanPhotoRowsCompanion.insert(
              scanId: 'nope',
              pose: 'front',
              reference: 'r',
            ),
          ),
      throwsA(isA<Object>()),
    );
  });
}
