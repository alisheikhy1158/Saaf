# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** Onboarding + auth UI DONE: 01–05 (quiz is now 5 real steps), legal pages with researched drafts, Firebase
  auth coded behind `AuthRepository` (off until the owner configures Firebase). GitHub: https://github.com/alisheikhy1158/Saaf (main pushed).
- **Next exact step:** 06 Selfie capture (Figma 3:2) + 07 Analysis results (3:97): `CameraService` + `PermissionService`
  interfaces with fakes for Chrome, rationale sheet before the camera permission (store-compliance §1), on-device
  `SkinAnalyzer` interface. Then 08 Routine (3:185), 09 Home (3:292), 10–14. Each screen: read docs/design.md +
  store-compliance.md, Figma `get_design_context` first, tests first, verify in Chrome.
- **Tests:** 586 passing · **Analyze:** 0 issues · Flutter 3.47.7 / Dart 3.13.5

## Decisions made
- Bundle ID `com.saafapp.saaf`. Unified Material 3 styled like Figma; Figma wins (design.md §0). Backend: **Firebase** (ADR 0001 accepted).
- Quiz (researched, docs in git log): 1 skin type · 2 concerns (Figma 05) · 3 sensitivity · 4 safety (pregnant/breastfeeding,
  prescription treatment, ingredient allergy, none) · 5 monthly budget in PKR bands. Routes `/skin-quiz` (step 1), `/skin-quiz/:n`.
  `SaveQuizAnswers` merges each step into `SkinProfile`; `safetyFlags` null = unanswered, empty = "none of these".
- **Requirement for later sync code:** safety flags (health data) must NEVER be uploaded — the quiz copy and Privacy Policy promise it.
- Legal: `LegalDocuments` (English drafts, `core/legal/`), shown with a "Draft" chip until `LEGAL_REVIEWED=true`. Urdu pages show
  a note that the text is English only. Contact email / deletion URL come from `SUPPORT_EMAIL` / `DELETION_URL` dart-defines.
- Firebase: `FirebaseAuthRepository` (phone OTP, Google + Apple via `signInWithProvider`, Android auto-verification →
  `sessionChanges`). Settings via `--dart-define` (`Env`), lazy init, no config files committed. Default = fake backend.
  Google sign-in uses Firebase's provider flow (no google_sign_in package); swap to the native SDK later if UX needs it.
- Consent boxes start unticked; 01 stat labelled "Example"; fonts are OFL variable fonts; Material icons replace Figma SVG icons.
- In-memory repos (consent, skin profile, language) until drift (Phase 7). Urdu strings are mine — need native review.

## Testing notes
- Widget tests use the Ahem font (16 dp/glyph): short labels, `ensureVisible`, no `pumpAndSettle` with a spinner, reset
  `debugDefaultTargetPlatformOverride` in the test body. Helpers: `test/helpers/pump_app.dart`.
- Browser check: `flutter run -d web-server --web-port 8099`, reload, wait ~40 s; if the first render looks cropped, reload again.

## Native files edited (only verifiable via Codemagic)
- `ios/Runner.xcodeproj/project.pbxproj`: iOS deployment target 13 → 15 (Firebase), `CODE_SIGN_ENTITLEMENTS`.
- NEW `ios/Runner/Runner.entitlements` (Sign in with Apple), NEW `ios/Podfile` (stock Flutter template, platform 15.0).
- `codemagic.yaml`: Firebase/legal `--dart-define`s + a PlistBuddy step adding Firebase's URL scheme.

## Open problems / questions for the user
- Do docs/firebase-setup.md (Firebase console, Apple capability, Codemagic variables). SMS delivery to Pakistani networks is the go/no-go.
- Phase 3: Apple Developer + Google Play + Codemagic accounts (owner said they will do it).
- Before release: lawyer review of Terms/Privacy (`LEGAL_REVIEWED`), support email, public deletion page, native Urdu review.
- Delete-account flow + Cloud Function (Phase 4.4) still to build; needs Blaze plan.

## Log
- 2026-10-16: screens 01–05, auth domain, ADR; GitHub pushed.
- 2026-10-17: 5-step quiz, legal drafts (researched), Firebase auth implementation + setup guide. 586 tests green.
