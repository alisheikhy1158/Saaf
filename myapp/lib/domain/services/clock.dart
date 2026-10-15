/// Source of "now", injected so logic is deterministic in tests.
abstract interface class Clock {
  DateTime now();
}
