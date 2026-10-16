import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saaf/app.dart';
import 'package:saaf/data/local/app_database.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The database lives on the phone. On the web (Chrome demos) drift needs extra
  // setup files (OFF-6), so the in-memory repositories are used there.
  final database = kIsWeb ? null : AppDatabase(driftDatabase(name: 'saaf'));
  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const SaafApp(),
    ),
  );
}
