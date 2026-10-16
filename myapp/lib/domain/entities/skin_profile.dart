import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';

part 'skin_profile.freezed.dart';

/// What the user told us about their skin in the quiz. Every field is optional:
/// each step can be skipped, and the routine copes with what is known.
@freezed
abstract class SkinProfile with _$SkinProfile {
  const factory SkinProfile({
    SkinType? skinType,
    @Default(<SkinConcern>{}) Set<SkinConcern> concerns,
    Sensitivity? sensitivity,

    /// null = the safety step was not answered; empty = "none of these".
    Set<SafetyFlag>? safetyFlags,
    BudgetBand? budget,
  }) = _SkinProfile;
}
