import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/usecases/save_skin_concerns.dart';
import 'package:saaf/presentation/features/onboarding/state/skin_quiz_state.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'skin_quiz_controller.g.dart';

@riverpod
class SkinQuizController extends _$SkinQuizController {
  @override
  SkinQuizState build() => const SkinQuizState();

  /// Selects or unselects [concern]. Picking a third one drops the earliest.
  void toggle(SkinConcern concern) {
    final selected = [...state.selected];
    if (!selected.remove(concern)) {
      selected.add(concern);
      while (selected.length > SaveSkinConcerns.maxConcerns) {
        selected.removeAt(0);
      }
    }
    state = state.copyWith(selected: selected, failure: null);
  }

  /// Saves the picks. Returns true when they were saved.
  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    state = state.copyWith(isSubmitting: true, failure: null);
    final result = await ref.read(saveSkinConcernsProvider)(
      state.selected.toSet(),
    );
    state = state.copyWith(isSubmitting: false, failure: result.failureOrNull);
    return result.isOk;
  }
}
