# Firebase setup (owner steps)

The app is already coded for Firebase Authentication (`lib/data/repositories/firebase_auth_repository.dart`). Until
you finish the steps below, builds use the **fake backend** (any number, code `123456`) — fine for Chrome and testing,
**never for a store release**. Everything here happens in web consoles; you do not need Xcode or Android Studio.

> Verify against the current Firebase console wording; screens change. Prices/quotas (SMS) change too — check
> https://firebase.google.com/pricing before enabling phone sign-in for real users.

## 1. Create the project
1. https://console.firebase.google.com → **Add project** → name it `saaf` (no Google Analytics needed — the app
   uses no analytics, see the Privacy Policy).
2. **Build → Authentication → Get started → Sign-in method**, enable:
   - **Phone**
   - **Google** (set a support email)
   - **Apple** (needs the Apple Developer account, see step 4)

## 2. Register the two apps (this gives you the values Codemagic needs)
1. Project settings (gear) → **Your apps** → **Add app → Android**. Package name: `com.saafapp.saaf`.
   Add your **SHA-1 and SHA-256** fingerprints (see "Fingerprints" below). Skip downloading `google-services.json`.
2. **Add app → iOS**. Bundle ID: `com.saafapp.saaf`. Skip downloading `GoogleService-Info.plist`.
3. In Project settings → Your apps, note for each app: **API key** and **App ID**, and for the project:
   **Project ID** and **Sender ID** (Project settings → Cloud Messaging → "Sender ID", or the "Project number").

## 3. Put the values into Codemagic
Codemagic → your app → Environment variables → group **`app_config`** → add (mark Secret where you like — none of
these is a password, but there is no reason to publish them):

| Variable | Value |
|---|---|
| `USE_FIREBASE` | `true` (only once everything below is done) |
| `FIREBASE_PROJECT_ID` | project ID |
| `FIREBASE_MESSAGING_SENDER_ID` | sender ID / project number |
| `FIREBASE_API_KEY_ANDROID` | the Android app's API key |
| `FIREBASE_APP_ID_ANDROID` | the Android app's App ID (`1:…:android:…`) |
| `FIREBASE_API_KEY_IOS` | the iOS app's API key |
| `FIREBASE_APP_ID_IOS` | the iOS app's App ID (`1:…:ios:…`) |
| `SUPPORT_EMAIL` | the address users can write to (shown in the Terms/Privacy Policy) |
| `DELETION_URL` | public web page for account-deletion requests (Google Play requires one) |
| `LEGAL_REVIEWED` | `true` **only after a lawyer has reviewed the Terms and Privacy Policy** (hides the "Draft" chip) |

## 4. Apple
- In the Apple Developer portal, App ID `com.saafapp.saaf` → enable the **Sign in with Apple** capability
  (the entitlement file is already in the project: `ios/Runner/Runner.entitlements`). Regenerate the provisioning profile.
- In Firebase → Authentication → Sign-in method → **Apple**: enable it (for the native iOS flow no extra service ID is needed).
- **Phone sign-in on iOS:** Firebase → Project settings → **Cloud Messaging** → upload an **APNs authentication key**
  (Apple Developer → Keys). Without it Firebase falls back to a reCAPTCHA page, which also works.
  The build script adds the URL scheme Firebase needs automatically from `FIREBASE_APP_ID_IOS`.

## 5. Android fingerprints
Firebase needs your signing certificates' fingerprints so Google trusts the app:
- Upload key (the `.jks` from the Codemagic setup): `keytool -list -v -keystore saaf-upload.jks -alias saaf_upload`
  (shows SHA-1 and SHA-256; `keytool` ships with any JDK).
- **Google Play App Signing key**: Play Console → your app → Setup → App signing → copy its SHA-1 / SHA-256 too
  (users install builds signed with this key).
Add each fingerprint in Firebase → Project settings → your Android app → **Add fingerprint**.

## 6. App Review demo login (required by Apple 2.1 / PLAN 4.5)
Firebase → Authentication → Sign-in method → Phone → **Phone numbers for testing**: add one number with a fixed
6-digit code. Put that number and code in the App Review notes. (Test numbers never send an SMS.)

## 7. Before real users
- Check the SMS pricing/quota for Pakistan and set a **budget alert** (Google Cloud Billing).
- Test code delivery on **Jazz, Telenor, Zong and Ufone** numbers — this is the real go/no-go (ADR 0001).
- Account deletion needs a Cloud Function that deletes a user's data (Phase 4.4); that requires the **Blaze** plan.
- Add the Firebase Auth / Google as a processor to the App Privacy and Play Data safety forms.

## What the app does with these values
`FIREBASE_*` are read in `lib/core/config/env.dart` and used in `lib/data/services/firebase_bootstrap.dart` to start
Firebase from code, so no `google-services.json` / `GoogleService-Info.plist` is committed. Firebase starts lazily
the first time the user signs in.
