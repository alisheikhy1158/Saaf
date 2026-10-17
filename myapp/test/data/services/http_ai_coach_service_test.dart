// Covers: talking to our AI proxy (never to the AI company directly): what is
// sent, how failures are reported, and that no secret lives in the app
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/services/http_ai_coach_service.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/services/auth_token_provider.dart';

class _Tokens implements AuthTokenProvider {
  _Tokens(this.token);
  final String? token;

  @override
  Future<String?> idToken() async => token;
}

const _context = AiContext(
  languageCode: 'ur',
  skinType: SkinType.oily,
  concerns: {SkinConcern.acne},
  sensitivity: Sensitivity.low,
  budget: BudgetBand.essential,
  routineProducts: ['Himalaya Purifying Neem Face Wash'],
);

final _history = [
  AiMessage(
    id: '1',
    role: AiRole.user,
    text: 'Hello',
    createdAt: DateTime(2026, 10, 17),
    photoCount: 2,
  ),
  AiMessage(
    id: '2',
    role: AiRole.assistant,
    text: 'Hi! How can I help?',
    createdAt: DateTime(2026, 10, 17),
  ),
];

http.Response ok(Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

HttpAiCoachService service(
  http.Client client, {
  String baseUrl = 'https://saaf-ai.example.workers.dev',
  String? token = 'firebase-id-token',
  Duration timeout = const Duration(seconds: 5),
}) => HttpAiCoachService(
  baseUrl: baseUrl,
  tokens: _Tokens(token),
  client: client,
  timeout: timeout,
);

Future<Object?> ask(
  HttpAiCoachService s, {
  String question = 'Is niacinamide safe?',
  List<Uint8List> photos = const [],
}) async {
  final result = await s.ask(
    history: _history,
    question: question,
    photos: photos,
    context: _context,
  );
  return result.isOk ? result.valueOrNull : result.failureOrNull;
}

void main() {
  group('a good answer', () {
    test('comes back as text', () async {
      final s = service(MockClient((_) async => ok({'reply': 'Yes, it is.'})));
      expect(await ask(s), 'Yes, it is.');
    });

    test('Urdu text survives the trip', () async {
      final s = service(MockClient((_) async => ok({'reply': 'جی ہاں۔'})));
      expect(await ask(s), 'جی ہاں۔');
    });
  });

  group('what is sent', () {
    late http.Request seen;
    late Map<String, dynamic> body;

    Future<void> run({List<Uint8List> photos = const []}) async {
      final s = service(
        MockClient((request) async {
          seen = request;
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return ok({'reply': 'ok'});
        }),
      );
      await ask(s, photos: photos);
    }

    test('to our server, signed in with the Firebase token', () async {
      await run();
      expect(seen.method, 'POST');
      expect(
        seen.url.toString(),
        'https://saaf-ai.example.workers.dev/v1/chat',
      );
      expect(seen.headers['Authorization'], 'Bearer firebase-id-token');
      expect(seen.headers['Content-Type'], contains('application/json'));
    });

    test('the question, the chat so far and the context', () async {
      await run();
      expect(body['question'], 'Is niacinamide safe?');
      expect(body['history'], [
        {'role': 'user', 'text': 'Hello'},
        {'role': 'assistant', 'text': 'Hi! How can I help?'},
      ]);
      expect(body['context'], {
        'language': 'ur',
        'skinType': 'oily',
        'concerns': ['acne'],
        'sensitivity': 'low',
        'budget': 'essential',
        'routine': ['Himalaya Purifying Neem Face Wash'],
      });
    });

    test('photos as base64 text', () async {
      await run(
        photos: [
          Uint8List.fromList([1, 2, 3]),
        ],
      );
      expect(body['images'], [
        base64Encode([1, 2, 3]),
      ]);
    });

    test('no photos means an empty list', () async {
      await run();
      expect(body['images'], isEmpty);
    });

    test(
      'nothing else about the user: no safety answers, name or phone',
      () async {
        await run();
        final text = jsonEncode(body).toLowerCase();
        for (final word in [
          'pregnan',
          'prescription',
          'allerg',
          'phone',
          'name"',
        ]) {
          expect(text, isNot(contains(word)), reason: word);
        }
        expect(body.keys, {'history', 'question', 'images', 'context'});
      },
    );

    test('a trailing slash on the address does not matter', () async {
      late Uri url;
      final s = service(
        MockClient((request) async {
          url = request.url;
          return ok({'reply': 'ok'});
        }),
        baseUrl: 'https://saaf-ai.example.workers.dev/',
      );
      await ask(s);
      expect(url.path, '/v1/chat');
    });
  });

  group('when it cannot work', () {
    test('no server address on this build', () async {
      var sent = 0;
      final s = service(
        MockClient((_) async {
          sent++;
          return ok({'reply': 'x'});
        }),
        baseUrl: '',
      );
      expect(await ask(s), const ServiceUnavailable());
      expect(sent, 0);
    });

    test('not signed in: nothing is sent', () async {
      var sent = 0;
      final s = service(
        MockClient((_) async {
          sent++;
          return ok({'reply': 'x'});
        }),
        token: null,
      );
      expect(await ask(s), const Unauthorised());
      expect(sent, 0);
    });

    test('the server says the sign-in is no good', () async {
      final s = service(MockClient((_) async => http.Response('', 401)));
      expect(await ask(s), const Unauthorised());
    });

    test('too many questions today', () async {
      final s = service(MockClient((_) async => http.Response('', 429)));
      expect(await ask(s), const RateLimited());
    });

    test('a refused message', () async {
      final s = service(MockClient((_) async => http.Response('', 400)));
      expect(await ask(s), const ValidationFailure('message'));
    });

    test('the server or the AI is down', () async {
      for (final status in [500, 502, 503]) {
        final s = service(MockClient((_) async => http.Response('', status)));
        expect(await ask(s), const ServiceUnavailable(), reason: '$status');
      }
    });

    test('no connection', () async {
      final s = service(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(await ask(s), const NetworkFailure());
    });

    test('too slow', () async {
      final s = service(
        MockClient((_) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          return ok({'reply': 'late'});
        }),
        timeout: const Duration(milliseconds: 50),
      );
      expect(await ask(s), const NetworkFailure());
    });

    test('a reply that is not what we expect', () async {
      for (final response in [
        http.Response('<html>', 200),
        ok({'nothing': true}),
        ok({'reply': ''}),
        ok(['not', 'a', 'map']),
      ]) {
        final s = service(MockClient((_) async => response));
        expect(await ask(s), isA<UnknownFailure>());
      }
    });
  });

  group('reporting a reply', () {
    final reply = AiMessage(
      id: 'r1',
      role: AiRole.assistant,
      text: 'Some harmful advice',
      createdAt: DateTime(2026, 10, 17),
    );

    test('goes to /v1/report with the reason', () async {
      late http.Request seen;
      final s = service(
        MockClient((request) async {
          seen = request;
          return ok({'ok': true});
        }),
      );
      final result = await s.report(reply: reply, reason: 'harmful');
      expect(result.isOk, isTrue);
      expect(seen.url.path, '/v1/report');
      expect(seen.headers['Authorization'], 'Bearer firebase-id-token');
      expect(jsonDecode(seen.body), {
        'reason': 'harmful',
        'replyId': 'r1',
        'replyText': 'Some harmful advice',
      });
    });

    test('a failure is reported as a failure', () async {
      final s = service(MockClient((_) async => http.Response('', 503)));
      final result = await s.report(reply: reply, reason: 'wrong');
      expect(result.failureOrNull, const ServiceUnavailable());
    });
  });

  group('product picks', () {
    const cleanser = Product(
      id: 'cleanser-a',
      name: 'Gentle Cleanser',
      category: ProductCategory.cleanser,
      pricePkr: 900,
      times: {RoutineTime.morning, RoutineTime.night},
      skinTypes: {SkinType.oily, SkinType.notSure},
      targets: {SkinConcern.acne},
      ingredients: {Ingredient.niacinamide},
    );

    test('sends the allowed products, the scan and the skin facts', () async {
      late http.Request seen;
      final s = service(
        MockClient((request) async {
          seen = request;
          return ok({
            'summary': 'A gentle routine.',
            'picks': [
              {'productId': 'cleanser-a', 'reason': 'Calms oil.'},
            ],
          });
        }),
      );
      final result = await s.pickProducts(
        context: _context,
        candidates: const [cleanser],
        scan: const {SkinMetricKind.darkSpots: 0.5},
      );
      expect(seen.url.path, '/v1/recommend');
      expect(seen.headers['Authorization'], 'Bearer firebase-id-token');
      final body = jsonDecode(seen.body) as Map<String, dynamic>;
      expect(body['candidates'], [
        {
          'id': 'cleanser-a',
          'step': 'cleanser',
          'name': 'Gentle Cleanser',
          'pricePkr': 900,
          'times': ['morning', 'night'],
          'forSkin': ['oily'],
          'helpsWith': ['acne'],
          'actives': ['niacinamide'],
        },
      ]);
      expect(body['scan'], {'darkSpots': 0.5});
      expect(body['context'], containsPair('skinType', 'oily'));
      final picks = result.valueOrNull!;
      expect(picks.summary, 'A gentle routine.');
      expect(picks.reasonFor('cleanser-a'), 'Calms oil.');
    });

    test('a reply without picks is a failure', () async {
      final s = service(MockClient((_) async => ok({'summary': 'x'})));
      final result = await s.pickProducts(
        context: _context,
        candidates: const [cleanser],
      );
      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });

  group('product look-up', () {
    Future<Map<String, dynamic>> sent(ProductQuery query) async {
      late Map<String, dynamic> body;
      final s = service(
        MockClient((request) async {
          expect(request.url.path, '/v1/product');
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return ok({'found': false});
        }),
      );
      await s.lookUpProduct(query: query, context: _context);
      return body;
    }

    test(
      'sends exactly one of the photo, the barcode or the QR text',
      () async {
        expect(
          (await sent(ProductPhotoQuery(Uint8List.fromList([1, 2]))))['image'],
          base64Encode([1, 2]),
        );
        final barcode = await sent(const ProductBarcodeQuery('3337875743563'));
        expect(barcode['barcode'], '3337875743563');
        expect(barcode.containsKey('image'), isFalse);
        expect(
          (await sent(const ProductQrQuery('https://x.example')))['qr'],
          'https://x.example',
        );
      },
    );

    test('a found product comes back with its title and text', () async {
      final s = service(
        MockClient(
          (_) async => ok({
            'found': true,
            'title': 'CeraVe Foaming Cleanser',
            'insight': '**What it is**\n- A gel wash.',
            'webChecked': false,
          }),
        ),
      );
      final insight = (await s.lookUpProduct(
        query: const ProductBarcodeQuery('3337875743563'),
        context: _context,
      )).valueOrNull!;
      expect(insight.found, isTrue);
      expect(insight.title, 'CeraVe Foaming Cleanser');
      expect(insight.text, '**What it is**\n- A gel wash.');
      expect(insight.webChecked, isFalse);
    });

    test('not found is an answer, not a failure', () async {
      final s = service(MockClient((_) async => ok({'found': false})));
      final insight = (await s.lookUpProduct(
        query: const ProductQrQuery('hello'),
        context: _context,
      )).valueOrNull!;
      expect(insight.found, isFalse);
    });
  });
}
