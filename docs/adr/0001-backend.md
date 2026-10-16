# ADR 0001 — Backend: Firebase or Supabase

- **Status:** **ACCEPTED 2026-10-16 — the owner chose Firebase** (this ADR originally recommended Supabase; the
  owner overruled it, which is their call). Sign-in is implemented behind the `AuthRepository` interface; until the
  Firebase project is configured the app keeps using `FakeAuthRepository` (fixed code `123456`). See
  `docs/firebase-setup.md` for the console steps only the owner can do.
- **Date:** 2026-10-16
- **Prices, quotas and SMS coverage below are from memory and change often — verify each on the provider's
  pricing page before deciding.**

## What the app needs (architecture.md §6, store-compliance.md)

| Need | Detail |
|---|---|
| Phone OTP sign-in | Pakistani numbers (+92). Delivery reliability and per-SMS cost matter more than anything else here. |
| Google sign-in + **Sign in with Apple** | Apple 4.8: Apple sign-in is mandatory on iOS because Google is offered. |
| Account deletion | In-app flow **and** a public web page (Play policy). Must delete server data, not just deactivate. |
| App Review demo login | A fixed phone number + code (PLAN 4.5). |
| Data | Profile, routine, check-ins, product catalogue + prices, ingredient-clash rules (relational), photo backup (opt-in). |
| Offline-first | The local drift DB is the source of truth; the backend only syncs (outbox, last-write-wins). |
| Privacy | Face photos never leave the phone unless the user turns backup on; no ad/tracking SDKs. |
| Team | One developer, Flutter, no backend experience: managed service, little ops. |

## Options

### A. Firebase (Auth + Firestore + Cloud Functions + Storage)
- **For:** the most mature Flutter SDKs (FlutterFire); phone auth built in with client SDKs that handle
  reCAPTCHA/Play Integrity/APNs; **test phone numbers with fixed codes** for App Review; free Auth tier; Google
  and Apple sign-in are first-class; Crashlytics later without another vendor.
- **Against:** Firestore is document-based: product ↔ ingredient ↔ clash rules and price history are awkward and
  can get expensive per read; deletion of a user's data across collections needs a Cloud Function you write;
  Cloud Functions need the pay-as-you-go plan; phone-auth SMS is billed per message beyond a small free quota
  and Pakistan rates are not the cheapest; vendor lock-in is high.
- **Adds a Google SDK** that must be declared in the App Privacy / Data safety forms.

### B. Supabase (Auth + Postgres + Edge Functions + Storage)
- **For:** Postgres fits the relational data (catalogue, ingredients, clash rules, price history); row-level
  security gives per-user isolation in SQL; "delete my account" is a single transaction (`on delete cascade`) +
  one Edge Function; open source and exportable (low lock-in); `supabase_flutter` is solid; test OTPs for review.
- **Against:** phone OTP needs a third-party **SMS provider** (Twilio, MessageBird, Vonage…) that you configure
  and pay — and you pick one that delivers well in Pakistan; a bit more setup than Firebase; free projects pause
  after inactivity (use a paid plan for production); fewer Flutter-specific extras (no built-in crash reporting).

### C. Own backend (e.g. Dart/Node + Postgres)
- Rejected for now: most work and ongoing ops for a solo developer, with no benefit over B at this size.

## Trade-off summary

| | Firebase | Supabase |
|---|---|---|
| Phone OTP set-up effort | lowest | medium (SMS provider) |
| SMS cost control in Pakistan | provider-managed | you choose the provider |
| Relational catalogue / clash rules | awkward | natural |
| Account deletion | custom function | cascade + function |
| Lock-in | high | low |
| Offline sync with drift | custom either way | custom either way |
| Flutter SDK maturity | excellent | good |

## Recommendation (for you to accept or overrule)

**Supabase**, because the product's core data (products, ingredients, clash rules, prices, routines) is relational
and account deletion is a hard store requirement that is simplest in SQL. Pick **Firebase** instead if getting
phone sign-in working quickly in Pakistan with the least set-up outweighs the data-model fit.
Either way, **evaluate SMS delivery to Pakistani networks first** (send test codes to Jazz, Telenor, Zong, Ufone
numbers) — that is the real go/no-go, not the database.

## Decision

☒ **Firebase** (Auth now; Firestore/Functions/Storage as the data features arrive) ☐ Supabase ☐ Other

Consequences to plan for: model the relational catalogue (products ↔ ingredients ↔ clash rules) so it fits Firestore
— clash rules are pure domain code shipped in the app (not queried), and the catalogue can be a Firestore
collection of denormalised product documents; write a Cloud Function that deletes a user's data across
collections for account deletion (requires the Blaze plan); budget for phone-auth SMS and test delivery on
Pakistani networks first.

## Consequences once decided
1. Add the SDK with `flutter pub add`, implement `AuthRepository` (OTP, Google, Apple, sign-out, session in
   `flutter_secure_storage` via `SecureStore`) and keep the fake for tests/Chrome.
2. Replace `authRepositoryProvider`'s fake; fixed review code configured **server-side** for one test number only.
3. Create the data schema + sync outbox; build the delete-account Edge Function / Cloud Function and the public
   deletion web page.
4. Update `docs/store-compliance.md` (Data safety / App Privacy: backend vendor, phone number collected) and the
   privacy policy.
5. Remove the "MUST be replaced before store release" fake from release builds.
