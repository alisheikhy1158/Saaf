import 'package:saaf/domain/services/clock.dart';

/// The real clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
