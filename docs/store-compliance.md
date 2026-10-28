# Store Compliance — Saaf (App Store & Google Play Guardrails)

> Read before writing ANY UI code, and before touching permissions, login, accounts, payments, user data or AI features.
> Store rules change. Before each release, re-check the live
> [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) and the
> [Google Play Developer Policy Center](https://play.google.com/about/developer-content-policy/).
> If a rule here conflicts with the live policy, the live policy wins — update this file.

---

## 0. Pre-feature checklist (run for EVERY feature)

- [ ] Does it request a permission? → §1 (rationale screen + Info.plist string + manifest entry)
- [ ] Does it collect, store or send new data? → §2 (privacy labels, Data safety form, privacy policy)
- [ ] Does it touch login or accounts? → §3 (account deletion, Sign in with Apple)
- [ ] Does it unlock paid features? → §4 (RevenueCat, paywall rules)
- [ ] Does it give skin/health guidance or use AI? → §5
- [ ] UI: 48×48 dp hit areas, no placeholder text, works on tablet & foldable → §6
- [ ] Visuals match the Figma screen; any addition below is styled with Figma tokens (design.md §0 and §9)
- [ ] Any text mentioning "Google Play" / "App Store" / prices is platform-aware → §4.3
- [ ] Copy is real and final (no lorem ipsum, "TODO", "Test", fake names in production builds)

---

## 1. Privacy & Permissions

**Rule P-1: Never request a permission without a clear, user-facing rationale, using `permission_handler`.**

Flow (implemented once in `PermissionService`, used everywhere):
1. Request **in context**, only when the user taps the feature that needs it (e.g. tapping "Start face scan"),
   never on app launch.
2. Check status first: `await Permission.camera.status`.
3. If not yet asked → show our **pre-permission rationale sheet** (`widgets/common/permission_rationale_sheet.dart`):
   icon, one-sentence reason, "Continue" and "Not now". Only "Continue" triggers `Permission.camera.request()`.
   Apple: the button that leads to the system prompt must say "Continue"/"Next" — not "Allow" (don't imitate the system dialog).
4. If `isDenied` → feature degrades gracefully, explain, allow retry later.
5. If `isPermanentlyDenied` (Android) / denied (iOS) → explain and offer `openAppSettings()`.
6. The app must remain usable when any permission is refused (Apple 5.1.1(iv)).

| Permission | Why Saaf needs it | iOS `Info.plist` key (purpose string) | Android |
|---|---|---|---|
| Camera | Face scan (06), product barcode scan (10) | `NSCameraUsageDescription` = "Saaf uses the camera to take your skin check photos and scan product barcodes. Photos stay on your phone." | `android.permission.CAMERA` |
| Photos (pick existing selfie) | Gallery button on 06 | Use the **system photo picker** (`image_picker` → PHPicker / Android Photo Picker), so no library permission is needed. Still add `NSPhotoLibraryUsageDescription` if a plugin requires the key. | **Do NOT declare `READ_MEDIA_IMAGES`/`READ_EXTERNAL_STORAGE`** — Play restricts these; the Photo Picker needs none. |
| Notifications | Routine reminders (8:00 · 22:30) | Requested via `permission_handler` at reminder setup | `POST_NOTIFICATIONS` (Android 13+) |
| Exact alarms | Avoid. Use inexact scheduled notifications. | — | Do NOT declare `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` |

- `permission_handler` on iOS: enable only the permissions we use via the `PERMISSION_*` macros in `ios/Podfile`
  (text edit; verified by Codemagic). Unused permission code can cause App Review rejections.
- Every permission declared in AndroidManifest must be used; remove any a plugin adds that we don't need
  (`tools:node="remove"`).

**Privacy declarations (must match real behaviour exactly):**
- Apple **App Privacy "nutrition labels"** in App Store Connect + **`PrivacyInfo.xcprivacy`** privacy manifest in
  `ios/Runner/` (required-reason APIs, e.g. `UserDefaults` via shared_preferences). Third-party SDKs must ship their own manifests.
- Google Play **Data safety form**: declare phone number, photos (processed on device → state whether collected),
  purchase history, app interactions, crash logs (if any).
- **Privacy policy URL** required by both stores, linked in-app (Sign up 02, Privacy consent 04, Profile 14, Paywall 13).
- Face data: the policy must say what face/skin data is collected, how it's used, that it's not shared with third parties,
  how long it's kept, and how to delete it. The 04 consent screen's promises ("stay on your phone", "never sold or shared",
  "delete anytime") are **contractual** — code must make them true.
- No tracking/advertising SDKs. If any SDK ever tracks across apps → App Tracking Transparency prompt required. Avoid.

## 2. Data handling
- Collect the minimum (architecture.md PRV-3). Every new field → update privacy labels + Data safety + privacy policy *before* release.
- Age: 04 has "I am 16 or older". Do not target children; set the Play target audience to 16+/18+ and answer the
  Apple age-rating questionnaire honestly. Do not add features that appeal mainly to kids (Play Families policy).

## 3. Accounts & sign-in

**Rule A-1: Any app with account creation MUST have an easily accessible account deletion option inside the app (Apple 5.1.1(v)).**
- Location: Profile (14) → PRIVACY → "Delete my account" (already in the mockups — keep it ≤ 2 taps from Profile).
- Flow: explain what is deleted → if the user has an active subscription, tell them deletion does NOT cancel billing
  and link to the store's subscription management → confirm (type "DELETE" or confirm dialog) → delete server account
  + all server data → wipe local data (SEC-7) → return to Welcome.
- Deletion must actually delete (not just deactivate). If some data must legally be kept, say so in the flow.
- Temporary deactivation alone is NOT compliant.
- Google Play also requires a **web link** where users can request deletion without the app; add it to the Play
  Data safety form (e.g. a simple page on the Saaf website).

**Rule A-2: Sign in with Apple.** The mockups offer "Continue with Google". Apple 4.8 requires that apps using a
third-party login also offer an equivalent privacy-focused login — use **Sign in with Apple** on iOS (equal prominence,
styled as `SaafButton.outline` per design.md §9.3). Phone OTP alone does not need it; adding Google does.
- Login must not be required for features that don't need an account (Apple 5.1.1). Decide which screens are usable before sign-up.
- App Review needs a demo login: provide a test phone number + fixed OTP in App Review notes (backend must support it).

## 4. In-App Purchases (Saaf Pro)

**Rule IAP-1: Use RevenueCat (`purchases_flutter`) for all cross-platform subscriptions.**
- Saaf Pro unlocks digital features → must use Apple IAP / Google Play Billing (Apple 3.1.1, Play Payments policy).
  No external links or "pay on our website" buttons for Pro.
- Physical products (the "Buy" buttons on 10 → Daraz, pharmacies) are real-world goods → external links allowed,
  IAP not required. Open them in the external browser; label affiliate links if any.
- Products are configured in App Store Connect + Play Console, then mapped in RevenueCat: entitlement `pro`,
  offering `default` with packages `$rc_annual` and `$rc_monthly`.
- Check access with `customerInfo.entitlements.active['pro']` — never with a local bool. Cache for offline but re-validate.
- Call `Purchases.logIn(userId)` after sign-in and `Purchases.logOut()` on sign-out/deletion.
- `purchases_flutter` does not run in our Chrome dev build → use `FakePurchasesService` on web/tests.

**Paywall (13) must have (Apple 3.1.2 / Play subscriptions policy):**
- [ ] Prices from the store via RevenueCat (`storeProduct.priceString`) — **never hardcode "Rs 3,999"/"Rs 599"**.
      Localized currency & per-month equivalents are computed from store data.
- [ ] Subscription name, duration, full billed amount most prominent; trial length and what happens after the trial
      ("Free for 7 days, then <price>/year") — trial terms come from the store's intro offer.
- [ ] **"Restore purchases"** button (Apple requirement) — not in the prototype; add per design.md §9.2.
- [ ] Links to **Terms of Use (EULA)** and **Privacy Policy** on the paywall — not in the prototype; add per design.md §9.2.
- [ ] Clear close (X) button; no fake urgency timers, no pre-selected hidden upsells.
- [ ] Cancellation text is **platform-aware**: "Cancel anytime in Google Play" on Android, "…in Settings › Apple ID ›
      Subscriptions" on iOS. The prototype shows the Android text only — switch via `defaultTargetPlatform`.
- [ ] "Save 44%" style badges must be computed from real store prices, not hardcoded.
- Never mention the other store or other platforms' prices in-app.

## 5. Skin analysis, health claims & AI
- Saaf is a **cosmetic** coach, not a medical device. Never use words like "diagnose", "treat", "cure", "acne treatment
  guaranteed". Keep the 07 disclaimer ("A cosmetic screening, not a medical diagnosis…") on every analysis result.
- Apple 1.4.1: health-related measurements must be accurate and their methodology disclosed ("How we score" link on 07
  must lead to a real explanation).
- Play: complete the **Health apps declaration** in Play Console.
- Marketing claims (e.g. Welcome 01 "Dark spots −32% in 8 weeks") must be real, substantiated data or clearly labelled
  as an example (design.md §9.5).
- Weekly check-in (11) coach: if replies are AI-generated —
  - Play AI-generated content policy: provide an in-app way to **report/flag** an offensive or harmful AI reply.
  - Apple 5.1.2(i): if personal data (messages, skin data, photos) is sent to a third-party AI provider, **disclose who
    and get explicit permission first**. Prefer on-device or our own backend without sharing identifiable data.
  - Add guardrails: no medical diagnoses; suggest a dermatologist for concerning symptoms.

## 6. UI/UX requirements
- **Dark Mode:** none, the owner's decision (2026-10-29). The app is always light; neither store requires a dark
  theme. Only the camera screens are dark by design (design.md §2.3).
- **Touch targets ≥ 48×48 dp** (Google/Material; Apple's minimum is 44×44 pt — 48 satisfies both). Keep the Figma
  visual sizes (40 dp icon buttons, 36 dp checkbox rows, 40 dp text button, 44 dp days, 22–26 dp checks) and expand the
  **hit area** invisibly to 48 dp (design.md §9.1).
- **No placeholder text** in any build sent to the stores: no "Lorem ipsum", "Ayesha Khan", "Rs 1,450", "+92 312 456 7890"
  hardcoded — mockup data is for design only; real screens use real data or proper empty states.
- Every screen has loading, empty, error and offline states. No dead buttons, no "Coming soon" screens (Apple 2.1, 2.2).
- App must be complete and stable for review: no crashes, all links work, demo account works (Apple 2.1).
- iPad: if the iOS build supports iPad, the app must look and work right on iPad (Apple 2.4.1) — see design.md §5.
  Support all orientations on iPad (multitasking). Android 16+ ignores orientation locks on large screens → design for it.
- Use the system share sheet; don't fake system UI (status bar, alerts).
- Localization: English and Urdu; store listing text matches the app's languages.

## 7. Store listing & release checklist
- [ ] Apple Developer Program (paid, yearly) and Google Play Console (one-time fee) accounts — check current fees.
- [ ] New **personal** Play developer accounts must run a **closed test with at least 12 testers for 14 days** before
      production access. Plan for it (PLAN Phase 7).
- [ ] Play: target the API level required at upload time (rises every year — check "Target API level requirements").
- [ ] App icon (no transparency on iOS), screenshots for 6.9"/6.5" iPhone, 13" iPad (if supported), Play phone/tablet.
- [ ] Privacy policy URL, support URL, account-deletion web URL, content rating questionnaires, Data safety, App Privacy.
- [ ] App Review notes: demo phone + OTP, explanation that photos are processed on device, how to reach the paywall.
- [ ] Export compliance: app uses only standard HTTPS encryption → `ITSAppUsesNonExemptEncryption = false` in Info.plist.
