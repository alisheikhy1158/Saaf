# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** Phase 2 DONE. Phase 5 onboarding screens 01 Welcome, 04 Privacy consent, 05 Skin quiz DONE (UI + tests).
  Phase 3 (stores/Codemagic) and the GitHub remote need the user. Phase 4 (auth) UI can be built against a fake.
- **Next exact step:** Phase 4.2 UI — Figma 02 Sign up (node 2:76) and 03 Verify code (2:140) against an `AuthRepository`
  interface + fake (fixed OTP) so they run in Chrome; write `docs/adr/0001-backend.md` with trade-offs (user decides).
  Then 06/07 scan (CameraService/PermissionService fakes), 08/09, 10–14. Each screen: Figma `get_design_context` first.
- **Branch / last commit:** main / 9665918 (all work committed except this file)
- **Tests:** 339 passing · **Analyze:** 0 issues · Flutter 3.47.7 / Dart 3.13.5

## Decisions made
- Bundle ID `com.saafapp.saaf` (permanent). Unified Material 3 styled like Figma; Figma wins (design.md §0).
- Fonts bundled: Nunito + Noto Naskh Arabic as OFL *variable* fonts (google/fonts has no static files), declared per weight.
- Packages: flutter_riverpod 3 + riverpod_generator 4, go_router 18, drift, flutter_secure_storage, permission_handler,
  freezed 4, mocktail; `intl: any`. Generated `*.g.dart`/`*.freezed.dart` are gitignored → run
  `dart run build_runner build --delete-conflicting-outputs` after a fresh clone. l10n output IS committed.
- design.md corrections found in Figma: 04 title is 32/42 (`SaafType.screenTitle`), not 34/44. Icons: Material icons stand
  in for Figma's Feather-style SVGs (theme-aware); decorative hero art/glow PNG bundled in `assets/images/`.
- Consent (04): boxes start UNticked, button disabled until both ticked (mockup shows ticked). 48 dp rows (layout +12 dp/row).
- 01 stat card says "Example: dark spots" (design.md §9.5). Language switch is in-memory (`LocaleController`), no persistence yet.
- 05: only the concerns step is designed ("STEP 2 OF 5"); step numbers are fixed to Figma. A 3rd pick replaces the earliest.
- Repos are in-memory placeholders (consent, skin profile) until drift (Phase 7). `SaafScaffold` pins the CTA via
  min-height + spaceBetween (no intrinsics → bodies can hold a LayoutBuilder).
- Urdu strings are my translations — need native review before release.

## Testing notes
- Widget tests use the Ahem font (16 dp/glyph): keep labels short, `ensureVisible` before tapping low widgets,
  never `pumpAndSettle` with a spinner on screen. Helpers: `pumpSaaf`, `pumpSaafApp`, `expectRobustLayout`,
  `expectTapTargetsAccessible` in `test/helpers/pump_app.dart`. `test/architecture/*` guard hardcoded values + layers.
- Browser check: `flutter run -d web-server --web-port 8099` then reload the page (hash navigation can show a stale, cropped render).

## Native files edited (only verifiable via Codemagic)
- none by hand.

## Open problems / questions for the user
- Quiz: what are steps 1, 3, 4, 5 (Figma shows only step 2)? Needed before the quiz is complete.
- Terms/Privacy pages are placeholders ("published before release"): real documents + public URLs required before store submission.
- GitHub remote not created (`git remote add origin <url>`; `git push -u origin main`). Phase 3 accounts are the user's.
- The promises on 04 are contractual: later code must make them true (on-device analysis, delete account, no sharing).

## Log
- 2026-10-16: Phase 1, 2.1–2.6, fonts, 01 Welcome, 04 Consent (+legal pages), 05 Quiz. 339 tests green.
