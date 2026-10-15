# CLAUDE.md — Saaf (Master Router)

Saaf is a skincare-coach mobile app for South Asian skin (iOS + Android), built with Flutter.
The owner has **zero mobile experience**. Explain every command you ask him to run, one at a time.

## Tech stack (do not substitute)
- **Flutter** (stable channel) + **Dart** (null-safe, Dart 3 features: records, sealed classes, patterns)
- **Riverpod** (`flutter_riverpod` + `riverpod_annotation` / `riverpod_generator`) for ALL state
- `go_router` (navigation) · `drift` (local DB, offline-first) · `flutter_secure_storage` (tokens)
- `permission_handler` (permissions) · `purchases_flutter` / RevenueCat (subscriptions)
- Tests: `flutter_test`, `mocktail` · Lints: `flutter_lints` (strict mode, see architecture.md)
- CI/CD + store upload: **Codemagic** (`codemagic.yaml` at repo root)
- Add packages ONLY with `flutter pub add <pkg>` — never hand-type version numbers.

## Repo layout
```
Saaf/                     <- git repo root
├── CLAUDE.md  PLAN.md  handoff.md  codemagic.yaml
├── docs/  architecture.md  store-compliance.md  design.md
├── tests/test-strategy.md
└── myapp/                <- the Flutter project (all `flutter` commands run here)
```

## HARD RULES — never break these
1. **NEVER suggest running `xcodebuild`, `pod install`, or local Gradle commands, because the user does
   not have Xcode or Android Studio. All mobile builds happen via Codemagic.**
   This also bans: `./gradlew`, `gradle`, `flutter build ios|ipa|apk|appbundle`, `flutter run -d <phone/emulator>`,
   `open ios/Runner.xcworkspace`, and "open this in Android Studio/Xcode" instructions.
2. Local testing = **Flutter Web in Chrome** only: `flutter run -d chrome`.
3. Allowed local commands: `flutter pub get|add|remove`, `flutter analyze`, `flutter test`,
   `dart format .`, `dart run build_runner build --delete-conflicting-outputs`, `flutter run -d chrome`, `git`.
4. Native files (`ios/Runner/Info.plist`, `AndroidManifest.xml`, `build.gradle.kts`) may be EDITED as text,
   but changes there can only be verified by a Codemagic build. Say so whenever you touch them.
5. Never import `dart:io` in `lib/presentation` or `lib/domain` — it crashes on web.
   Use `defaultTargetPlatform` / `Theme.of(context).platform`, never `Platform.isIOS`.
6. No hardcoded colors, text styles or spacing in widgets (see `docs/design.md`).
   **The Figma prototype wins every design conflict** (design.md §0); store/legal additions follow design.md §9.
7. Tests first. Never edit a test to make failing code pass (see `tests/test-strategy.md`).
8. Never commit secrets (API keys, keystores, `.p8`, `.jks`, service-account JSON). They live in Codemagic.
9. Never invent package APIs. If unsure, say so and check pub.dev docs before writing code.
10. Never claim tests pass or code compiles unless you ran the command and saw the output.

## Progressive Disclosure — read before you write
Do NOT load every doc for every task. Load what the task needs:

| Before you…                                        | Read first                     |
|----------------------------------------------------|--------------------------------|
| create/move any file, add a provider or package    | `docs/architecture.md`         |
| write ANY UI code (screen, widget, theme)          | `docs/design.md` **and** `docs/store-compliance.md`, then Figma `get_design_context` for that screen's node (design.md §10) |
| touch permissions, login, accounts, payments, data, AI features | `docs/store-compliance.md` |
| write or change a feature                          | `tests/test-strategy.md`       |
| edit `codemagic.yaml` or native config             | `docs/architecture.md` §Build  |
| start a new session                                | `handoff.md`, then `PLAN.md`   |

Mandatory before writing UI code: read `docs/architecture.md` (structure) and
`docs/store-compliance.md` (App Store / Play rules) — no exceptions.

## Workflow for every feature
1. Read `handoff.md` → find the current PLAN.md step.
2. State in 3–5 bullets what you will build and which files you will touch. Wait for "go".
3. Write failing test(s) → run `flutter test` → show the failure.
4. Implement the smallest code that passes → `flutter analyze` (0 issues) → `flutter test` (all green).
5. Run the store-compliance checklist (store-compliance.md §0) for UI/data features.
6. Tell the user exactly what to look at in Chrome (`flutter run -d chrome`, press `r` to hot reload).
7. Update `handoff.md`. Suggest a commit message. Suggest `/clear` after a major step.

## Communication style
- The user is a Software Engineering student: use correct terms, but explain mobile-specific ones once.
- One command per code block, with what it does and what success looks like.
- If a request conflicts with a rule above, refuse that part, explain why, and offer the compliant way.
- Prefer small diffs. Never rewrite a whole file to change a few lines.

## Definition of Done
- [ ] Tests written first and passing · `flutter analyze` clean · `dart format` applied
- [ ] Works in Chrome at 360×640, 390×844, 768×1024 and 1280×800 (DevTools device toolbar)
- [ ] Light + dark mode checked · text scale 200% doesn't overflow · Urdu (RTL) doesn't break layout
- [ ] Matches the Figma node exactly (tokens, spacing, radii, copy) + design.md §9 additions
- [ ] Semantics labels on every interactive/meaningful element · hit areas ≥ 48×48 dp (visuals as in Figma)
- [ ] store-compliance checklist passed · `handoff.md` updated
