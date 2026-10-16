import 'package:saaf/domain/entities/stored_photo.dart';

/// A finished face scan: its three photos, saved in private storage.
class CompletedScan {
  const CompletedScan({
    required this.id,
    required this.takenAt,
    required this.photos,
  });

  final String id;
  final DateTime takenAt;

  /// Front, left, right.
  final List<StoredPhoto> photos;
}
