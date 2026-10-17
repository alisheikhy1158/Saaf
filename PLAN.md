# PLAN.md — Saaf Beginner Roadmap

> How to use this file: work top to bottom. Each step says **what to run**, **what success looks like**, and ends with a
> ✅ checkbox. After every phase there is a **Document & Clear** block — do it, every time.
> Your machine: Windows, Chrome, VS Code. **No Xcode, no Android Studio, no emulators.**
> Mobile builds = Codemagic. Local testing = Chrome.

---

## 🔁 The "Document & Clear" ritual (after every phase)
1. Ask Claude: **"Update handoff.md for the phase we just finished."** It must record: what was done, files changed,
   decisions made, native files edited, open problems, the exact next step.
2. Check `flutter analyze` and `flutter test` are green.
3. Commit: `git add -A` then `git commit -m "Phase N: <summary>"` then `git push`.
4. In Claude Code, run **`/clear`** to wipe the conversation (saves tokens; context lives in the files now).
5. Start the next session with: **"Read CLAUDE.md and handoff.md, then continue PLAN.md."**

---

## Phase 0 — Set up your PC (one time, ~1–2 hours)
- [ ] Install **Git for Windows**, **Google Chrome**, **VS Code** (+ "Flutter" and "Dart" extensions).
- [ ] Install the **Flutter SDK** (Windows, stable) from docs.flutter.dev → "Get started → Windows → Web" path.
      Extract to a path **without spaces**, e.g. `C:\dev\flutter`, and add `C:\dev\flutter\bin` to your PATH.
- [ ] Open a NEW terminal and run `flutter doctor`.
      ✔ Success = Flutter ✓ and Chrome ✓. It will complain about **Android toolchain** and **Visual Studio** — that is
      expected and fine; we don't use them. Do not install Android Studio to "fix" it.
- [ ] Create a **private GitHub repo** named `saaf`. In `D:\Saaf`:
      `git init` → `git branch -M main` → `git remote add origin <your repo URL>`.
- [ ] The repo lives in **`D:\Saaf`** (no spaces — good for Flutter on Windows). Run all git commands there and all
      `flutter` commands inside `D:\Saaf\myapp`.

### 📝 Document & Clear → handoff.md · commit "Phase 0: tooling" · `/clear`

---

## Phase 1 — Create the app and see it in Chrome
**Step 1.** In `D:\Saaf` run:
```
flutter create --org com.mycompany myapp
```
> ⚠️ Decide the IDs NOW — they become the permanent iOS Bundle ID / Android package (`com.mycompany.myapp`) and can
> never change after the first store upload. Better: your own reverse domain, e.g.
> `flutter create --org com.saafapp --project-name saaf --platforms=android,ios,web myapp`
> (`--platforms` skips the Windows/macOS/Linux folders we don't need). If you change them, also update
> `PACKAGE_NAME` and `bundle_identifier` in `codemagic.yaml`.

✔ Success = a `myapp/` folder with `lib/main.dart`, `android/`, `ios/`, `web/`, `pubspec.yaml`.

**Step 2.** Local development:
```
cd myapp
flutter run -d chrome
```
✔ Success = Chrome opens the Flutter counter demo. In the terminal: `r` = hot reload, `R` = hot restart, `q` = quit.
Press F12 → device toolbar (Ctrl+Shift+M) → choose iPhone 12 Pro (390×844) to match the Figma frames.

- [x] `flutter test` passes the default widget test.
- [x] Copy the root `.gitignore` additions: `*.jks`, `*.keystore`, `*.p8`, `key.properties`, `*.g.dart`, `*.freezed.dart`, `.env`.

### 📝 Document & Clear → handoff.md · commit "Phase 1: flutter project created" · `/clear`

---

## Phase 2 — Foundation (architecture + design system, no features yet)
Ask Claude, one step at a time (it must read architecture.md + design.md first):
- [x] 2.1 Add packages with `flutter pub add` (riverpod set, go_router, drift set, flutter_secure_storage,
      permission_handler, freezed set, intl, mocktail as dev) — Claude explains each.
- [x] 2.2 `analysis_options.yaml` strict rules; folder skeleton from architecture.md §2.
- [x] 2.3 Theme: `tokens.dart`, `SaafTokens` extension, light + dark `ThemeData`, Nunito + Noto Naskh fonts bundled.
      Tests first: tokens equal the Figma values (design.md §2–§4), high-contrast pairs ≥ 4.5:1, extension in all themes.
- [x] 2.4 `no_hardcoded_values_test.dart` + layer-import architecture tests.
- [x] 2.5 Localisation (English + Urdu ARB, RTL check), `go_router` with placeholder routes for the 14 screens.
- [x] 2.6 Common widgets (design.md §4): SaafScaffold, SaafAdaptiveNav, SaafButton, SaafIconButton, SaafCard,
      SaafChip, SaafTextField — each with widget + a11y tests. Build a hidden `/gallery` route to view them in Chrome.
✔ Success = gallery page matches the Figma components side by side (compare with Figma at 390 wide), in light & dark,
  at 360/768/1280 widths.

### 📝 Document & Clear → handoff.md · commit "Phase 2: foundation" · `/clear`

---

## Phase 3 — Cloud pipeline early ("walking skeleton" on real phones)
Do this BEFORE features, so native problems show up while the app is tiny.
- [ ] 3.1 Buy/activate **Apple Developer Program** and **Google Play Console** accounts (check current fees; Apple
      enrolment can take days).
- [ ] 3.2 App Store Connect: register Bundle ID, create the app record. Play Console: create the app.
- [ ] 3.3 Push repo to GitHub, connect Codemagic, follow the setup comments at the top of `codemagic.yaml` (A–E).
- [ ] 3.4 Android signing in `myapp/android/app/build.gradle.kts` (text edit, verified only by Codemagic):
```kotlin
android {
    signingConfigs {
        create("release") {
            if (System.getenv("CI") != null) {           // true on Codemagic
                storeFile = file(System.getenv("CM_KEYSTORE_PATH"))
                storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("CM_KEY_ALIAS")
                keyPassword = System.getenv("CM_KEY_PASSWORD")
            }
        }
    }
    buildTypes {
        release {
            signingConfig = if (System.getenv("CI") != null)
                signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}
```
- [ ] 3.5 Push → `ci-tests` green. Then `git tag v0.0.1` → `git push origin v0.0.1` → both release workflows run.
- [ ] 3.6 First Android build: download the `.aab` from Codemagic Artifacts and upload it **manually once** to
      Play Console → Testing → Internal testing. Add yourself as tester, install from the Play link.
- [ ] 3.7 iOS: install **TestFlight** on your iPhone (or borrow one), accept the invite, install the build.
✔ Success = the skeleton app runs on a real Android phone and a real iPhone. 🎉

### 📝 Document & Clear → handoff.md (record IDs, workflow names, first build numbers) · commit · `/clear`

---

## Phase 4 — Backend decision, auth & account deletion
- [ ] 4.1 ADR `docs/adr/0001-backend.md` (Firebase vs Supabase) — you decide, Claude lists trade-offs.
- [ ] 4.2 Screens 02 Sign up + 03 Verify code (TDD), phone OTP, Google sign-in, **Sign in with Apple on iOS**.
- [ ] 4.3 Tokens in `flutter_secure_storage` via `SecureStore`; logout wipes everything.
- [ ] 4.4 **Delete account** flow (store-compliance A-1) + public web page for deletion requests.
- [ ] 4.5 Test account for App Review (fixed OTP).
✔ Success = sign up, log out, log in, delete account all work on TestFlight/internal builds.

### 📝 Document & Clear · commit · `/clear`

---

## Phase 5 — Onboarding (01 Welcome, 04 Privacy consent, 05 Skin quiz)
- [x] Tests first for each screen (states, a11y guidelines, responsive matrix, RTL). 01, 04, 05 done (quiz: concerns step only).
- [~] Language switch English/Urdu works (in memory; persistence needs the local DB). Consent stored with timestamp + policy
      version (in-memory repository until drift).
- [ ] Router guard: no app access until consent + quiz done (needs sign-up/auth state from Phase 4).

### 📝 Document & Clear · commit · `/clear`

---

## Phase 6 — Face scan & results (06, 07)
- [ ] `CameraService` + `PermissionService` interfaces; fakes for Chrome; rationale sheet before camera permission.
- [ ] On-device `SkinAnalyzer` (decide model in an ADR); photos saved privately (PRV-1, PRV-2).
- [ ] Results screen with disclaimer + "How we score" page. Verify camera on real phones via a tagged build.

### 📝 Document & Clear · commit · `/clear`

---

## Phase 7 — Daily use (08 Routine, 09 Home) + offline-first
- [ ] drift tables, outbox sync, streams to UI. Works in airplane mode.
- [ ] Reminders: notification permission with rationale, inexact scheduled notifications.

### 📝 Document & Clear · commit · `/clear`

---

## Phase 8 — Products, coach, progress (10, 11, 12)
- [ ] Barcode scan → product match, ingredient clash rules (pure domain, heavily unit-tested), external Buy links.
- [ ] Weekly check-in; if AI-generated: report button + data-sharing consent (store-compliance §5).
- [ ] Monthly before/after slider.

### 📝 Document & Clear · commit · `/clear`

---

## Phase 9 — Money: Saaf Pro (13) with RevenueCat
- [ ] Create subscription products in App Store Connect (+ agreements, tax, banking) and Play Console.
- [ ] RevenueCat project: entitlement `pro`, offering `default`, keys into Codemagic `app_config` group.
- [ ] Paywall per store-compliance §4 checklist (store prices, Restore, Terms, Privacy, platform-aware text).
- [ ] Test purchases with Apple sandbox/TestFlight and Play license testers.

### 📝 Document & Clear · commit · `/clear`

---

## Phase 10 — Profile (14) & hardening
- [ ] Settings rows, theme override, language, reminders, photo backup toggle.
- [ ] Full pass: dark mode, 200 % text, Urdu RTL, 320×480 → 1280×800, foldable hinge, iPad split view.
- [ ] Performance pass (architecture §4.4), size check, crash-free on real devices.

### 📝 Document & Clear · commit · `/clear`

---

## Phase 10.5 — Best-in-class features (decided and BUILT 2026-10-18; phone test pending)
Goal: the app that knows Pakistani skin and Pakistani life best. Build in this order, one commit each, tests first.
Rules for all: safety answers never leave the phone; anything sent to an AI or a server is shown and agreed first;
every AI answer is labelled and reportable; no AI prices; Urdu + RTL + 200 % text; no hardcoded colours/sizes.

1. **Skin weather (daily).** City picker (no GPS permission). Our server `/v1/weather` (signed in, cached 30 min
   per city) fetches Open-Meteo forecast (temperature, humidity, UV now + today's max) and air quality (US AQI,
   PM2.5). Pure rules on the phone turn it into 2–3 tips on Home ("UV 11 today: reapply at 1 pm", humid → gel
   moisturiser, smog → cleanse well tonight, heat → reapply after sweat). Attribution "Weather data by
   Open-Meteo.com" + CAMS. **Before launch:** Open-Meteo's free tier is non-commercial only → paid plan or
   another provider (swap on the server only).
2. **"Is this cream safe?"** Label photo / barcode → server `/v1/safety`: vision reads the ingredient list,
   browser search looks for regulator warnings (PSQCA, DRAP, FDA, others) about THIS product, strict JSON with
   cited links (only links found by the search). The phone adds fixed ingredient rules: mercury compounds,
   hydroquinone, strong steroids (clobetasol, betamethasone…), prescription retinoids; "no ingredients
   printed" = caution. Verdict: Danger / Be careful / No known problem (never "safe"), with reasons and sources.
3. **Progress you can trust.** On the front pose, a faint outline of the last scan's front photo to line up
   angle and distance (toggle). Light check already exists. Progress: "Share before & after" makes an animated
   GIF (first vs latest front photo, dated) and shares it only when the user taps.
4. **Product shelf.** "Products you use now" becomes the shelf: opened date, period after opening (6/12/24
   months), how long it lasts → "use by" and "runs out around"; Home reminds before it runs out or expires.
   "Find a cheaper alternative" → Saaf AI web search for similar products sold in Pakistan (no prices; "Check
   prices online").
5. **New-product introducer.** One new active at a time: patch test (24–48 h) → 2 nights a week → every other
   night → normal. Home card with today's step and "Any reaction today?" (No / Mild / Strong) — strong = stop and
   advice, possibly see a doctor. Kept on the phone.
6. **Life-event modes.** Ramadan mode (routine labelled "After sehri" / "After iftar", hydration tips). Event prep
   (wedding, mehndi…): date → countdown plan (no new actives in the last 4 weeks, nothing new in the last 2, gentle
   last week). Home card.
7. **Dermatologist bridge.** "Find a dermatologist" (Google Maps search in the user's city, opened in the
   browser) shown on warning signs and in Profile; "Share a report for your doctor": PDF of latest scan photo +
   AI estimate + routine + products, shared only on tap.
8. **Voice + Roman Urdu.** Microphone button in the AI coach (speech_to_text; Urdu or English by app language),
   own explanation before the mic/speech permission; Privacy Policy names Google/Apple speech services. Native
   permissions only verifiable on Codemagic.
9. **Body pigmentation.** New concern (underarms, knees, elbows, neck); body-care tips card; AI routine and coach
   know it; no bleaching ever.

Still open for launch (Phase 9–11): RevenueCat, cloud backup/sync, crash reporting, deletion web page, reviews.

### 📝 Document & Clear after each feature · commit · push

---

## Phase 11 — Store submission
- [ ] Privacy policy, Terms (EULA), support page, deletion page live on the web.
- [ ] App Privacy labels, `PrivacyInfo.xcprivacy`, Play Data safety, Health apps declaration, content ratings, target audience 16+/18+.
- [ ] Screenshots (iPhone, iPad if supported, Android phone + tablet), icon, descriptions in English (+ Urdu).
- [ ] **Google Play closed test: ≥ 12 testers opted in for 14 consecutive days** (required for new personal accounts),
      then apply for production.
- [ ] Apple: submit for review with demo account notes. Fix feedback, resubmit.
- [ ] Run store-compliance.md §7 checklist one last time against the **live** guidelines.

### 📝 Document & Clear · commit "v1.0.0" · `git tag v1.0.0` · `/clear`

---

## Phase 12 — After launch
- Weekly: check crashes, reviews, subscription metrics in RevenueCat.
- Every release: bump `version:` in pubspec (e.g. `1.1.0+1`; Codemagic sets the build number), tag `v1.1.0`.
- Yearly: Play target API level update; re-read both stores' guideline changes.
