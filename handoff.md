# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** Screens 01–09 BUILT (welcome, auth, consent, quiz, 3-pose face scan, results + "How we score", routine, home).
  GitHub: https://github.com/alisheikhy1158/Saaf (main). Firebase auth is coded but off until the owner configures it.
- **Next exact step:** 10 Product scan result (Figma 3:446), 11 Weekly check-in (3:537), 12 Monthly progress (3:613),
  13 Saaf Pro paywall (3:712), 14 Profile & privacy (3:801). Each screen: read docs/design.md + store-compliance.md, Figma
  `get_design_context` (load the figma-design-to-code skill first), tests first, verify in Chrome. Tab screens (12, 14) wrap
  themselves in `SaafMainNav`.
- **Tests:** 896 passing · **Analyze:** 0 issues · Flutter 3.47.7 / Dart 3.13.5

## Decisions made
- Bundle ID `com.saafapp.saaf`. Unified Material 3 styled like Figma; Figma wins (design.md §0). Backend: **Firebase** (ADR 0001).
- Quiz: 1 skin type · 2 concerns · 3 sensitivity · 4 safety flags · 5 monthly budget (PKR bands). `SkinProfile` (null = unanswered).
- **Safety flags (health data) must NEVER be uploaded** — the quiz copy and Privacy Policy promise it.
- Face scan: 3 photos (front, left cheek, right cheek) in `ScanController`; permission rationale panel before the system dialog;
  gallery works without the camera; photos in private storage (`FilePhotoStore`, in memory on web). Always-dark screen (`SaafDarkScope`).
  `--dart-define=FAKE_CAMERA=true` = pretend camera/permission/gallery/share (for Chrome demos).
- **PLACEHOLDERS to replace before release:** `DemoSkinAnalyzer` (estimates the 4 bars from quiz answers, never looks at the photos),
  `FakeCaptureQualityMonitor` (the "Good light / Centred / Hold still" hints and the 2 s auto-capture are pretend), `SeedProductCatalog`
  (generic products, ballpark PKR prices, simplified ingredient flags — dermatologist review needed), "How we score" text.
- Routine: `BuildRoutine` (pure domain) picks products by skin type/concerns, filters by safety flags, fits the PKR budget
  (swaps to cheaper products, drops treatments last). Home checklist keys = `morning:<productId>` / `night:<productId>`.
- Routes: `/how-we-score` (extra), results opens the routine with `push`. Bell icon → profile (reminders will live there).
- In-memory repos (consent, skin profile, routine log, language) until drift (Phase 7). Urdu strings are mine — need native review.

## Testing notes
- Widget tests use the Ahem font (16 dp/glyph): short labels, `ensureVisible`, fixed pumps instead of `pumpAndSettle` with a spinner,
  reset `debugDefaultTargetPlatformOverride` in the test body. Helpers: `test/helpers/pump_app.dart` (`expectRobustLayoutSettled` for async screens).
- Riverpod 3 retries failed providers: screens that show an error use `@Riverpod(retry: ...)` returning null.
- Browser check: `flutter run -d web-server --web-port 8100 --release --dart-define=FAKE_CAMERA=true` (debug/DDC mode hung in the pane);
  reload with a changed query string (`?v=2`) — a hash-only navigation keeps the old app running.

## Native files edited (only verifiable via Codemagic)
- iOS: deployment target 15, `Runner.entitlements` (Sign in with Apple), `Podfile` (+ `PERMISSION_CAMERA=1`), `Info.plist` `NSCameraUsageDescription`.
- Android: `AndroidManifest.xml` CAMERA permission + optional camera features. `codemagic.yaml`: Firebase/legal `--dart-define`s.

## Open problems / questions for the user
- docs/firebase-setup.md (Firebase console, Apple capability, Codemagic variables); SMS delivery on Pakistani networks is go/no-go.
- Apple Developer + Google Play + Codemagic accounts. Test the camera on real phones via a Codemagic build.
- Before release: lawyer review of Terms/Privacy (`LEGAL_REVIEWED`), support email, deletion page, native Urdu review.
- Delete-account flow + Cloud Function (Phase 4.4) still to build; needs Blaze plan. Router guards (consent + quiz) not added yet.

## Log
- 2026-10-17: 5-step quiz, legal drafts, Firebase auth. 586 tests.
- 2026-10-18: screens 06 (3-pose scan), 07 (results), 08 (routine + planner), 09 (home + week strip + checklist). 896 tests.
