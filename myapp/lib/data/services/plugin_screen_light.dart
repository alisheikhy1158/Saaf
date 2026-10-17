import 'package:saaf/domain/services/screen_light.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Full brightness for the app's window only (no permission needed), through
/// the `screen_brightness` plugin. A phone that refuses is simply left as it
/// is: the scan still works, the light frame still helps.
class PluginScreenLight implements ScreenLight {
  const PluginScreenLight();

  @override
  Future<void> brighten() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1);
    } on Object {
      // Not available on this phone.
    }
  }

  @override
  Future<void> restore() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } on Object {
      // Not available on this phone.
    }
  }
}
