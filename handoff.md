# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** Phase 1 — done (project created, default test green). Phase 0 left: GitHub remote (user action)
- **Last thing done:** `git init` (branch main), `flutter create --org com.saafapp --project-name saaf` → `myapp/`,
  codemagic.yaml IDs updated, root `.gitignore` added, default `flutter test` passes (+1).
- **Next exact step:** (a) user creates private GitHub repo `saaf` + `git remote add origin <url>`; (b) user checks
  `flutter run -d chrome` shows the counter demo; (c) PLAN.md Phase 2.1 — add packages with `flutter pub add`.
- **Branch / last commit:** main / no commits yet
- **Tests:** 1 passing (default counter smoke test) · **Analyze:** not run yet

## Decisions made
- Bundle ID / Android package: `com.saafapp.saaf` (permanent after first store upload)
- Design: unified Material 3 styled exactly like Figma; Figma wins all design conflicts (design.md §0)
- Spacing: Figma scale replaces the 8-pt grid; Figma colours kept, high-contrast theme for OS contrast settings
- Repo folder: D:\Saaf · Flutter 3.41.1 / Dart 3.11.0 at D:\flutter_windows_3.41.1-stable\flutter
- Backend: undecided (Phase 4 ADR)

## Native files edited (only verifiable via Codemagic)
- none by hand. `flutter create` generated android/ and ios/ with applicationId / PRODUCT_BUNDLE_IDENTIFIER `com.saafapp.saaf`.

## Open problems / questions for the user
- `flutter create` warned the local Java/Gradle combo may conflict — irrelevant locally (builds run on Codemagic).
- Minor doc slips: codemagic.yaml step E says PLAN "Phase 6" (it's Phase 3.4); architecture §6 says "PLAN Phase 3" for backend (it's Phase 4).
- Build-time additions to the prototype are listed in design.md §9.

## Log
- 2026-10-15: Context Pack generated.
- 2026-10-15: design.md rebuilt from Figma values; Figma-first precedence; moved to D:\Saaf.
- 2026-10-16: Phase 1 — git init, Flutter project created (com.saafapp.saaf), codemagic IDs updated, default test green.
