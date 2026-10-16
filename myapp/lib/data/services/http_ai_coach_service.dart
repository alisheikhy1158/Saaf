import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/services/auth_token_provider.dart';

/// The AI coach through OUR OWN server (a small proxy in front of an open-source
/// model on Groq). The app never holds an AI key: it sends the user's Firebase
/// sign-in token, and the server checks it, adds the secret key and the safety
/// instructions, and keeps a daily limit per user.
///
/// Only the chat, the optional photos and a few non-health facts about the
/// user's skin are sent (see [AiContext]); never their name, number or safety
/// answers.
class HttpAiCoachService implements AiCoachService {
  HttpAiCoachService({
    required String baseUrl,
    required AuthTokenProvider tokens,
    http.Client? client,
    this.timeout = const Duration(seconds: 60),
  }) : _base = baseUrl.trim().replaceAll(RegExp(r'/+$'), ''),
       _tokens = tokens,
       _client = client ?? http.Client();

  final String _base;
  final AuthTokenProvider _tokens;
  final http.Client _client;

  /// Photo questions are slower than text ones, so the wait is generous.
  final Duration timeout;

  @override
  Future<Result<String>> ask({
    required List<AiMessage> history,
    required String question,
    required List<Uint8List> photos,
    required AiContext context,
  }) async {
    final sent = await _post('/v1/chat', {
      'history': [
        for (final message in history)
          {'role': message.role.name, 'text': message.text},
      ],
      'question': question,
      'images': [for (final photo in photos) base64Encode(photo)],
      'context': {
        'language': context.languageCode,
        'skinType': context.skinType?.name,
        'concerns': [for (final c in context.concerns) c.name]..sort(),
        'sensitivity': context.sensitivity?.name,
        'budget': context.budget?.name,
        'routine': context.routineProducts,
      },
    });
    final response = sent.valueOrNull;
    if (response == null) return Err(sent.failureOrNull!);

    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      final reply = body is Map<String, dynamic> ? body['reply'] : null;
      if (reply is String && reply.trim().isNotEmpty) return Ok(reply.trim());
    } on Object {
      // Fall through to the failure below.
    }
    return const Err(UnknownFailure('ai-reply'));
  }

  @override
  Future<Result<void>> report({
    required AiMessage reply,
    required String reason,
  }) async {
    final sent = await _post('/v1/report', {
      'reason': reason,
      'replyId': reply.id,
      'replyText': reply.text,
    });
    final failure = sent.failureOrNull;
    return failure == null ? const Ok<void>(null) : Err(failure);
  }

  Future<Result<http.Response>> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    if (_base.isEmpty) return const Err(ServiceUnavailable());
    final token = await _tokens.idToken();
    if (token == null) return const Err(Unauthorised());

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_base$path'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on Object {
      // No connection, a slow server, a closed client: all "try again".
      return const Err(NetworkFailure());
    }

    final status = response.statusCode;
    if (status >= 200 && status < 300) return Ok(response);
    return Err(switch (status) {
      400 => const ValidationFailure('message'),
      401 || 403 => const Unauthorised(),
      429 => const RateLimited(),
      _ when status >= 500 => const ServiceUnavailable(),
      _ => UnknownFailure('ai-http-$status'),
    });
  }
}
