/// Who wrote a chat message.
enum AiRole { user, assistant }

/// One message in the AI coach chat.
class AiMessage {
  const AiMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.photoCount = 0,
    this.reported = false,
  });

  final String id;
  final AiRole role;
  final String text;
  final DateTime createdAt;

  /// How many photos the user attached (their pictures are not kept in the
  /// chat, only this count).
  final int photoCount;

  /// The user reported this AI reply as harmful or wrong.
  final bool reported;

  bool get isFromUser => role == AiRole.user;

  AiMessage copyWith({bool? reported}) => AiMessage(
    id: id,
    role: role,
    text: text,
    createdAt: createdAt,
    photoCount: photoCount,
    reported: reported ?? this.reported,
  );
}
