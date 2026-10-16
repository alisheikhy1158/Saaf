import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/domain/entities/face_pose.dart';

/// The words for each of the three photos.
extension FacePoseText on FacePose {
  /// Short name: "Front", "Left", "Right".
  String label(AppLocalizations l10n) => switch (this) {
    FacePose.front => l10n.scanPoseFront,
    FacePose.left => l10n.scanPoseLeft,
    FacePose.right => l10n.scanPoseRight,
  };

  /// What the user should do: "Show your left cheek".
  String instruction(AppLocalizations l10n) => switch (this) {
    FacePose.front => l10n.scanInstructionFront,
    FacePose.left => l10n.scanInstructionLeft,
    FacePose.right => l10n.scanInstructionRight,
  };
}
