import 'package:saaf/domain/services/screen_light.dart';

/// Remembers whether the screen would be at full brightness (Chrome, tests).
class FakeScreenLight implements ScreenLight {
  bool bright = false;

  @override
  Future<void> brighten() async => bright = true;

  @override
  Future<void> restore() async => bright = false;
}
