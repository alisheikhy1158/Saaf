import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/local/app_database.dart';

part 'database_providers.g.dart';

/// The phone's database. `main()` overrides it with the real one; it is null in
/// tests and in Chrome (drift on the web needs extra setup files, OFF-6), where
/// the in-memory repositories are used instead.
@Riverpod(keepAlive: true)
AppDatabase? appDatabase(Ref ref) => null;
