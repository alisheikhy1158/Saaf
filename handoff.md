# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** all 14 Figma screens + phone-test feedback round done. Android test builds work on Codemagic (workflow
  "Android test app", needs Mac minutes; see Native notes). GitHub: https://github.com/alisheikhy1158/Saaf (main).
- **Waiting on the owner:** push + rebuild "Android test app", test on the Android 15 phone (checklist below); AI coach needs the
  server (docs/ai-coach.md: Groq key + Cloudflare, then `AI_PROXY_URL` + `USE_FIREBASE=true` in Codemagic `app_config`).
- **Tests:** 1508 Flutter + 32 backend (`cd backend/ai-proxy; node --test`) · **Analyze:** 0 issues · Flutter 3.47.7
- **NOT pushed yet:** 5 local commits (profile edit, tissue test, scan checks, products, AI coach). Push triggers a CI run.

## Phone-test checklist (new, unverified on a device)
1. Scan: face/light/angle chips and hints react; shutter locked until green; side photos need ~20–55° turn. **If "turn left" is
   mirrored, flip `_yawSign` in `domain/usecases/analyse_frame.dart`** (and `mirrored` in `mlkit_capture_quality_monitor.dart` for iOS).
   Bad photos (also from gallery) show a warning with "Use it anyway". 2. Scan a product (Home icon): real barcode -> Open Beauty
   Facts; typed number works without camera. 3. Profile: edit one answer; name/age sheet; AI sharing row. 4. Tissue test on quiz step 1.
5. Reminders sheet + notifications. 6. AI coach is a labelled DEMO until the server is deployed.

## Decisions made
- Bundle ID `com.saafapp.saaf`. Material 3 like Figma (design.md §0). Backend: **Firebase** (project `saaf-01`, see memory file).
- **Safety flags (health data) NEVER leave the phone** — not even to the AI (`AiContext` has no such field; tested).
- Face scan = 3 photos; checks use ML Kit on-device (`google_mlkit_face_detection`); fakes in Chrome/tests (`FAKE_CAMERA=true`).
  Pure rules: `analyse_frame.dart` (`FrameQualityAnalyzer`, `checkPhoto`). Shutter locks only when `CaptureQuality.assessed`.
- Weekly check-in (11) is rule-based. The **AI coach** (`/ai-coach`) is separate: explicit consent (Groq named), report button,
  server-side prompt in `backend/ai-proxy/src/prompt.js`, models set in `wrangler.toml` (qwen3.8-27b is a *preview* model).
- Products: `RealProductCatalog` (22 named PK products, prices = guide from derma.pk/qeemat, Oct 2026; two "estimate"s) drives
  routines; `OpenBeautyFactsLookup` + `IngredientReader` read real ingredient lists. `SeedProductCatalog/Lookup` stay as test/demo data.
- Profile rows edit ONE quiz step (`/skin-quiz/N?edit=1`); `ProfileDetails` (name, age) kept on the phone; wiped on delete.
- Pro gate: 12 Monthly progress needs Pro. Delete account wipes drift + settings (name, age, AI consent). Router guard in `app_guard.dart`.
- **PLACEHOLDERS before release:** `DemoSkinAnalyzer` (estimates from quiz, never reads photos), `FakeSubscriptionRepository`,
  "How we score" text, Profile "Photo backup", demo AI when no server. Prices need re-checking; flags need dermatologist review;
  allergy-flagged users get no sunscreen (no fragrance-free one with a PK price yet).

## Testing notes
- Widget tests use Ahem (16 dp/glyph): `FittedBox(scaleDown)`/`Flexible`; fixed pumps (no `pumpAndSettle` with spinners).
  `pumpSaaf`/`pumpSaafApp` default fakes for notifications; params `permissions:`/`scheduler:` (duplicate overrides throw).
- Re-pumping `pumpSaafApp` in one test keeps the old ProviderScope: `pumpWidget(const SizedBox())` between.
- `overrideWithBuild` pins state; Riverpod 3 retries: `noAutoRetry`. Bash heredocs with quotes hang: use the Write tool for scripts.

## Native notes (only verifiable via Codemagic)
- Android: Kotlin 2.4.0 + AGP 8.11.1 + `permission_handler 12.0.1` (13.x needs API 37). INTERNET, CAMERA, POST_NOTIFICATIONS,
  RECEIVE_BOOT_COMPLETED, boot receivers, desugaring. Release signing = Codemagic keystore "saaf upload keystore".
- iOS: deployment target 15.5 (ML Kit), `PERMISSION_CAMERA/NOTIFICATIONS`, entitlements. iOS build not tried yet.
- `codemagic.yaml` on Mac M2 (free plan has no Linux). New var `AI_PROXY_URL`.

## Open problems / questions for the user
- Firebase: replace test phone number (it looked real); Play-signing SHA after first Play upload (Firebase + Google Cloud key);
  Apple/Play accounts; SMS delivery on PK networks; Blaze plan decision.
- Before release: lawyer review (new AI section 6 in Privacy Policy), native Urdu review (all Urdu is mine), dermatologist review,
  support email, public deletion page, Cloud Function for account deletion, drift on web (OFF-6), outbox/sync (OFF-2), RevenueCat.

## Log
- 2026-10-17: 5-step quiz, legal drafts, Firebase auth. 586 tests.
- 2026-10-19: screens 10–14 + delete account. 1132 tests. 2026-10-20: guard, drift, reminders. 1201 tests.
- 2026-10-16/17 (device): Codemagic + Firebase wired; Android build fixed 4x. Feedback round: profile edit, name/age, tissue test,
  real camera checks, real products + barcode scanner, AI coach + proxy. 1508 tests.
