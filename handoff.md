# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Step:** feedback round 2 (2026-10-29) BUILT + security/policy/payments pass. GitHub: alisheikhy1158/Saaf (main).
- **Waiting on the owner:** rebuild "Android test app" for the professor demo; owner to-do list in the 2026-10-29 chat.
  **If the Android build fails, run `git revert c978bf1` (RevenueCat plugin) and rebuild** — payments are not needed for the demo.
- **Tests:** 1760 Flutter + 76 backend · **Analyze:** 0 issues · Flutter 3.47.7. Server: https://saaf-ai.saafai.workers.dev
  (`npx wrangler deploy` in backend/ai-proxy). Public pages: /privacy, /terms, /delete-account (set Worker var SUPPORT_EMAIL).

## Phone-test checklist (unverified on a device)
1. Demo order: sign in -> consent -> quiz -> products (+price) -> city -> scan (turn head slowly; each angle auto-captured,
   "Got it! Now turn…"; stops only if a check fails) -> turn on Saaf AI -> wait ~1 min -> Routine: options per step
   ("Compare and choose products"). "Saaf AI couldn't build your routine" -> wait a minute, Try again.
2. Side photos need ~20–55° turn (**mirrored? flip `_yawSign`** in `analyse_frame.dart`).
3. Home: tap an earlier day -> "What you did on …" (read-only), Back to today. Bell -> Reminders. No dark mode any more.
4. Google sign-in (Firebase needs the SHA-1/256 of "saaf upload keystore"); Apple shows on Android too (errors until set up).

## Decisions made
- Bundle ID `com.saafapp.saaf`. Backend: **Firebase** (`saaf-01`) + Cloudflare Worker (Groq models).
- **Safety flags NEVER leave the phone.** Skin numbers ONLY from Saaf AI reading the FRONT photo (consent).
- **No routine without an AI-analysed scan** (no catalogue fallback). Server returns 2–3 options per step, each with
  reviews + a source found by the search; user choices in `routineChoices`; plan cache key `v2`.
- Owned products may have a price: counted in routine total and budget, never swapped; sent to the AI.
- **Always light theme** (owner's call); camera screens dark by design (`SaafDarkScope`).
- Payments: store billing only (RevenueCat, `RC_GOOGLE_API_KEY`/`RC_APPLE_API_KEY`); without keys: fake (test app) /
  nothing for sale (release). Direct card/GPay/Apple Pay for Pro would break store policy.
- No cookie banner: no cookies in the app or on our pages. Refunds: Terms §7 (Apple/Google rules).
- Legal web pages generated from `legal_documents.dart` by `test/tool/legal_web_pages_test.dart`
  (`--dart-define=UPDATE_LEGAL_PAGES=true` to rewrite `backend/ai-proxy/src/legal_pages.js`, then deploy).

## Testing notes
- Widget tests use Ahem (16 dp/glyph); fixed pumps. `test/helpers/ai_routine.dart` gives tests a scan + AI plan.
- Re-pumping `pumpSaafApp` keeps the old ProviderScope: `pumpWidget(const SizedBox())` between. Riverpod 3: `noAutoRetry`.
- Bash heredocs mangle `\\`: write scripts with the Write tool.

## Native notes (only verifiable via Codemagic)
- Android: Kotlin 2.4.0 + AGP 8.11.1; purchases_flutter 11 (plugin classpath AGP 8.13.2). allowBackup=false +
  data_extraction_rules, cleartext off (`native_security_test`).
- iOS: target 15.5; Sign in with Apple entitlement; Firebase URL scheme; PrivacyInfo.xcprivacy (in pbxproj Resources);
  ITSAppUsesNonExemptEncryption=false. **iOS build never tried.**

## Open problems / questions for the user
- "busy" (Groq 8K TPM): logging deployed, cause not yet seen in a log. Options per step = more tokens; a Groq paid plan
  may be needed. Open-Meteo free tier is non-commercial.
- Before release: lawyer review (Terms §6–7, Privacy §2–3, §6 changed), native Urdu review, dermatologist review,
  SUPPORT_EMAIL, RevenueCat + store products, Apple Services ID, Play Health declaration + Data safety, App Privacy
  answers = PrivacyInfo.xcprivacy, account-deletion Cloud Function, backup/sync, crash reporting.

## Log
- Earlier: quiz, legal, auth, screens, Codemagic + Firebase, feedback round 1, AI routine/look-up, Phase 10.5 (1713).
- 2026-10-29: round 2 (history, AI options, prices, video scan, no dark), sign-in fixes, security, policies, RevenueCat (1760).
