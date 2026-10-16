import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The user's consent: one row (id 1).
class ConsentRows extends Table {
  IntColumn get id => integer()();
  DateTimeColumn get acceptedAt => dateTime()();
  TextColumn get policyVersion => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The quiz answers: one row (id 1). Enums are stored by name; [concerns] is a
/// comma-separated list. A null [safetyFlags] means "not answered", an empty
/// string means "none of these".
class SkinProfileRows extends Table {
  IntColumn get id => integer()();
  TextColumn get skinType => text().nullable()();
  TextColumn get concerns => text().withDefault(const Constant(''))();
  TextColumn get sensitivity => text().nullable()();
  TextColumn get safetyFlags => text().nullable()();
  TextColumn get budget => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A finished face scan. The photos themselves are files in private storage.
class ScanRows extends Table {
  TextColumn get id => text()();
  DateTimeColumn get takenAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ScanPhotoRows extends Table {
  TextColumn get scanId => text().references(ScanRows, #id)();
  TextColumn get pose => text()();
  TextColumn get reference => text()();

  @override
  Set<Column<Object>> get primaryKey => {scanId, pose};
}

/// Routine steps done on a day ([day] is "2026-10-15").
class RoutineLogRows extends Table {
  TextColumn get day => text()();
  TextColumn get stepKey => text()();

  @override
  Set<Column<Object>> get primaryKey => {day, stepKey};
}

class CheckInRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get week => integer()();
  TextColumn get skinFeel => text().nullable()();
  TextColumn get breakouts => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get outcome => text()();
}

/// Small yes/no facts, such as "the quiz was finished".
class FlagRows extends Table {
  TextColumn get name => text()();
  BoolColumn get value => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

/// Small settings by name (reminders, language, appearance). Added in
/// schema version 2.
class SettingRows extends Table {
  TextColumn get name => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

/// The phone's own database (OFF-1): the single source of truth for everything
/// the user has told or done. Nothing here is sent anywhere.
@DriftDatabase(
  tables: [
    ConsentRows,
    SkinProfileRows,
    ScanRows,
    ScanPhotoRows,
    RoutineLogRows,
    CheckInRows,
    FlagRows,
    SettingRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(settingRows);
    },
    beforeOpen: (details) async {
      // Photos reference scans; keep that honest.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Deletes everything (account deletion, SEC-7).
  Future<void> wipe() => transaction(() async {
    // Newest table first, so photos go before the scans they point at.
    for (final table in allTables.toList().reversed) {
      await delete(table).go();
    }
  });
}
