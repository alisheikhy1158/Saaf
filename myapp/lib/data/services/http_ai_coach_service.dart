import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:saaf/data/services/ai_routine_plan_json.dart';
import 'package:saaf/data/services/ai_skin_estimate_json.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/ai_skin_estimate.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/pk_city.dart';
import 'package:saaf/domain/entities/safety_check.dart';
import 'package:saaf/domain/entities/skin_weather.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/services/ai_safety_service.dart';
import 'package:saaf/domain/services/ai_skin_service.dart';
import 'package:saaf/domain/services/weather_service.dart';
import 'package:saaf/domain/services/auth_token_provider.dart';

/// The AI coach through OUR OWN server (a small proxy in front of an open-source
/// model on Groq). The app never holds an AI key: it sends the user's Firebase
/// sign-in token, and the server checks it, adds the secret key and the safety
/// instructions, and keeps a daily limit per user.
///
/// Only the chat, the optional photos and a few non-health facts about the
/// user's skin are sent (see [AiContext]); never their name, number or safety
/// answers. Saaf AI's product help (picks and look-ups) goes the same way.
class HttpAiCoachService
    implements
        AiCoachService,
        AiProductService,
        AiSkinService,
        AiSafetyService,
        WeatherService {
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
      'context': _contextJson(context),
    });
    final body = _decode(sent);
    if (body case Err(:final failure)) return Err(failure);
    final reply = body.valueOrNull!['reply'];
    if (reply is String && reply.trim().isNotEmpty) return Ok(reply.trim());
    return const Err(UnknownFailure('ai-reply'));
  }

  @override
  Future<Result<AiRoutinePlan>> planRoutine({
    required AiContext context,
    required List<OwnedProduct> currentProducts,
    Map<SkinMetricKind, double> scan = const {},
  }) async {
    final sent = await _post('/v1/routine', {
      'context': _contextJson(context),
      'scan': {for (final e in scan.entries) e.key.name: e.value},
      'current': [
        for (final p in currentProducts)
          {'name': p.name, 'step': p.step?.name ?? 'other'},
      ],
    });
    final body = _decode(sent);
    if (body case Err(:final failure)) return Err(failure);
    final plan = AiRoutinePlanJson.decode(body.valueOrNull);
    return plan == null ? const Err(UnknownFailure('ai-routine')) : Ok(plan);
  }

  @override
  Future<Result<AiSkinEstimate>> estimateSkin({
    required Uint8List photo,
    required String languageCode,
  }) async {
    final sent = await _post('/v1/skin', {
      'image': base64Encode(photo),
      'context': {'language': languageCode},
    });
    final body = _decode(sent);
    if (body case Err(:final failure)) return Err(failure);
    final estimate = AiSkinEstimateJson.decode(body.valueOrNull);
    return estimate == null
        ? const Err(UnknownFailure('ai-skin'))
        : Ok(estimate);
  }

  @override
  Future<Result<SafetyCheck>> checkSafety({
    required CreamQuery query,
    required AiContext context,
  }) async {
    final sent = await _post('/v1/safety', {
      ...switch (query) {
        CreamPhotoQuery(:final bytes) => {'image': base64Encode(bytes)},
        CreamNameQuery(:final name) => {'name': name},
      },
      'context': _contextJson(context),
    });
    final body = _decode(sent);
    if (body case Err(:final failure)) return Err(failure);
    final data = body.valueOrNull!;
    if (data['found'] != true) return const Ok(SafetyCheck(found: false));
    String text(Object? v) => v is String ? v.trim() : '';
    final printed = data['ingredientsPrinted'];
    return Ok(
      SafetyCheck(
        found: true,
        title: text(data['title']),
        level: switch (data['level']) {
          'danger' => SafetyLevel.danger,
          'no_known_problem' => SafetyLevel.noKnownProblem,
          _ => SafetyLevel.caution,
        },
        summary: text(data['summary']),
        ingredients: [
          if (data['ingredients'] case final List<Object?> list)
            for (final i in list)
              if (i is String && i.trim().isNotEmpty) i.trim(),
        ],
        ingredientsPrinted: printed is bool ? printed : null,
        findings: [
          if (data['findings'] case final List<Object?> list)
            for (final f in list)
              if (f case {'text': final String t} when t.trim().isNotEmpty)
                SafetyFinding(
                  text: t.trim(),
                  source: switch (f['source']) {
                    final String url when url.startsWith('http') => url,
                    _ => null,
                  },
                ),
        ],
      ),
    );
  }

  @override
  Future<Result<SkinWeather>> today(PkCity city) async {
    final sent = await _post('/v1/weather', {'lat': city.lat, 'lon': city.lon});
    final body = _decode(sent);
    if (body case Err(:final failure)) return Err(failure);
    final data = body.valueOrNull!;
    final temperature = data['temperature'];
    if (temperature is! num) return const Err(UnknownFailure('weather'));
    int? whole(Object? v) => v is num ? v.round() : null;
    double? decimal(Object? v) => v is num ? v.toDouble() : null;
    return Ok(
      SkinWeather(
        temperatureC: temperature.round(),
        humidity: whole(data['humidity']),
        uvNow: decimal(data['uvNow']),
        uvMax: decimal(data['uvMax']),
        aqi: whole(data['aqi']),
        pm25: whole(data['pm25']),
      ),
    );
  }

  @override
  Future<Result<ProductInsight>> lookUpProduct({
    required ProductQuery query,
    required AiContext context,
  }) async {
    final sent = await _post('/v1/product', {
      ...switch (query) {
        ProductPhotoQuery(:final bytes) => {'image': base64Encode(bytes)},
        ProductBarcodeQuery(:final digits) => {'barcode': digits},
        ProductQrQuery(:final text) => {'qr': text},
        ProductDupeQuery(:final name) => {'dupe': name},
      },
      'context': _contextJson(context),
    });
    final body = _decode(sent);
    if (body case Err(:final failure)) return Err(failure);
    final data = body.valueOrNull!;
    final text = data['insight'];
    if (data['found'] != true || text is! String || text.trim().isEmpty) {
      return const Ok(ProductInsight.notFound());
    }
    final title = data['title'];
    return Ok(
      ProductInsight(
        title: title is String && title.trim().isNotEmpty ? title.trim() : null,
        text: text.trim(),
        webChecked: data['webChecked'] == true,
      ),
    );
  }

  static Map<String, Object?> _contextJson(AiContext context) => {
    'language': context.languageCode,
    'skinType': context.skinType?.name,
    'concerns': [for (final c in context.concerns) c.name]..sort(),
    'sensitivity': context.sensitivity?.name,
    'budget': context.budget?.name,
    'routine': context.routineProducts,
  };

  /// The server's short error code ("timeout", "groq_400"…), if it sent one.
  static String? _reason(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      final error = body is Map<String, dynamic> ? body['error'] : null;
      return error is String && error.length <= 40 ? error : null;
    } on Object {
      return null;
    }
  }

  /// The JSON object our server answered with.
  static Result<Map<String, dynamic>> _decode(Result<http.Response> sent) {
    final response = sent.valueOrNull;
    if (response == null) return Err(sent.failureOrNull!);
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic>) return Ok(body);
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
      _ when status >= 500 => ServiceUnavailable(_reason(response)),
      _ => UnknownFailure('ai-http-$status'),
    });
  }
}
