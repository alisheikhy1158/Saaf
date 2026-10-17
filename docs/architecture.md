# Architecture — Saaf (Blueprint & NFRs)

> Read this before creating files, adding packages, or adding providers.
> Paths below are relative to `myapp/` (the Flutter project).

## 1. Principles

1. **Clean Architecture, three layers.** `presentation → domain ← data`. Dependencies point inward only.
2. **Domain is pure Dart.** No `package:flutter`, no `dart:io`, no plugin imports in `lib/domain`.
3. **Every platform plugin sits behind an interface** (repository or service) so the app runs in Chrome
   with a web/fake implementation, and in tests with a mock. This is what makes our "no emulator" workflow possible.
4. **Offline-first.** The local database is the source of truth for the UI. The network only syncs.
5. **Privacy by design.** Face photos never leave the device unless the user explicitly turns on backup.

## 2. Directory structure

```
myapp/
├── lib/
│   ├── main.dart                     # runApp(ProviderScope(child: SaafApp())) — nothing else
│   ├── app.dart                      # MaterialApp.router, theme, localization, router
│   ├── core/                         # cross-cutting, no feature logic
│   │   ├── config/                   # Env (--dart-define values), flavors, feature flags
│   │   ├── error/                    # Failure (sealed), exceptions, Result<T>
│   │   ├── l10n/                     # ARB files: app_en.arb, app_ur.arb (generated via flutter gen-l10n)
│   │   ├── platform/                 # PlatformInfo wrapper (web-safe), adaptive helpers
│   │   ├── router/                   # go_router config, route names, guards (auth, consent, paywall)
│   │   ├── theme/                    # tokens.dart (ONLY place hex codes live), saaf_theme.dart,
│   │   │                             # saaf_tokens_extension.dart, breakpoints.dart
│   │   └── utils/                    # pure helpers (formatters, validators)
│   ├── domain/
│   │   ├── entities/                 # immutable models: SkinProfile, Scan, RoutineStep, Product, Plan…
│   │   ├── repositories/             # abstract interfaces: AuthRepository, ScanRepository…
│   │   ├── services/                 # abstract: SkinAnalyzer, CameraService, PermissionService,
│   │   │                             #           PurchasesService, SecureStore, Clock
│   │   └── usecases/                 # one class per action: AnalyzeSkin, BuildRoutine, DeleteAccount…
│   ├── data/
│   │   ├── local/                    # drift database, tables, DAOs, photo file store
│   │   ├── remote/                   # API client, DTOs (json_serializable), interceptors
│   │   ├── repositories/             # implementations of domain/repositories (local-first + sync)
│   │   ├── services/                 # plugin adapters: permission_handler, camera, RevenueCat, ML
│   │   │   └── web/                  # web/fake adapters used by `flutter run -d chrome`
│   │   └── sync/                     # outbox queue, retry/backoff, connectivity listener
│   └── presentation/
│       ├── providers/                # app-wide providers (repository/service wiring)
│       ├── widgets/
│       │   └── common/               # SaafButton, SaafTextField, SaafCard, SaafChip, SaafScaffold…
│       └── features/
│           ├── onboarding/           # 01 Welcome, 04 Privacy consent, 05 Skin quiz
│           ├── auth/                 # 02 Sign up, 03 Verify code
│           ├── scan/                 # 06 Selfie capture, 07 Analysis results
│           ├── routine/              # 08 Routine
│           ├── home/                 # 09 Home
│           ├── products/             # 10 Product scan result
│           ├── coach/                # 11 Weekly check-in
│           ├── progress/             # 12 Monthly progress
│           ├── paywall/              # 13 Saaf Pro paywall
│           └── profile/              # 14 Profile & privacy, Delete account flow
│               └── (each feature) screens/, widgets/, controllers/ (Notifiers), state/
├── test/                             # mirrors lib/ exactly (see tests/test-strategy.md)
├── assets/ fonts/ images/ ml/        # bundled fonts (no runtime font download), on-device model
└── analysis_options.yaml
```

**File rules**
- One public widget per file. File names `snake_case.dart`; classes `PascalCase`.
- A feature may import `domain/`, `presentation/widgets/common/`, `core/`. It must NOT import another feature's internals
  (share via `domain/` or `widgets/common/`).
- `data/` may import `domain/` and `core/`, never `presentation/`.
- Generated files (`*.g.dart`, `*.freezed.dart`) are NOT committed — they are in `.gitignore`. Regenerate them
  locally with `dart run build_runner build --delete-conflicting-outputs`; Codemagic runs the same command before building.

## 3. State management rules (Riverpod)

1. **Code generation style only** (`@riverpod` / `@Riverpod(keepAlive: true)`). Use `Notifier` / `AsyncNotifier`.
   Do NOT use `StateNotifier`, `ChangeNotifier`, `StateProvider`, `setState` for business state, or `provider` package.
   (`setState` is allowed only for purely visual, widget-local state such as an animation toggle.)
2. **Wiring providers** (repositories/services) are `keepAlive: true` and live in `presentation/providers/`.
   They return the *interface* type: `ScanRepository scanRepository(Ref ref) => ScanRepositoryImpl(...)`.
3. **Screen controllers** are auto-dispose `AsyncNotifier`s inside the feature's `controllers/`.
   They call use cases, never `data/` classes directly.
4. **State is immutable.** Use `freezed` (or sealed classes + `copyWith`) for state objects.
5. Async UI always handles all three states: `asyncValue.when(data:, loading:, error:)`. No `!` on `.value`.
6. `ref.watch` in `build`, `ref.read` in callbacks, `ref.listen` for side effects (snackbars, navigation).
   Never `ref.read` inside `build`.
7. Use `select` to avoid rebuilding big widgets: `ref.watch(p.select((s) => s.score))`.
8. **Testability:** every test builds a `ProviderContainer` (or `ProviderScope`) with `overrides:` that replace
   repositories/services with fakes. No test may hit the real network, camera, or store.
9. Platform switching happens in ONE place — the wiring provider:
   ```dart
   @Riverpod(keepAlive: true)
   CameraService cameraService(Ref ref) =>
       kIsWeb ? WebCameraService() : PluginCameraService();
   ```
10. Errors: repositories return `Result<T, Failure>` (sealed `Failure`: `NetworkFailure`, `PermissionDenied`,
    `StorageFailure`, `PurchaseCancelled`, `Unknown`). UI maps failures to friendly, localized text.

## 4. Non-Functional Requirements (strict)

### 4.1 Security
| ID | Requirement |
|----|-------------|
| SEC-1 | Auth/refresh tokens and the DB encryption key are stored ONLY via `flutter_secure_storage` (Keychain on iOS, Keystore-backed on Android), wrapped by `domain/services/secure_store.dart`. Never `shared_preferences`, never plain files, never logs. |
| SEC-2 | On web, `flutter_secure_storage` is NOT truly secure (browser storage). Web is a **dev-only** target; never ship web to users. |
| SEC-3 | No secrets in source. Public keys (RevenueCat SDK keys, API base URL) come from `--dart-define` set in Codemagic env vars, read via `core/config/env.dart`. |
| SEC-4 | HTTPS only. No `android:usesCleartextTraffic="true"`, no iOS ATS exceptions. |
| SEC-5 | Release builds use `--obfuscate --split-debug-info=build/symbols` (configured in `codemagic.yaml`). |
| SEC-6 | Logs never contain tokens, phone numbers, names, photos, or skin data. Use a `Logger` that strips PII in release. |
| SEC-7 | On logout/account deletion: wipe secure storage, DB, photo folder, RevenueCat user (`logOut`). |
| SEC-8 | Validate every input at the boundary (phone number format, OTP length, quiz answers). |

### 4.2 Privacy
| ID | Requirement |
|----|-------------|
| PRV-1 | Selfies are stored in the app's private documents folder only (never the public gallery) and are excluded from cloud backup unless "Photo backup" is ON. |
| PRV-2 | Photos stay on the phone unless the user agrees: the skin numbers come from Saaf AI reading the FRONT photo, sent only after Saaf AI is turned on AND the user says yes (once for automatic, or per scan); side photos are never sent. Sharing (e.g. the before-and-after GIF) happens only on the user's tap, through the system share sheet. Any new feature that sends a photo or skin data needs its own explicit consent first (see store-compliance.md, docs/ai-coach.md). |
| PRV-3 | Collect the minimum: phone number (auth), skin profile, budget, routine. No contacts, no location, no advertising ID. |
| PRV-4 | Analytics/crash reporting (if added) must be declared in privacy labels and have no PII. |

### 4.3 Offline-first
| ID | Requirement |
|----|-------------|
| OFF-1 | `drift` database is the single source of truth. Screens read via `Stream`s from DAOs. |
| OFF-2 | Writes go to the DB first, then into an **outbox** table; `data/sync/` pushes when online (exponential backoff, max 5 retries, idempotency key per item). |
| OFF-3 | Conflicts: last-write-wins by `updatedAt` (server timestamps) unless a feature spec says otherwise. |
| OFF-4 | Every screen must render meaningful content with no network: home, routine, progress, profile, past scans. Network-only features (product prices, OTP, purchases) show a clear offline state, never a spinner forever. |
| OFF-5 | Fonts, icons, ML model and illustrations are bundled — nothing required is downloaded at runtime. |
| OFF-6 | drift on web needs `sqlite3.wasm` + `drift_worker.js` in `web/` — follow drift's web setup docs exactly. |

### 4.4 Performance
| ID | Requirement |
|----|-------------|
| PERF-1 | Cold start to first frame < 2 s on a mid-range Android (~4 GB RAM); defer non-critical init (RevenueCat, sync) until after first frame. |
| PERF-2 | 60 fps scrolling: `ListView.builder`/`SliverList` for lists, `const` constructors everywhere possible, no work in `build`. |
| PERF-3 | Images: downscale selfies before analysis/storage (max 1080 px long edge, JPEG ~85%); use `cacheWidth`/`cacheHeight` for thumbnails. |
| PERF-4 | Heavy CPU work (image processing, ML pre-processing, JSON > 100 KB) runs in an isolate (`Isolate.run`) on mobile. |
| PERF-5 | Release AAB download size target < 30 MB; review `flutter build appbundle --analyze-size` output in Codemagic logs when size jumps. |
| PERF-6 | Network: 10 s connect timeout, 30 s receive; paginate lists > 50 items. |

### 4.5 Accessibility (WCAG 2.1 AA + platform guidelines)
| ID | Requirement |
|----|-------------|
| A11Y-1 | Every interactive element has a label: use `Semantics(label:, button: true)` or the widget's `tooltip`/`semanticLabel`. Icon-only buttons ALWAYS have `tooltip` + semantic label. |
| A11Y-2 | Decorative images/illustrations: `ExcludeSemantics` or `semanticLabel: null` with `excludeFromSemantics: true`. |
| A11Y-3 | Group related content: `MergeSemantics` for list rows (e.g. "Niacinamide Serum, Treatment, Rs 1,450, done"). |
| A11Y-4 | Live updates (scan countdown, OTP errors, score) announce via `SemanticsService.announce` or `Semantics(liveRegion: true)`. |
| A11Y-5 | Hit areas ≥ 48×48 dp while visuals stay as in Figma (design.md §9.1). Colours follow Figma; when the OS requests more contrast, the high-contrast theme (design.md §2.4) must meet ≥ 4.5:1 body text, ≥ 3:1 large text & UI components. |
| A11Y-6 | Support text scaling to 200% without clipping; never set fixed heights on text containers. |
| A11Y-7 | Never convey meaning by colour alone (e.g. score ring also shows the number; "Good match" chip has a ✓ icon + text). |
| A11Y-8 | Full RTL support for Urdu: `EdgeInsetsDirectional`, `AlignmentDirectional`, directional icons (`Icons.adaptive.arrow_back`). |
| A11Y-9 | Respect reduce-motion: check `MediaQuery.disableAnimationsOf(context)`. |

### 4.6 Reliability & quality
- `flutter analyze` must report **0 issues**. `analysis_options.yaml` enables `strict-casts`, `strict-inference`,
  `strict-raw-types` and lints: `prefer_const_constructors`, `avoid_print`, `always_declare_return_types`,
  `require_trailing_commas`, `unawaited_futures`.
- Coverage targets: domain ≥ 90 %, data ≥ 80 %, presentation controllers ≥ 80 %.
- Every async failure path has a test.

## 5. Build & release (cloud only)
- Local: `flutter run -d chrome`, `flutter test`, `flutter analyze`. Nothing else.
- Cloud: `codemagic.yaml` → workflows `ci-tests` (every push), `android-release` (.aab → Play internal track),
  `ios-release` (.ipa → TestFlight). Release workflows run on git tags `v*`.
- Version: `pubspec.yaml` `version: 1.0.0+1` — the build number (+N) is auto-incremented by Codemagic.
- Bundle/package ID: decided in PLAN step 1 and **never changes after the first store upload**.
- Native config edits (Info.plist keys, AndroidManifest permissions, signing config in `android/app/build.gradle.kts`)
  are text edits verified by a Codemagic build. Keep a note in `handoff.md` of every native edit.

## 6. Backend (to decide — PLAN Phase 3)
Needs: phone OTP auth, Google + Sign in with Apple, user profile sync, product/price catalogue, account deletion endpoint,
web page for deletion requests. Candidates: Firebase (Auth + Firestore + Functions) or Supabase.
Record the decision as an ADR in `docs/adr/0001-backend.md` before writing data-layer code.
