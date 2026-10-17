# handoff.md — Session handoff (read this first after every `/clear`)

> Claude: keep this file under 60 lines. Overwrite "Current state"; append one line to "Log".

## Current state
- **Phase / step:** Phase 10.5 "best-in-class features" (PLAN.md) BUILT: skin weather, cream safety check, line-up outline +
  before/after GIF, product shelf + cheaper alternatives, new-product introducer, Ramadan mode, event prep, body care,
  dermatologist bridge (Maps + PDF report), voice input. GitHub: https://github.com/alisheikhy1158/Saaf (main).
- **Waiting on the owner:** rebuild "Android test app" (Codemagic), test on the Android 15 phone (checklist below).
- **Tests:** 1713 Flutter + 65 backend (`cd backend/ai-proxy; node --test`) · **Analyze:** 0 issues · Flutter 3.47.7.
  Server live: https://saaf-ai.saafai.workers.dev (deploy: `npx wrangler deploy` in backend/ai-proxy). docs/ai-coach.md.

## Phone-test checklist (unverified on a device)
1. Scan: chips/hints react; side photos need ~20–55° turn (**mirrored? flip `_yawSign`** in `analyse_frame.dart`). Screen at full
   brightness + light frame; faint outline of the last scan (**if not lined up, remove `Transform.flip` in `scan_viewfinder.dart`**).
2. Results: "Not analysed yet" -> asked once "Analyse every scan automatically?" -> numbers with "How sure". Progress: GIF share.
3. Quiz (6 concerns incl. body) -> "Products you use now" (kind) -> scan. Routine: your products "Yours", AI web picks (~1 min),
   keep/replace/stop, Body care card. Shelf: tap a product -> opened/keeps/lasts, cheaper alternative, introduce slowly.
4. Home cards: skin weather (choose city), shelf reminders, introducer check-in, event countdown, Ramadan tips, cream check.
5. Cream check (Home / scan screen): type a name or photo -> Danger / Be careful / No known problem + sources.
6. AI coach: answers tidy; mic button (explain -> mic permission -> text in box). Profile: life events, dermatologist, PDF report.
7. Scan product: QR, label photo look-up, unknown barcode -> Saaf AI. Test app shows "Technical detail" on AI errors.

## Decisions made
- Bundle ID `com.saafapp.saaf`. Material 3 like Figma (design.md §0). Backend: **Firebase** (`saaf-01`) + Cloudflare Worker.
- **Safety flags (health data) NEVER leave the phone** (`AiContext` has no such field; AI products checked on the phone by
  `ActiveRules`/`BuildRoutine`/`cautionFor`; the doctor PDF leaves them out). Skin numbers ONLY from Saaf AI reading the FRONT
  photo (consent; asked once, then automatic; Profile switch). No AI prices anywhere ("Check prices online").
- Cream check never says "safe"; phone rules (`FlagIngredients`) can only make the verdict stricter; sources only from search.
- Weather: city picker (no GPS); Open-Meteo through our server, cached 30 min; attribution shown.
- Quiz concern `bodyPigmentation` added after Figma (end of list). Ramadan labels via `routineTimeName`.
- **PLACEHOLDERS before release:** `FakeSubscriptionRepository`, Profile "Photo backup", demo AI when no server; prices of the
  22-product fallback catalogue need re-checking; ingredient/active rules need dermatologist review.

## Testing notes
- Widget tests use Ahem (16 dp/glyph): `FittedBox(scaleDown)`/`Flexible`; fixed pumps (no `pumpAndSettle` with spinners).
- Re-pumping `pumpSaafApp` keeps the old ProviderScope: `pumpWidget(const SizedBox())` between. Riverpod 3: `noAutoRetry`.
- Bash heredocs mangle `\\` and quotes: write scripts with the Write tool. `compute` in widget tests needs `runAsync`.

## Native notes (only verifiable via Codemagic)
- Android: Kotlin 2.4.0 + AGP 8.11.1 + `permission_handler 12.0.1`. INTERNET, CAMERA, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED,
  **RECORD_AUDIO + `<queries>` RecognitionService (speech_to_text, Bluetooth off)**. `screen_brightness` (app window only).
- iOS: target 15.5, `PERMISSION_CAMERA/NOTIFICATIONS`, **NSMicrophone/NSSpeechRecognition usage strings**. iOS build not tried.
- `codemagic.yaml` on Mac M2. Release signing = Codemagic keystore "saaf upload keystore".

## Open problems / questions for the user
- **Open-Meteo free tier is non-commercial**: buy their API plan (or switch provider in `backend/ai-proxy/src/weather.js`) before
  charging money. Firebase: real SMS untested (test number +92 300 1234567 / 123456); Play-signing SHA after first upload.
- Before release: lawyer review (Privacy Policy sections 5–6 changed a lot), native Urdu review, dermatologist review (rules,
  tips, cream flags), support email, deletion page, account-deletion Cloud Function, backup/sync, RevenueCat, crash reporting.

## Log
- Earlier: quiz, legal, Firebase auth; screens 10–14, guard, drift, reminders; Codemagic + Firebase; feedback round 1 (1508).
- 2026-10-17: AI tidy answers, web routine + keep/replace/stop, look-up, QR, honest scan results (1644).
- 2026-10-18: Phase 10.5 built (weather, cream check, trust, shelf, introducer, Ramadan/event, body, dermatologist, voice). 1713.
