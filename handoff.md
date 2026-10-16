# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** ALL 14 Figma screens are built and tested (01–14) plus router, theme, l10n (English + Urdu), fakes for every
  plugin. GitHub: https://github.com/alisheikhy1158/Saaf (main). It is a complete, demo-able app on fakes; nothing is real-backend yet.
- **Next exact step (needs the owner):** Firebase console setup (docs/firebase-setup.md), Apple/Google/Codemagic accounts, then a
  Codemagic build to test the camera, permissions and share on real phones. Engineering next: Phase 7 (drift persistence +
  notifications), Phase 8 (barcode scanner + real product/price service), Phase 9 (RevenueCat), real analyser.
- **Tests:** 1144 passing · **Analyze:** 0 issues · Flutter 3.47.7 / Dart 3.13.5

## Decisions made
- Bundle ID `com.saafapp.saaf`. Unified Material 3 styled like Figma; Figma wins (design.md §0). Backend: **Firebase** (ADR 0001).
- **Safety flags (health data) must NEVER be uploaded** — the quiz copy and Privacy Policy promise it.
- Face scan = 3 photos (front, left cheek, right cheek); permission rationale before the system dialog; gallery works without the camera.
  `--dart-define=FAKE_CAMERA=true` (pretend camera/gallery/share/links) and `FAKE_PURCHASES=true` (free "Pro") are for Chrome demos only;
  debug builds use the fake store, release builds get a store that sells nothing, so fake Pro can never ship.
- Coach (11) is rule-based, NOT AI (so no third-party data-sharing consent). Typed replies are kept as notes, never analysed.
- Pro gate: 12 Monthly progress needs Pro (`ProStatus`); 11 check-in is reached from 12. Paywall prices come from the store (fake for now).
- Delete account: `DeleteAccount` (account first, then photos best-effort) + `AccountController` wipes on-device data. Log out in Profile.
- **PLACEHOLDERS to replace before release:** `DemoSkinAnalyzer` (estimates from quiz answers, never reads the photos),
  `FakeCaptureQualityMonitor` (pretend light/centred/steady hints + 2 s auto-capture), `SeedProductCatalog` + `SeedProductLookup`
  (generic products, made-up prices/stores; ingredient flags need dermatologist review), `FakeSubscriptionRepository`, "How we score" text,
  `ReminderSettings` (times saved, but NO notifications are scheduled yet), Profile "Photo backup" (always off).
- Router guard (`core/router/app_guard.dart`): signed in -> consent -> quiz before the app opens; off in tests unless `guard:` is passed. `ConsentStatus`/`QuizDone` live in `onboarding_status.dart` (quiz-done is in memory, so persist it with drift).
- In-memory repos (consent, skin profile, scan history, routine log, check-ins, reminders, theme, language) until drift. Urdu = mine, needs native review.
- Profile "Skin profile"/"Monthly budget" reopen the quiz; the quiz ends on the camera screen (could return to Profile instead).

## Testing notes
- Widget tests use the Ahem font (16 dp/glyph): wide texts need `FittedBox(scaleDown)`/`Flexible`; reset `debugDefaultTargetPlatformOverride`
  in the test body; use fixed pumps (no `pumpAndSettle` with spinners). Helpers: `test/helpers/pump_app.dart` (`expectRobustLayoutSettled`).
- `overrideWithBuild` pins a notifier even after `invalidate` (so wipe tests set state by hand). Riverpod 3 retries failures: `noAutoRetry`.
- Browser check: `flutter run -d web-server --web-port 8100 --release --dart-define=FAKE_CAMERA=true --dart-define=FAKE_PURCHASES=true`;
  reload with a changed query string (`?v=2`); debug/DDC mode hung in the pane. Bash heredocs with quotes hang: write scripts with the Write tool.

## Native files edited (only verifiable via Codemagic)
- iOS: deployment target 15, `Runner.entitlements`, `Podfile` (`PERMISSION_CAMERA=1`), `Info.plist` `NSCameraUsageDescription`.
- Android: `AndroidManifest.xml` CAMERA + optional camera features. `codemagic.yaml`: Firebase/legal `--dart-define`s.

## Open problems / questions for the user
- docs/firebase-setup.md; SMS delivery on Pakistani networks is go/no-go. Developer/Play/Codemagic accounts. Test camera on real phones.
- Before release: lawyer review of Terms/Privacy (`LEGAL_REVIEWED`), support email, public deletion page, native Urdu review,
  dermatologist review of the product rules, replace every PLACEHOLDER above, Cloud Function for account deletion.

## Log
- 2026-10-17: 5-step quiz, legal drafts, Firebase auth. 586 tests.
- 2026-10-18: screens 06–09 (scan, results, routine, home). 896 tests.
- 2026-10-19: screens 10–14 (product result, check-in, progress, paywall, profile + delete account). 1132 tests.
