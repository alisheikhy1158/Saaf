import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/scan_photo.dart';

/// A scan in progress: up to one photo per [FacePose]. Immutable; every change
/// returns a new session.
class ScanSession {
  ScanSession._(this.id, this.startedAt, Map<FacePose, ScanPhoto> photos)
    : photos = Map.unmodifiable(photos);

  factory ScanSession.start({
    required String id,
    required DateTime startedAt,
  }) => ScanSession._(id, startedAt, const {});

  final String id;
  final DateTime startedAt;
  final Map<FacePose, ScanPhoto> photos;

  int get capturedCount => photos.length;
  bool get isComplete => photos.length == FacePose.count;

  /// The first pose that has no photo yet, or null when all three are taken.
  FacePose? get nextMissing {
    for (final pose in FacePose.values) {
      if (!photos.containsKey(pose)) return pose;
    }
    return null;
  }

  /// The photos in pose order (front, left, right).
  List<ScanPhoto> get orderedPhotos => [
    for (final pose in FacePose.values)
      if (photos[pose] != null) photos[pose]!,
  ];

  /// Adds [photo], replacing an earlier one of the same pose (a retake).
  ScanSession withPhoto(ScanPhoto photo) =>
      ScanSession._(id, startedAt, {...photos, photo.pose: photo});

  ScanSession withoutPose(FacePose pose) =>
      ScanSession._(id, startedAt, {...photos}..remove(pose));
}
