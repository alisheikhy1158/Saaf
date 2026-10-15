import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/skin_concern.dart';

part 'skin_quiz_state.freezed.dart';

/// The concerns step of the skin quiz. [selected] keeps pick order so a third
/// pick can replace the earliest one.
@freezed
abstract class SkinQuizState with _$SkinQuizState {
  const factory SkinQuizState({
    @Default(<SkinConcern>[]) List<SkinConcern> selected,
    @Default(false) bool isSubmitting,
    Failure? failure,
  }) = _SkinQuizState;

  const SkinQuizState._();

  bool get canSubmit => selected.isNotEmpty && !isSubmitting;
}
