import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saaf/domain/entities/skin_concern.dart';

part 'skin_profile.freezed.dart';

/// What the user told us about their skin in the quiz. Grows as more quiz
/// steps are designed.
@freezed
abstract class SkinProfile with _$SkinProfile {
  const factory SkinProfile({required Set<SkinConcern> concerns}) =
      _SkinProfile;
}
