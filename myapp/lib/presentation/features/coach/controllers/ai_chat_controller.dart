import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/usecases/ask_coach.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'ai_chat_controller.g.dart';

const Object _keep = Object();

/// Everything the AI coach screen shows.
class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.pendingPhotos = const [],
    this.sending = false,
    this.failure,
    this.photoFailed = false,
  });

  final List<AiMessage> messages;

  /// Photos chosen for the next message (at most [AskCoach.maxPhotos]).
  final List<Uint8List> pendingPhotos;
  final bool sending;

  /// Why the last question got no answer; the question stays so it can be
  /// sent again.
  final Failure? failure;

  /// The last attempt to get a photo failed.
  final bool photoFailed;

  AiChatState copyWith({
    List<AiMessage>? messages,
    List<Uint8List>? pendingPhotos,
    bool? sending,
    Object? failure = _keep,
    bool? photoFailed,
  }) => AiChatState(
    messages: messages ?? this.messages,
    pendingPhotos: pendingPhotos ?? this.pendingPhotos,
    sending: sending ?? this.sending,
    failure: identical(failure, _keep) ? this.failure : failure as Failure?,
    photoFailed: photoFailed ?? this.photoFailed,
  );
}

/// The AI coach conversation. Kept in memory only (never saved on the phone or
/// our server) and wiped when the user stops sharing with the AI.
@Riverpod(keepAlive: true)
class AiChatController extends _$AiChatController {
  int _counter = 0;

  @override
  AiChatState build() {
    // Withdrawing permission also wipes the conversation.
    ref.listen(aiConsentStateProvider, (before, now) {
      if (now == false && before != false) clear();
    });
    return const AiChatState();
  }

  String _id() => 'm${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

  /// Sends the typed text (and any attached photos) to the coach.
  Future<void> send(String text, {required String languageCode}) async {
    if (state.sending) return;
    final question = text.trim();
    final photos = state.pendingPhotos;
    if (question.isEmpty && photos.isEmpty) return;

    final earlier = state.messages;
    final asked = AiMessage(
      id: _id(),
      role: AiRole.user,
      text: question,
      createdAt: DateTime.now(),
      photoCount: photos.length,
    );
    state = state.copyWith(
      messages: [...earlier, asked],
      sending: true,
      failure: null,
    );

    final profile = ref.read(skinProfileControllerProvider);
    var routine = const Routine(morning: [], night: []);
    try {
      routine = await ref.read(routineProvider.future);
    } on Object {
      // No routine yet: the coach still answers without it.
    }

    final result = await ref.read(askCoachProvider)(
      text: question,
      photos: photos,
      history: earlier,
      profile: profile,
      routine: routine,
      languageCode: languageCode,
    );
    if (!ref.mounted) return;

    final reply = result.valueOrNull;
    if (reply != null) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          AiMessage(
            id: _id(),
            role: AiRole.assistant,
            text: reply,
            createdAt: DateTime.now(),
          ),
        ],
        pendingPhotos: const [],
        sending: false,
      );
      return;
    }

    final failure = result.failureOrNull;
    state = state.copyWith(sending: false, failure: failure);
    if (failure is ConsentMissing) {
      await ref.read(aiConsentStateProvider.notifier).withdraw();
    }
  }

  /// Sends the last question again after a failure (the question is not
  /// duplicated in the chat).
  Future<void> retry({required String languageCode}) async {
    if (state.sending || state.failure == null) return;
    final last = state.messages.lastOrNull;
    if (last == null || !last.isFromUser) return;
    state = state.copyWith(
      messages: state.messages.sublist(0, state.messages.length - 1),
      failure: null,
    );
    await send(last.text, languageCode: languageCode);
  }

  void dismissFailure() => state = state.copyWith(failure: null);

  Future<void> attach(AiPhotoSource source) async {
    if (state.pendingPhotos.length >= AskCoach.maxPhotos) return;
    final result = await ref.read(aiPhotoPickerProvider).pick(source);
    if (!ref.mounted) return;
    switch (result) {
      case Ok(:final value):
        if (value == null) return; // cancelled
        state = state.copyWith(
          pendingPhotos: [...state.pendingPhotos, value],
          photoFailed: false,
        );
      case Err():
        state = state.copyWith(photoFailed: true);
    }
  }

  void removePhoto(int index) {
    if (index < 0 || index >= state.pendingPhotos.length) return;
    state = state.copyWith(
      pendingPhotos: [...state.pendingPhotos]..removeAt(index),
    );
  }

  /// Tells us an answer was harmful, wrong or offensive. True when it was sent.
  Future<bool> report(AiMessage reply, String reason) async {
    if (reply.reported) return false;
    final result = await ref
        .read(aiCoachServiceProvider)
        .report(reply: reply, reason: reason);
    if (!ref.mounted || !result.isOk) return false;
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.id == reply.id) m.copyWith(reported: true) else m,
      ],
    );
    return true;
  }

  void clear() => state = const AiChatState();
}
