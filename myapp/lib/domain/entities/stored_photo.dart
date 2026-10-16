import 'package:saaf/domain/entities/face_pose.dart';

/// A photo saved in the app's private storage. [reference] is whatever the
/// store needs to find it again (a relative path).
class StoredPhoto {
  const StoredPhoto({
    required this.scanId,
    required this.pose,
    required this.reference,
  });

  final String scanId;
  final FacePose pose;
  final String reference;

  @override
  bool operator ==(Object other) =>
      other is StoredPhoto &&
      other.scanId == scanId &&
      other.pose == pose &&
      other.reference == reference;

  @override
  int get hashCode => Object.hash(scanId, pose, reference);
}
