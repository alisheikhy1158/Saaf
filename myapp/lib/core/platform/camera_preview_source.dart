import 'package:flutter/widgets.dart';

/// Gives the scan screen the live camera picture without it knowing which
/// camera plugin (or fake) is behind it. The data layer implements this next to
/// `CameraService`; presentation only ever sees this interface.
abstract interface class CameraPreviewSource {
  /// The live picture, or an empty box while the camera is not running.
  Widget buildPreview(BuildContext context);
}
