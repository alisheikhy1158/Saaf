import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/data/services/firebase_id_token_provider.dart';
import 'package:saaf/data/services/http_ai_coach_service.dart';
import 'package:saaf/data/services/image_photo_shrinker.dart';
import 'package:saaf/data/services/plugin_ai_photo_picker.dart';
import 'package:saaf/data/services/web/fake_ai_coach_service.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/services/ai_photo_picker.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/services/ai_safety_service.dart';
import 'package:saaf/domain/services/ai_skin_service.dart';
import 'package:saaf/domain/services/auth_token_provider.dart';
import 'package:saaf/domain/services/photo_shrinker.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/ask_coach.dart';
import 'package:saaf/domain/usecases/check_cream_safety.dart';
import 'package:saaf/domain/usecases/estimate_skin.dart';
import 'package:saaf/domain/usecases/look_up_product.dart';
import 'package:saaf/domain/usecases/plan_routine.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

part 'ai_providers.g.dart';

/// True when this build should use a pretend AI coach: Chrome, `FAKE_CAMERA`
/// demos, debug builds and builds with the fake sign-in backend. A real store
/// build (Firebase on) never pretends: without the AI address it reports that
/// the coach is unavailable.
bool get _pretendAi =>
    kIsWeb || kDebugMode || Env.fakeCamera || !Env.useFirebase;

@Riverpod(keepAlive: true)
AuthTokenProvider idTokenSource(Ref ref) => _pretendAi
    ? const FakeAuthTokenProvider()
    : const FirebaseIdTokenProvider();

@Riverpod(keepAlive: true)
AiCoachService aiCoachService(Ref ref) => _pretendAi
    ? const FakeAiCoachService()
    : HttpAiCoachService(
        baseUrl: Env.aiProxyUrl,
        tokens: ref.watch(idTokenSourceProvider),
      );

/// Saaf AI's product help (a routine researched on the web, product look-ups);
/// pretend in the same builds as the coach.
@Riverpod(keepAlive: true)
AiProductService aiProductService(Ref ref) => _pretendAi
    ? const FakeAiProductService()
    : HttpAiCoachService(
        baseUrl: Env.aiProxyUrl,
        tokens: ref.watch(idTokenSourceProvider),
        // Web research takes much longer than a chat answer.
        timeout: const Duration(seconds: 150),
      );

/// Saaf AI's estimate from a front photo; pretend in the same builds as the
/// coach.
@Riverpod(keepAlive: true)
AiSkinService aiSkinService(Ref ref) => _pretendAi
    ? const FakeAiSkinService()
    : HttpAiCoachService(
        baseUrl: Env.aiProxyUrl,
        tokens: ref.watch(idTokenSourceProvider),
      );

/// Saaf AI's cream check; pretend in the same builds as the coach.
@Riverpod(keepAlive: true)
AiSafetyService aiSafetyService(Ref ref) => _pretendAi
    ? const FakeAiSafetyService()
    : HttpAiCoachService(
        baseUrl: Env.aiProxyUrl,
        tokens: ref.watch(idTokenSourceProvider),
        // Reading the label and a web search take a while.
        timeout: const Duration(seconds: 150),
      );

@Riverpod(keepAlive: true)
CheckCreamSafety checkCreamSafety(Ref ref) => CheckCreamSafety(
  service: ref.watch(aiSafetyServiceProvider),
  consent: ref.watch(aiConsentStoreProvider),
);

@Riverpod(keepAlive: true)
EstimateSkin estimateSkin(Ref ref) => EstimateSkin(
  service: ref.watch(aiSkinServiceProvider),
  consent: ref.watch(aiConsentStoreProvider),
);

@Riverpod(keepAlive: true)
PlanRoutine planRoutine(Ref ref) => PlanRoutine(
  service: ref.watch(aiProductServiceProvider),
  consent: ref.watch(aiConsentStoreProvider),
);

@Riverpod(keepAlive: true)
LookUpProduct lookUpProduct(Ref ref) => LookUpProduct(
  service: ref.watch(aiProductServiceProvider),
  consent: ref.watch(aiConsentStoreProvider),
);

@Riverpod(keepAlive: true)
AiPhotoPicker aiPhotoPicker(Ref ref) => (kIsWeb || Env.fakeCamera)
    ? const FakeAiPhotoPicker()
    : PluginAiPhotoPicker();

@Riverpod(keepAlive: true)
PhotoShrinker photoShrinker(Ref ref) => const ImagePhotoShrinker();

@Riverpod(keepAlive: true)
AiConsent aiConsentStore(Ref ref) =>
    AiConsent(ref.watch(settingsRepositoryProvider));

@Riverpod(keepAlive: true)
AskCoach askCoach(Ref ref) => AskCoach(
  service: ref.watch(aiCoachServiceProvider),
  consent: ref.watch(aiConsentStoreProvider),
);

/// Whether the user has agreed to share their questions and photos with the AI
/// coach: null while it is being read, then true or false.
@Riverpod(keepAlive: true)
class AiConsentState extends _$AiConsentState {
  bool _changed = false;

  @override
  bool? build() {
    ref.read(aiConsentStoreProvider).isGiven().then((given) {
      if (ref.mounted && !_changed) state = given;
    });
    return null;
  }

  Future<void> give() async {
    _changed = true;
    await ref.read(aiConsentStoreProvider).give();
    if (ref.mounted) state = true;
  }

  Future<void> withdraw() async {
    _changed = true;
    await ref.read(aiConsentStoreProvider).withdraw();
    if (ref.mounted) state = false;
  }
}
