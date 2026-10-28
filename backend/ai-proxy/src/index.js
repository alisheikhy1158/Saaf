// Saaf AI proxy (Cloudflare Worker).
//
//   POST /v1/chat      {history, question, images, context}  ->  {reply}
//   POST /v1/routine   {context, scan, current}               ->  {summary, picks, current}
//   POST /v1/product   {image | barcode | qr, context}       ->  {found, title, insight, webChecked}
//   POST /v1/skin      {image, context}                       ->  {usable, summary, metrics} | {usable: false, problem}
//   POST /v1/safety    {image | barcode | qr | name, context} ->  {found, title, level, summary, ingredients, findings}
//   POST /v1/weather   {lat, lon}                             ->  {temperature, humidity, uvNow, uvMax, aqi, pm25}
//   POST /v1/report    {reason, replyId, replyText}          ->  {ok: true}
//   GET  /health                                           ->  {ok: true}
//
// The app never holds an AI key. Every request must carry a valid Firebase
// sign-in token. Questions, photos and replies are NOT stored or logged here;
// only a report (a reply the user flagged, and why) is kept, without any name.

import { AuthError, verifyFirebaseToken } from './auth.js';
import { UpstreamError, askGroq } from './groq.js';
import { lookUpProduct, planRoutine } from './products.js';
import { checkSafety } from './safety.js';
import { analyseSkin } from './skin.js';
import { fetchSkinWeather } from './weather.js';
import { validateChat, validateProduct, validateReport, validateRoutine, validateSafety, validateSkin, validateWeather } from './validate.js';

// A request (with up to three photos) may be this big.
const MAX_BODY_BYTES = 9_000_000;

/** On every answer: JSON only, never cached, framed or sniffed, HTTPS only. */
const SECURITY_HEADERS = {
  'Content-Type': 'application/json; charset=utf-8',
  'Cache-Control': 'no-store',
  'X-Content-Type-Options': 'nosniff',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Content-Security-Policy': "default-src 'none'; frame-ancestors 'none'",
  'Referrer-Policy': 'no-referrer',
  'X-Frame-Options': 'DENY',
};

function json(body, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: SECURITY_HEADERS });
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
function withinDailyLimit(env, uid, now) {
  return withinLimit(env, uid, now, 'd', Number(env.DAILY_LIMIT || 30));
}

/**
 * Counts today's requests of one kind ([prefix]) for this user (by a short
 * fingerprint, never the id); false when [limit] is reached.
 */
async function withinLimit(env, uid, now, prefix, limit) {
  if (!env.LIMITS) return true; // no counter set up: Groq's own limits protect us
  const day = new Date(now).toISOString().slice(0, 10);
  const key = `${prefix}:${await hashUser(uid)}:${day}`;
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

const skin = (request, env, deps) =>
  aiRequest(request, env, deps, validateSkin, (value, options) => analyseSkin(env, value, options));

const safety = (request, env, deps) =>
  aiRequest(request, env, deps, validateSafety, (value, options) => checkSafety(env, value, options));

const product = (request, env, deps) =>
  aiRequest(request, env, deps, validateProduct, (value, options) => lookUpProduct(env, value, options));

/** The skin weather: signed in, not counted as an AI question, cached 30 min per place. */
async function weather(request, env, deps) {
  const { uid } = await authenticate(request, env, deps);
  const read = await readJson(request);
  if (read.error) return json({ error: read.error }, read.status);
  const checked = validateWeather(read.body);
  if (!checked.ok) return json({ error: checked.error }, 400);
  const now = deps.now?.() ?? Date.now();
  if (!(await withinLimit(env, uid, now, 'wl', Number(env.WEATHER_LIMIT || 100)))) {
    return json({ error: 'daily_limit' }, 429);
  }

  const key = `w:${checked.value.lat},${checked.value.lon}`;
  const cached = env.LIMITS ? await env.LIMITS.get(key) : null;
  if (cached) return json(JSON.parse(cached));
  try {
    const result = await fetchSkinWeather(env, checked.value, { fetchImpl: deps.fetchImpl });
    if (env.LIMITS) await env.LIMITS.put(key, JSON.stringify(result), { expirationTtl: 30 * 60 });
    return json(result);
  } catch (error) {
    if (error instanceof UpstreamError) return json({ error: error.code }, error.status);
    throw error;
  }
}

async function report(request, env, deps) {
  const { uid } = await authenticate(request, env, deps);

  const read = await readJson(request);
  if (read.error) return json({ error: read.error }, read.status);
  const checked = validateReport(read.body);
  if (!checked.ok) return json({ error: checked.error }, 400);

  const now = deps.now?.() ?? Date.now();
  if (!(await withinLimit(env, uid, now, 'rl', Number(env.REPORT_LIMIT || 20)))) {
    return json({ error: 'daily_limit' }, 429);
  }
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
    if (request.method === 'POST' && url.pathname === '/v1/skin') return await skin(request, env, deps);
    if (request.method === 'POST' && url.pathname === '/v1/safety') return await safety(request, env, deps);
    if (request.method === 'POST' && url.pathname === '/v1/weather') return await weather(request, env, deps);
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
