import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/repositories/onboarding_repository.dart';
import 'package:saaf/domain/repositories/scan_history_repository.dart';
import 'package:saaf/domain/repositories/settings_repository.dart';

/// In-memory scan history (Chrome and tests; phones use the drift one).
class InMemoryScanHistoryRepository implements ScanHistoryRepository {
  final List<CompletedScan> _scans = [];

  @override
  Future<List<CompletedScan>> all() async => List.unmodifiable(_scans);

  @override
  Future<void> add(CompletedScan scan) async => _scans.add(scan);
}

/// In-memory onboarding flag (Chrome and tests).
class InMemoryOnboardingRepository implements OnboardingRepository {
  bool _done = false;

  @override
  Future<bool> quizDone() async => _done;

  @override
  Future<void> setQuizDone({required bool done}) async => _done = done;
}

/// In-memory settings (Chrome and tests).
class InMemorySettingsRepository implements SettingsRepository {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String name) async => _values[name];

  @override
  Future<void> write(String name, String? value) async {
    if (value == null) {
      _values.remove(name);
    } else {
      _values[name] = value;
    }
  }
}
