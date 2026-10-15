# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** Phase 2 DONE. Onboarding/auth UI DONE: 01 Welcome, 02 Sign up, 03 Verify code, 04 Privacy consent,
  05 Skin quiz (concerns step) — all with tests, Figma-checked in Chrome. Auth runs on `FakeAuthRepository` (code `123456`).
  Phase 3 (stores/Codemagic) + GitHub remote need the user; backend choice is the owner's (docs/adr/0001-backend.md).
- **Next exact step:** 06 Selfie capture (Figma 3:2) + 07 Analysis results (3:97): `CameraService` + `PermissionService`
  interfaces with fakes for Chrome, rationale sheet before camera permission (store-compliance §1), on-device
  `SkinAnalyzer` interface (model ADR later). Then 08 Routine (3:185), 09 Home (3:292), 10–14. Each screen: read
  docs/design.md + store-compliance.md, Figma `get_design_context` first, tests first, verify in Chrome.
- **Branch / last commit:** main / see `git log` (everything committed)
- **Tests:** 494 passing · **Analyze:** 0 issues · Flutter 3.47.7 / Dart 3.13.5

## Decisions made
- Bundle ID `com.saafapp.saaf`. Unified Material 3 styled like Figma; Figma wins (design.md §0).
- Fonts: Nunito + Noto Naskh Arabic OFL variable fonts, declared per weight. Material icons stand in for Figma's SVG icons.
- Packages: flutter_riverpod 3 + riverpod_generator 4, go_router 18, drift, flutter_secure_storage, permission_handler,
  freezed 4, mocktail; `intl: any`. `*.g.dart`/`*.freezed.dart` are gitignored → run
  `dart run build_runner build --delete-conflicting-outputs` after a fresh clone. l10n output IS committed.
- Consent boxes start unticked (mockup shows ticked); 04 title is 32/42 (design.md corrected). 01 stat is labelled "Example".
- Auth: `PhoneNumber` (+92 3XX XXXXXXX, table-tested), `RequestOtp`/`VerifyOtp`/`SocialSignIn` use cases, `PendingSignIn`
  provider carries the number to Verify; "Continue with Apple" only on iOS (§9.3). Google button uses a plain "G" like
  Figma — swap for the official logo when real Google sign-in lands.
- Repos for consent/skin profile are in-memory until drift (Phase 7); language choice is in-memory (no persistence).
- Verify code: boxes + keypad as in Figma; a transparent TextField (NOT `Opacity(0)`, which hides it from screen readers)
  gives system keyboard, `oneTimeCode` autofill and paste. Android SMS Retriever still to add (native, verify via Codemagic).
- `SaafScaffold` pins CTA via min-height + spaceBetween (no intrinsics). 48 dp hit areas taken out of padding where Figma
  is 40 dp (top bar) or accepted as +layout (check rows).
- Urdu strings are my translations — need native review before release.

## Testing notes
- Widget tests use the Ahem font (16 dp/glyph): keep labels short, `ensureVisible` before tapping low widgets, never
  `pumpAndSettle` with a spinner, reset `debugDefaultTargetPlatformOverride` inside the test body. Helpers in
  `test/helpers/pump_app.dart` (`pumpSaaf`, `pumpSaafApp`, `expectRobustLayout`, `expectTapTargetsAccessible`).
- Browser check: `flutter run -d web-server --web-port 8099`, reload the page, wait ~40 s (dev compile); if the first
  render looks cropped/zoomed, reload again.

## Native files edited (only verifiable via Codemagic)
- none by hand.

## Open problems / questions for the user
- Backend decision: read docs/adr/0001-backend.md (recommends Supabase; SMS delivery to Pakistan is the real go/no-go).
- Quiz: what are steps 1, 3, 4, 5? (Figma shows only step 2, "STEP 2 OF 5".)
- Terms/Privacy pages are placeholders; real documents + public URLs are required before store submission.
- GitHub remote not created (`git remote add origin <url>`; `git push -u origin main`). Phase 3 accounts are the user's.
- The promises on 04 are contractual: later code must make them true (on-device analysis, delete account, no sharing).

## Log
- 2026-10-16: Phase 1, 2.x, fonts, screens 01–05 (+legal pages), auth domain/fake, ADR 0001 draft. 494 tests green.
