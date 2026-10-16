import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saaf/core/error/failure.dart';

part 'skin_quiz_state.freezed.dart';

/// One step of the skin quiz. [selected] keeps pick order so a third pick on
/// the concerns step can replace the earliest one.
@freezed
abstract class SkinQuizState with _$SkinQuizState {
  const factory SkinQuizState({
    @Default(<Enum>[]) List<Enum> selected,
    @Default(false) bool isSubmitting,
    Failure? failure,
  }) = _SkinQuizState;

  const SkinQuizState._();

  bool get canSubmit => selected.isNotEmpty && !isSubmitting;
}
