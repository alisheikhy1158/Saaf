# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** Phase 2 — 2.1–2.6 DONE except fonts (2.3). Next: bundle fonts, then Phase 3 (needs the user).
- **Last thing done:** tokens + 4 themes, architecture tests, en/ur l10n, go_router (14 placeholder routes + debug-only
  `/gallery`), 7 common widgets (SaafScaffold, SaafAdaptiveNav, SaafButton, SaafIconButton, SaafCard, SaafChip, SaafTextField).
- **Next exact step:** (1) bundle Nunito + Noto Naskh Arabic in `myapp/assets/fonts/` and declare in pubspec (needs the
  user's OK to download); (2) Phase 3 is user-action heavy (Apple/Google accounts, Codemagic, GitHub remote);
  (3) otherwise continue Phase 5 UI (01 Welcome etc.) — each screen: Figma `get_design_context` first.
- **Branch / last commit:** main / f4a9106 "Phase 2.6" (all work committed except this file)
- **Tests:** 188 passing · **Analyze:** 0 issues · Flutter 3.47.7 / Dart 3.13.5

## Decisions made
- Bundle ID / Android package: `com.saafapp.saaf` (permanent after first store upload)
- Design: unified Material 3 styled exactly like Figma; Figma wins all design conflicts (design.md §0)
- Packages: flutter_riverpod 3 + riverpod_generator 4, go_router 18, drift 2.35, flutter_secure_storage 11,
  permission_handler 13, freezed 4, json_serializable, mocktail; `intl: any` (pinned by flutter_localizations).
- Generated `*.g.dart` are gitignored → run `dart run build_runner build --delete-conflicting-outputs` after a fresh clone
  (Codemagic already does). l10n output `lib/core/l10n/app_localizations*.dart` IS committed (excluded from analyze).
- `SaafTokens` field for text extras is `styles` (not `type`: clashes with ThemeExtension.type).
- Lints added: `always_use_package_imports` (layer scanner only sees package: imports).
- SaafAdaptiveNav puts the pill *below* the content (never covers it); NavigationRail on medium/expanded.
- Urdu strings in `app_ur.arb` are my translations — need a native-speaker review before release.

## Testing notes
- Widget tests render with the Ahem font (16 dp per glyph): keep test labels short. `pumpAndSettle` hangs if a spinner
  is on screen — pump fixed durations. `test/helpers/pump_app.dart` has `pumpSaaf`, `expectRobustLayout` (4 sizes, dark,
  200 % text, Urdu, high contrast) and `expectTapTargetsAccessible`.
- `test/architecture/*` guard: no hex/Colors/literal sizes or spacing in lib/presentation; layer + feature import rules.

## Native files edited (only verifiable via Codemagic)
- none by hand. `flutter create` generated android/ and ios/ with `com.saafapp.saaf`.

## Open problems / questions for the user
- Fonts: needs permission to download Nunito (Regular/Bold/ExtraBold) + Noto Naskh Arabic .ttf (OFL, Google Fonts repo).
- GitHub remote not created yet (`git remote add origin <url>` then `git push -u origin main`).
- Minor doc slips: codemagic.yaml step E says PLAN "Phase 6" (it's 3.4); architecture §6 says "PLAN Phase 3" for backend (it's 4).

## Log
- 2026-10-15: Context Pack generated; design.md rebuilt from Figma values.
- 2026-10-16: Phase 1 (project), 2.1 (packages, Flutter 3.47.7), 2.2–2.6 (foundation, widgets, gallery). 188 tests green.
