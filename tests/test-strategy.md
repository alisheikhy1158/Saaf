# Test Strategy — Saaf

> Purpose: tests are the contract that stops AI-generated code from "looking right" while being wrong.
> Flutter's test runner expects tests in `myapp/test/` — this document lives in `tests/` at the repo root.

## 0. THE RULE

> **I must write the test BEFORE implementing the feature, and I must not modify the test to make failing code pass.**

What this means in practice:
1. **Red:** write the test from the requirement (PLAN.md step, design.md screen spec, store-compliance rule).
   Run `flutter test <file>` and show the user the failing output. A test that passes before the code exists is a bad test.
2. **Green:** write the minimum code to pass. Run the tests again and show the passing output.
3. **Refactor:** clean up with tests still green. Run `flutter analyze` (0 issues).
4. A test may only be changed when **the requirement changed** and the user agreed. Then: say which requirement changed,
   update the test first, watch it fail, then change the code.
5. Forbidden: deleting failing tests, `skip: true`, loosening matchers (`equals(3)` → `isNotNull`), wrapping in try/catch,
   adding `// ignore:`, changing expected values to whatever the code returns, or mocking the unit under test.
6. Never report "tests pass" without running them in this session and quoting the summary line (e.g. `+42: All tests passed!`).

## 1. Anti-hallucination guardrails
- **Verify APIs before use.** If unsure a package method exists, say so; check the package's pub.dev API docs. The compiler
  (`flutter analyze`) is the judge — run it after every change.
- **Tests describe behaviour, not implementation.** Test what the user sees or what a use case returns, not private methods.
- **One behaviour per test**, named as a sentence: `'shows Restore purchases button on paywall'`.
- **Deterministic:** inject `Clock` and random seeds; no `DateTime.now()` in logic; no real network, timers, camera, store.
- **Requirement traceability:** each test file starts with a comment listing the requirement IDs it covers
  (e.g. `// Covers: A-1 account deletion, A11Y-5 touch targets`).

## 2. Test pyramid

| Layer | Tool | Location | What | Target share |
|---|---|---|---|---|
| Unit | `flutter_test` / `test`, `mocktail` | `test/domain/`, `test/data/`, `test/core/` | entities, use cases, repositories (with fake DB/API), validators, formatters, sync/outbox, Result mapping | ~70 % |
| Provider/controller | `ProviderContainer` + overrides | `test/presentation/**/controllers/` | Notifier state transitions: loading → data/error, offline paths | (part of unit) |
| Widget | `testWidgets`, `ProviderScope(overrides:)` | `test/presentation/` | screens & common widgets render, react to taps, show all states, semantics, layout at sizes | ~25 % |
| Integration (later) | `integration_test` | `integration_test/` | critical flows: onboarding → scan → routine; delete account; paywall purchase (fake) | ~5 % |

`test/` mirrors `lib/` exactly: `lib/domain/usecases/build_routine.dart` → `test/domain/usecases/build_routine_test.dart`.

## 3. Unit tests — rules
- Every use case: happy path + each `Failure` type + edge cases (empty lists, budget = 0, max values).
- Repositories: use drift's in-memory DB (`NativeDatabase.memory()`) for data-layer tests; fake API client with `mocktail`.
- Offline-first: test "write while offline → item in outbox → connectivity returns → synced → outbox empty".
- Security: test that logout/delete calls `SecureStore.deleteAll()`, clears DB and photo store (SEC-7).
- Money/price formatting, phone validation (+92), OTP validation: table-driven tests.

## 4. Widget tests — rules
Use a shared helper `test/helpers/pump_app.dart`:
```dart
Future<void> pumpSaaf(WidgetTester tester, Widget child, {
  List<Override> overrides = const [],
  Size size = const Size(390, 844),        // iPhone-class default
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async { /* sets view size, wraps in ProviderScope + MaterialApp with Saaf theme & l10n */ }
```

Every screen's widget test file MUST include:
1. **States:** loading, data, empty, error, offline.
2. **Interaction:** primary button enabled/disabled rules, navigation/callback fired.
3. **Accessibility guidelines** (built into `flutter_test`):
   ```dart
   final handle = tester.ensureSemantics();
   await expectLater(tester, meetsGuideline(androidTapTargetGuideline));   // 48x48
   await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));       // 44x44
   await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));   // every tap target labelled
   // Contrast: default theme intentionally matches Figma (some captions < 4.5:1, design.md §2.4).
   // Run the contrast guideline with the HIGH-CONTRAST theme (MediaQueryData(highContrast: true)):
   await expectLater(tester, meetsGuideline(textContrastGuideline));       // high-contrast pump only
   handle.dispose();
   ```
4. **Responsive matrix:** run the key assertions at `Size(320, 568)` (small/flip cover), `390×844` (phone),
   `768×1024` (iPad portrait), `1280×800` (tablet landscape / unfolded). Assert no overflow
   (`tester.takeException()` is null) and the right navigation (bottom bar vs rail).
5. **Dark mode + text scale 2.0 + Urdu (RTL)** render without exceptions.
6. **Compliance assertions** where relevant, e.g.:
   - Paywall shows "Restore purchases", Terms and Privacy links, price from `FakePurchasesService` (not a literal),
     and the Android vs iOS cancellation sentence.
   - Sign up shows "Continue with Apple" only when `debugDefaultTargetPlatformOverride = TargetPlatform.iOS`.
   - Visual sizes match Figma (e.g. icon button renders 40×40) while the hit area passes `androidTapTargetGuideline`.
   - Profile shows "Delete my account" reachable without scrolling past more than one section.
   - Camera button shows the rationale sheet before calling `PermissionService.request`.

## 5. Theme / design-system tests
- `test/core/theme/` asserts tokens: every spacing/radius/size token equals the Figma value in design.md §2–§4 (a token
  snapshot test — Figma is the source of truth); high-contrast themes meet 4.5:1 for text roles; `SaafTokens` exists in
  all four themes (light, dark, high-contrast light/dark).
- A custom lint-style test (`test/architecture/no_hardcoded_values_test.dart`) scans `lib/presentation/**.dart` and fails
  on `Color(0x`, `Colors.` (except `Colors.transparent`), `TextStyle(` with a literal `fontSize`, and
  `EdgeInsets.*(` with numeric literals. Hex codes are allowed ONLY in `lib/core/theme/tokens.dart`.
- Same idea for imports: fail if `lib/domain/**` imports `package:flutter` or `dart:io`, or a feature imports another feature.

## 6. Golden tests (optional, CI only)
Goldens render differently on Windows vs Linux. If we add them, generate and compare ONLY in the Codemagic `ci-tests`
workflow (Linux), tagged `@Tags(['golden'])`, and excluded locally with `flutter test --exclude-tags golden`.

## 7. Commands
```
flutter test                                  # all tests
flutter test test/presentation/features/paywall   # one folder
flutter test --coverage                       # writes coverage/lcov.info
flutter analyze                               # must be 0 issues
```
Coverage targets: domain ≥ 90 %, data ≥ 80 %, presentation controllers ≥ 80 %. Codemagic `ci-tests` runs analyze + tests
on every push; a red CI blocks release tags.

## 8. Manual check in Chrome (after tests are green)
`flutter run -d chrome` → open DevTools (F12) → device toolbar → check 360×640, 390×844, 768×1024, 1280×800,
light/dark (DevTools "Rendering → prefers-color-scheme"), and Urdu. Note: camera, permissions, purchases and secure storage
are faked on web — real behaviour is only verified on TestFlight / Play internal testing builds.
