// Saaf AI proxy (Cloudflare Worker).
//
//   POST /v1/chat      {history, question, images, context}  ->  {reply}
//   POST /v1/routine   {context, scan, current}               ->  {summary, picks, current}
//   POST /v1/product   {image | barcode | qr, context}       ->  {found, title, insight, webChecked}
//   POST /v1/report    {reason, replyId, replyText}          ->  {ok: true}
//   GET  /health                                           ->  {ok: true}
//
// The app never holds an AI key. Every request must carry a valid Firebase
// sign-in token. Questions, photos and replies are NOT stored or logged here;
// only a report (a reply the user flagged, and why) is kept, without any name.

import { AuthError, verifyFirebaseToken } from './auth.js';
import { UpstreamError, askGroq } from './groq.js';
import { lookUpProduct, planRoutine } from './products.js';
import { validateChat, validateProduct, validateReport, validateRoutine } from './validate.js';

// A request (with up to three photos) may be this big.
const MAX_BODY_BYTES = 9_000_000;

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
    },
  });
}

async function hashUser(uid) {
  const bytes = new TextEncoder().encode(uid);
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)]
    .slice(0, 8)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

async function readJson(request) {
  const declared = Number(request.headers.get('content-length') ?? 0);
  if (declared > MAX_BODY_BYTES) return { error: 'too_large', status: 413 };
  const text = await request.text();
  if (text.length > MAX_BODY_BYTES) return { error: 'too_large', status: 413 };
  try {
    return { body: JSON.parse(text) };
  } catch {
    return { error: 'bad_request', status: 400 };
  }
}

async function authenticate(request, env, deps) {
  const header = request.headers.get('authorization') ?? '';
  const match = /^Bearer (.+)$/.exec(header);
  if (!match) throw new AuthError('missing');
  return (deps.verify ?? verifyFirebaseToken)(match[1], env.FIREBASE_PROJECT_ID, {
    now: deps.now?.(),
  });
}

/** Counts today's questions for this user; false when the limit is reached. */
async function withinDailyLimit(env, uid, now) {
  if (!env.LIMITS) return true; // no counter set up: Groq's own limits protect us
  const limit = Number(env.DAILY_LIMIT || 30);
  const day = new Date(now).toISOString().slice(0, 10);
  const key = `d:${await hashUser(uid)}:${day}`;
  const used = Number((await env.LIMITS.get(key)) ?? 0);
  if (used >= limit) return false;
  await env.LIMITS.put(key, String(used + 1), { expirationTtl: 60 * 60 * 36 });
  return true;
}

/**
 * One AI request: sign-in, a checked body, the daily limit, then [run]. Every
 * kind of AI request counts toward the same daily limit.
 */
async function aiRequest(request, env, deps, validate, run) {
  const { uid } = await authenticate(request, env, deps);

  const read = await readJson(request);
  if (read.error) return json({ error: read.error }, read.status);

  const checked = validate(read.body);
  if (!checked.ok) return json({ error: checked.error }, 400);

  const now = deps.now?.() ?? Date.now();
  if (!(await withinDailyLimit(env, uid, now))) return json({ error: 'daily_limit' }, 429);

  try {
    return json(await run(checked.value, { fetchImpl: deps.fetchImpl }));
  } catch (error) {
    if (error instanceof UpstreamError) return json({ error: error.code }, error.status === 504 ? 503 : error.status);
    throw error;
  }
}

const chat = (request, env, deps) =>
  aiRequest(request, env, deps, validateChat, async (value, options) => ({
    reply: await askGroq(env, value, options),
  }));

const routine = (request, env, deps) =>
  aiRequest(request, env, deps, validateRoutine, (value, options) => planRoutine(env, value, options));

const product = (request, env, deps) =>
  aiRequest(request, env, deps, validateProduct, (value, options) => lookUpProduct(env, value, options));

async function report(request, env, deps) {
  const { uid } = await authenticate(request, env, deps);

  const read = await readJson(request);
  if (read.error) return json({ error: read.error }, read.status);
  const checked = validateReport(read.body);
  if (!checked.ok) return json({ error: checked.error }, 400);

  const now = deps.now?.() ?? Date.now();
  const entry = {
    at: new Date(now).toISOString(),
    user: await hashUser(uid), // a short fingerprint, not the user id
    ...checked.value,
  };
  if (env.REPORTS) {
    await env.REPORTS.put(`r:${now}:${entry.user}`, JSON.stringify(entry), {
      expirationTtl: 60 * 60 * 24 * 90,
    });
  } else {
    console.log('REPORT', JSON.stringify(entry));
  }
  return json({ ok: true });
}

export async function handle(request, env, deps = {}) {
  const url = new URL(request.url);
  try {
    if (request.method === 'GET' && url.pathname === '/health') return json({ ok: true });
    if (request.method === 'POST' && url.pathname === '/v1/chat') return await chat(request, env, deps);
    if (request.method === 'POST' && url.pathname === '/v1/routine') return await routine(request, env, deps);
    if (request.method === 'POST' && url.pathname === '/v1/product') return await product(request, env, deps);
    if (request.method === 'POST' && url.pathname === '/v1/report') return await report(request, env, deps);
    return json({ error: 'not_found' }, 404);
  } catch (error) {
    if (error instanceof AuthError) return json({ error: 'unauthorised' }, 401);
    console.error('proxy error', error?.message ?? error);
    return json({ error: 'server_error' }, 500);
  }
}

export default {
  fetch: (request, env) => handle(request, env),
};
