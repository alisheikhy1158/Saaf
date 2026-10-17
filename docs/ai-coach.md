# AI skin coach — how it works and how to switch it on

The **AI coach** lets a user ask about their routine, ingredients or products, and attach a photo of their skin. An
open-source model on **Groq** writes the answer. The app never holds an AI key: it talks to a tiny server of ours
(`backend/ai-proxy`, a Cloudflare Worker) which checks the user's Firebase sign-in, adds the secret key and the safety
instructions, and keeps a daily limit.

```
phone  ──(Firebase sign-in token + chat)──▶  Cloudflare Worker  ──(secret key)──▶  Groq  ──▶  open-source model
          nothing else about the user                keeps no chats                (gpt-oss-120b for text,
                                                                                    qwen3.8-27b for photos)
```

## What the app sends (and never sends)

| Sent | Never sent |
|---|---|
| the typed message, up to 3 photos the user attaches, the last 10 messages of the chat | name, phone number, email |
| skin type, concerns, sensitivity, budget band, names of the routine's products | **safety answers** (pregnancy/breastfeeding, prescription treatment, allergy), face-scan photos |

**Progress review (Progress screen).** Scans are now every **two weeks**. The Progress screen has an "AI progress review"
card: the user sees thumbnails of their **first, previous and latest FRONT photos**, who receives them (Groq, through our
server) and taps **Send**. The photos are shrunk to 1024 px JPEG on the phone (`ImagePhotoShrinker`); the originals are
never touched; **side photos are never sent**. The answer appears in the AI chat (so it has the AI label, the report
button and Try again). The server's instructions tell the model to compare honestly, warn that light/angle/filters change
how skin looks, and not to praise or alarm without reason. The rule-based "scores" are NOT sent: they come from the
placeholder analyser and would mislead the model.

**Product picks (Routine screen, `/v1/recommend`).** With Saaf AI on, it chooses the routine's products. The phone
first removes every product the safety answers rule out (`BuildRoutine.allowedFor`), then sends only the remaining
products (id, step, name, price, skin types, concerns, key actives), the skin facts and the latest scan scores (four
numbers, never photos). The model (gpt-oss-120b, strict JSON schema) returns ids + one-line reasons; the server drops
any id not in the list, and the app still applies the safety answers and the budget (`BuildRoutine(preferred:)`). Picks
are cached on the phone (`aiProductPicks` setting) and only re-asked when the quiz, scan or language change. Without
Saaf AI, or if it fails, the rule-based picks stay. The card shows "Picked by Saaf AI", the reasons and a report button.

**Product look-up (`/product-ai`, `/v1/product`).** For a barcode nobody knows, a QR code that is only a link, or a photo
of the label when nothing scans. The user sees what will be sent and taps "Look it up". A photo is read first by the
vision model (strict JSON: brand, name, ingredients; "not a product" stops there), then gpt-oss-120b with Groq's
**browser search** tool finds the product and writes the answer (first line `PRODUCT: …`). If the search tool fails the
server answers without it and the app says it was not checked on the web. QR codes carrying a product number (GS1
Digital Link / DataMatrix) are read on the phone (`ReadProductCode`) and go to the normal barcode look-up. Groq retired
its `compound` web-search models in Sept 2026; browser search is the documented replacement.

**Answer format.** The prompts ask for a 1–2 sentence answer, at most 3 bold headings with "- " bullets, no tables, under
150 words. The app renders that with `SaafAiText` (`core/utils/ai_text.dart`), which also turns any table into bullets.

The safety answers are health data and the quiz promises they never leave the phone. The coach asks about pregnancy and
allergies **in the chat** before suggesting a strong active.

## Store compliance (docs/store-compliance.md §5)

- **Explicit permission first** (Apple 5.1.2(i)): the first time, a screen says what is sent and that **Groq** receives it
  (through our Cloudflare server); the user must tap "I agree". It can be withdrawn in *Profile → AI coach sharing* or in
  the chat menu; withdrawing wipes the conversation. Deleting the account removes the permission.
- **Report button** (Google Play AI-generated content policy): every answer is labelled "AI answer" and has a flag button;
  reports go to `/v1/report` and are kept 90 days (no name) in the `REPORTS` store.
- **Guardrails**: the server's instructions forbid diagnosis, prescription drugs, steroids, hydroquinone, mercury and
  skin bleaching, ask about pregnancy/allergies first, and send worrying symptoms to a dermatologist. A standing line
  in the chat says "not medical advice".
- The **Privacy Policy** (section 6) and the consent screen describe it. Also tell the stores:
  - App Store privacy labels: *User Content (photos, other user content)* and *Usage data* are shared with a third party
    for app functionality, not linked to tracking.
  - Play *Data safety*: photos and in-app messages **shared** with a service provider (Groq), optional, processed
    ephemerally, encrypted in transit.
- Lawyer review of the new Privacy Policy text is still needed (see `LEGAL_REVIEWED`).

## Switching it on (owner steps, about 30 minutes)

You need: a **Groq** account and a **Cloudflare** account (both have free plans), and **Node.js** (already on your PC).
Run the commands below in a terminal opened in `D:\Saaf\backend\ai-proxy`.

1. **Groq key.** https://console.groq.com → *API Keys* → create one → copy it (it is shown once). Treat it like a password;
   never put it in chat, in the repo or in the app.
2. **Install the tools** (downloads Cloudflare's `wrangler` tool into this folder):
   ```
   npm install
   ```
3. **Log in to Cloudflare** (opens your browser):
   ```
   npx wrangler login
   ```
4. **Create the two small stores** (daily counters, reports) and paste each printed `id` into `wrangler.toml`
   (remove the `#` in front of the two `[[kv_namespaces]]` blocks):
   ```
   npx wrangler kv namespace create LIMITS
   npx wrangler kv namespace create REPORTS
   ```
5. **Give it the secret key** (it asks you to paste it):
   ```
   npx wrangler secret put GROQ_API_KEY
   ```
6. **Check the tests pass, then publish**:
   ```
   npm test
   npx wrangler deploy
   ```
   It prints your address, like `https://saaf-ai.<your-name>.workers.dev`. Open `<address>/health` in a browser: it
   should say `{"ok":true}`.
7. **Tell the app the address**: Codemagic → app → Environment variables → group `app_config` → add
   `AI_PROXY_URL` = your address (no trailing slash). Real sign-in must also be on (`USE_FIREBASE=true`), because the
   server only accepts Firebase tokens. Rebuild.

Without step 7 a store build shows "The AI coach isn't available right now" (it never pretends). Chrome, debug builds and
`USE_FIREBASE=false` builds use a **demo** coach that says it is a demo.

## Costs and limits

- Groq (check https://console.groq.com/docs/models for current prices): `openai/gpt-oss-120b` about $0.15 / $0.60 per
  million input / output tokens; `qwen/qwen3.8-27b` (reads photos) about $0.80 / $4.00; each photo counts as about 2,048
  input tokens. A typical question costs a fraction of a cent. Set a **spend limit** in the Groq console.
- Cloudflare Workers free plan: 100,000 requests a day.
- Per user: `DAILY_LIMIT` questions a day (default 30, in `wrangler.toml`). The app shows "You've reached today's limit".
  Product picks and look-ups count toward the same limit. A look-up with browser search uses more tokens (the search
  results are read by the model): budget roughly 5–10x a chat answer.

## Keeping it working

- **Models change.** Groq retires models (its docs list them). Change `MODEL_TEXT` / `MODEL_VISION` in `wrangler.toml`
  and run `npx wrangler deploy`: **no app update needed**. `qwen/qwen3.8-27b` was a *preview* model when this was built;
  check `https://console.groq.com/docs/models` before launch and pick a production vision model if one exists.
- **Reports.** Read them with `npx wrangler kv key list --binding REPORTS` and `npx wrangler kv key get --binding REPORTS <key>`.
  Review them regularly; remove or fix prompts in `src/prompt.js` if a pattern shows up.
- **Prompts** live in `backend/ai-proxy/src/prompt.js`; change, run `npm test`, deploy.
- Nothing is logged except errors. Do not add logging of questions, photos or answers.

## Not done yet / ideas

- No streaming (the answer appears all at once, usually in a few seconds).
- No Pro gate: free users get the daily limit. Decide in Phase 9 whether more is a Pro feature.
- Prompt Guard / a moderation model in front of the main model is a possible hardening step.
- A native Urdu speaker should read the Urdu text and a few Urdu answers.
