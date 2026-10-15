# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** Phase 2.1 — done (packages added). Phase 0 left: GitHub remote (user action)
- **Last thing done:** Flutter upgraded 3.41.1 → 3.47.7 (Dart 3.13.5) because riverpod_generator/drift_dev would not
  resolve on the old SDK (meta pin). Added runtime + dev packages; analyze 0 issues, test +1, build_runner runs.
- **Next exact step:** PLAN.md Phase 2.2 — strict `analysis_options.yaml` + folder skeleton (architecture.md §2).
  Also pending for the user: create private GitHub repo `saaf`, `git remote add origin <url>`; check `flutter run -d chrome`.
- **Branch / last commit:** main / 42903d0 "Phase 1" (2.1 changes uncommitted: pubspec.yaml, pubspec.lock, analysis_options.yaml)
- **Tests:** 1 passing (default counter smoke test) · **Analyze:** 0 issues

## Decisions made
- Bundle ID / Android package: `com.saafapp.saaf` (permanent after first store upload)
- Design: unified Material 3 styled exactly like Figma; Figma wins all design conflicts (design.md §0)
- Spacing: Figma scale replaces the 8-pt grid; Figma colours kept, high-contrast theme for OS contrast settings
- Repo folder: D:\Saaf · Flutter 3.47.7 / Dart 3.13.5 at D:\flutter_windows_3.41.1-stable\flutter (folder name is stale, SDK is upgraded)
- Packages (2.1): flutter_riverpod, riverpod_annotation, go_router, drift, drift_flutter, flutter_secure_storage,
  permission_handler, freezed_annotation, json_annotation, intl (`any`, pinned by flutter_localizations), flutter_localizations;
  dev: riverpod_generator, build_runner, drift_dev, freezed, json_serializable, mocktail. riverpod_lint/custom_lint skipped.
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
- 2026-10-16: Phase 2.1 — flutter upgrade to 3.47.7, packages added, analyze/test/build_runner green.
- 2026-10-16: Phase 1 — git init, Flutter project created (com.saafapp.saaf), codemagic IDs updated, default test green.
