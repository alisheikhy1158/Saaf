import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/utils/week.dart';
import 'package:saaf/domain/entities/check_in.dart';
import 'package:saaf/domain/usecases/evaluate_check_in.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/check_in_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';

part 'check_in_controller.g.dart';

/// One line of the conversation. The screen turns these into (translated) text.
sealed class ChatItem {
  const ChatItem();
}

class CoachGreeting extends ChatItem {
  const CoachGreeting(this.name);

  /// The user's first name, when known.
  final String? name;
}

class CoachBreakoutsQuestion extends ChatItem {
  const CoachBreakoutsQuestion(this.after);

  /// What the user just said, so the coach can answer it ("Nice.", "Sorry to hear that.").
  final SkinFeel after;
}

class CoachNoteSaved extends ChatItem {
  const CoachNoteSaved();
}

class UserSkinFeel extends ChatItem {
  const UserSkinFeel(this.value);
  final SkinFeel value;
}

class UserBreakouts extends ChatItem {
  const UserBreakouts(this.value);
  final BreakoutChange value;
}

class UserText extends ChatItem {
  const UserText(this.text);
  final String text;
}

/// Which question is waiting for an answer.
enum CheckInStep { skinFeel, breakouts, done }

class CheckInState {
  const CheckInState({
    required this.messages,
    required this.step,
    required this.answers,
    required this.week,
    this.outcome,
    this.nextPhotoCheck,
  });

  final List<ChatItem> messages;
  final CheckInStep step;
  final CheckInAnswers answers;

  /// Which week of the routine this is (1-based).
  final int week;
  final CheckInOutcome? outcome;

  /// When the next progress photo is due, if the user has taken one.
  final DateTime? nextPhotoCheck;

  CheckInState copyWith({
    List<ChatItem>? messages,
    CheckInStep? step,
    CheckInAnswers? answers,
    CheckInOutcome? outcome,
  }) => CheckInState(
    messages: messages ?? this.messages,
    step: step ?? this.step,
    answers: answers ?? this.answers,
    week: week,
    outcome: outcome ?? this.outcome,
    nextPhotoCheck: nextPhotoCheck,
  );
}

/// The weekly check-in conversation: two questions answered by quick replies or
/// typed text, then a rule-based outcome (no AI) that is saved on the phone.
@riverpod
class CheckInController extends _$CheckInController {
  @override
  CheckInState build() {
    final now = ref.read(clockProvider).now();
    final scan = ref.read(completedScanProvider);
    final name = _firstName(
      ref.read(authSessionControllerProvider)?.displayName,
    );

    return CheckInState(
      messages: [CoachGreeting(name)],
      step: CheckInStep.skinFeel,
      answers: const CheckInAnswers(),
      week: scan == null ? 1 : weekNumberSince(scan.takenAt, now),
      nextPhotoCheck: scan == null ? null : nextProgressPhoto(scan.takenAt),
    );
  }

  void answerSkinFeel(SkinFeel value) {
    if (state.step != CheckInStep.skinFeel) return;
    _askBreakouts(
      UserSkinFeel(value),
      state.answers.copyWith(skinFeel: value),
      value,
    );
  }

  void answerBreakouts(BreakoutChange value) {
    if (state.step != CheckInStep.breakouts) return;
    _finish(UserBreakouts(value), state.answers.copyWith(breakouts: value));
  }

  /// Typed text answers the open question as "other" (the coach does not read
  /// it) and is kept as a note. After the check-in it is just saved.
  void sendText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final existing = state.answers.note;
    final withNote = state.answers.copyWith(
      note: existing == null ? trimmed : '$existing\n$trimmed',
    );

    switch (state.step) {
      case CheckInStep.skinFeel:
        _askBreakouts(
          UserText(trimmed),
          withNote.copyWith(skinFeel: SkinFeel.other),
          SkinFeel.other,
        );
      case CheckInStep.breakouts:
        _finish(
          UserText(trimmed),
          withNote.copyWith(breakouts: BreakoutChange.other),
        );
      case CheckInStep.done:
        state = state.copyWith(
          answers: withNote,
          messages: [
            ...state.messages,
            UserText(trimmed),
            const CoachNoteSaved(),
          ],
        );
    }
  }

  void _askBreakouts(ChatItem reply, CheckInAnswers answers, SkinFeel after) {
    state = state.copyWith(
      step: CheckInStep.breakouts,
      answers: answers,
      messages: [...state.messages, reply, CoachBreakoutsQuestion(after)],
    );
  }

  void _finish(ChatItem reply, CheckInAnswers answers) {
    final outcome = const EvaluateCheckIn()(answers, week: state.week);
    state = state.copyWith(
      step: CheckInStep.done,
      answers: answers,
      outcome: outcome,
      messages: [...state.messages, reply],
    );
    ref
        .read(checkInRepositoryProvider)
        .save(
          CheckIn(
            date: ref.read(clockProvider).now(),
            week: state.week,
            answers: answers,
            outcome: outcome,
          ),
        );
  }

  /// "Ayesha Khan" → "Ayesha".
  static String? _firstName(String? displayName) {
    final first = displayName?.trim().split(RegExp(r'\s+')).first;
    return first == null || first.isEmpty ? null : first;
  }
}
