// Checks and cleans what the app sends. Anything unexpected is refused or
// dropped: the model only ever sees text this file has accepted.

export const MAX_QUESTION = 1000;
export const MAX_HISTORY = 10;
export const MAX_HISTORY_TEXT = 4000;
export const MAX_IMAGES = 3;
// About 2 MB of picture per photo (base64 text is a third longer than the bytes).
export const MAX_IMAGE_CHARS = 2_800_000;
export const MAX_ROUTINE_PRODUCTS = 12;

const SKIN_TYPES = ['oily', 'dry', 'combination', 'normal', 'notSure'];
const CONCERNS = ['darkSpots', 'acne', 'oiliness', 'dryness', 'unevenTone'];
const SENSITIVITIES = ['low', 'sometimes', 'high'];
const BUDGETS = ['essential', 'balanced', 'comfortable', 'premium'];
const LANGUAGES = ['en', 'ur'];
const REPORT_REASONS = ['harmful', 'wrong', 'offensive', 'other'];

const BASE64 = /^[A-Za-z0-9+/]+={0,2}$/;

/** Text without control characters, trimmed and capped. */
export function cleanText(value, max) {
  if (typeof value !== 'string') return '';
  // eslint-disable-next-line no-control-regex
  const text = value.replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/g, '');
  return text.trim().slice(0, max);
}

/** Which picture type the base64 text really is, from its first bytes. */
export function sniffImage(base64) {
  let head;
  try {
    head = Uint8Array.from(atob(base64.slice(0, 24)), (c) => c.charCodeAt(0));
  } catch {
    return null;
  }
  const ascii = (from, to) => String.fromCharCode(...head.slice(from, to));
  if (head[0] === 0xff && head[1] === 0xd8 && head[2] === 0xff) return 'image/jpeg';
  if (head[0] === 0x89 && ascii(1, 4) === 'PNG') return 'image/png';
  if (ascii(0, 4) === 'RIFF' && ascii(8, 12) === 'WEBP') return 'image/webp';
  return null;
}

function pick(value, allowed) {
  return typeof value === 'string' && allowed.includes(value) ? value : null;
}

/**
 * @returns {{ok: true, value: object} | {ok: false, error: string}}
 */
export function validateChat(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return { ok: false, error: 'bad_request' };
  }

  const question = cleanText(body.question, MAX_QUESTION + 1);
  if (question.length > MAX_QUESTION) return { ok: false, error: 'question_too_long' };

  const rawImages = body.images ?? [];
  if (!Array.isArray(rawImages) || rawImages.length > MAX_IMAGES) {
    return { ok: false, error: 'too_many_images' };
  }
  const images = [];
  for (const raw of rawImages) {
    const image = cleanImage(raw);
    if (!image) return { ok: false, error: 'bad_image' };
    images.push(image);
  }

  if (!question && images.length === 0) return { ok: false, error: 'empty' };

  const rawHistory = body.history ?? [];
  if (!Array.isArray(rawHistory)) return { ok: false, error: 'bad_request' };
  const history = [];
  for (const item of rawHistory.slice(-MAX_HISTORY)) {
    if (!item || typeof item !== 'object') continue;
    const role = item.role === 'assistant' ? 'assistant' : item.role === 'user' ? 'user' : null;
    const text = cleanText(item.text, MAX_HISTORY_TEXT);
    if (role && text) history.push({ role, text });
  }

  return { ok: true, value: { question, images, history, context: cleanContext(body.context) } };
}

/** What the app may say about the person; anything else is dropped. */
export function cleanContext(raw) {
  const ctx = raw && typeof raw === 'object' && !Array.isArray(raw) ? raw : {};
  return {
    language: pick(ctx.language, LANGUAGES) ?? 'en',
    skinType: pick(ctx.skinType, SKIN_TYPES),
    concerns: Array.isArray(ctx.concerns)
      ? ctx.concerns.filter((c) => CONCERNS.includes(c)).slice(0, CONCERNS.length)
      : [],
    sensitivity: pick(ctx.sensitivity, SENSITIVITIES),
    budget: pick(ctx.budget, BUDGETS),
    routine: Array.isArray(ctx.routine)
      ? ctx.routine
          .map((name) => cleanText(name, 120))
          .filter(Boolean)
          .slice(0, MAX_ROUTINE_PRODUCTS)
      : [],
  };
}

/** One photo as base64 text, or null when it is not a real picture. */
export function cleanImage(image) {
  if (
    typeof image !== 'string' ||
    image.length < 16 ||
    image.length > MAX_IMAGE_CHARS ||
    !BASE64.test(image)
  ) {
    return null;
  }
  const type = sniffImage(image);
  return type ? { type, base64: image } : null;
}

export const STEPS = ['cleanser', 'treatment', 'moisturiser', 'sunscreen'];
export const MAX_CURRENT = 10;
const METRICS = ['darkSpots', 'breakouts', 'oiliness', 'hydration'];

/** The latest face scan's four scores (0 to 1), or null. Never photos. */
export function cleanScan(raw) {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return null;
  const metrics = {};
  for (const name of METRICS) {
    const value = raw[name];
    if (typeof value === 'number' && value >= 0 && value <= 1) {
      metrics[name] = Math.round(value * 100) / 100;
    }
  }
  return Object.keys(metrics).length ? metrics : null;
}

/**
 * A routine request: the person's skin facts, optionally their latest scan
 * scores, and the names of the products they use now (to keep or change).
 * Their safety answers are never sent: the app checks the picks against them.
 */
export function validateRoutine(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return { ok: false, error: 'bad_request' };
  }
  const raw = body.current ?? [];
  if (!Array.isArray(raw)) return { ok: false, error: 'bad_request' };
  if (raw.length > MAX_CURRENT) return { ok: false, error: 'too_many_products' };
  // Each is a name, or {name, step} when the person said what kind it is.
  const current = [];
  for (const item of raw) {
    const name = cleanText(typeof item === 'string' ? item : item?.name, 120);
    if (!name || current.some((c) => c.name.toLowerCase() === name.toLowerCase())) continue;
    const step = typeof item === 'object' && STEPS.includes(item?.step) ? item.step : 'other';
    current.push({ name, step });
  }
  return {
    ok: true,
    value: { context: cleanContext(body.context), scan: cleanScan(body.scan), current },
  };
}

/** One front photo of the face for the AI skin estimate (nothing else about the person). */
export function validateSkin(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return { ok: false, error: 'bad_image' };
  }
  const image = cleanImage(body.image);
  if (!image) return { ok: false, error: 'bad_image' };
  return { ok: true, value: { image, context: cleanContext(body.context) } };
}

/** A product to check for harmful ingredients: a label photo, barcode, QR text or a typed name. */
export function validateSafety(body) {
  if (body && typeof body === 'object' && !Array.isArray(body) && typeof body.name === 'string' && body.name.trim()) {
    if (['image', 'barcode', 'qr'].some((k) => body[k])) return { ok: false, error: 'bad_request' };
    return {
      ok: true,
      value: { context: cleanContext(body.context), image: null, barcode: null, qr: null, name: cleanText(body.name, 120) },
    };
  }
  const checked = validateProduct(body);
  return checked.ok ? { ok: true, value: { ...checked.value, name: null } } : checked;
}

/** A place for the skin weather, rounded to about 1 km (never more precise). */
export function validateWeather(body) {
  const lat = body?.lat;
  const lon = body?.lon;
  const ok = (v, max) => typeof v === 'number' && Number.isFinite(v) && Math.abs(v) <= max;
  if (!ok(lat, 90) || !ok(lon, 180)) return { ok: false, error: 'bad_place' };
  const round = (v) => Math.round(v * 100) / 100;
  return { ok: true, value: { lat: round(lat), lon: round(lon) } };
}

export const MAX_QR = 500;

/** A product to look up: exactly one of a label photo, a barcode or QR text. */
export function validateProduct(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return { ok: false, error: 'bad_request' };
  }
  const given = ['image', 'barcode', 'qr'].filter((k) => body[k] !== undefined && body[k] !== null && body[k] !== '');
  if (given.length !== 1) return { ok: false, error: 'bad_request' };

  const value = { context: cleanContext(body.context), image: null, barcode: null, qr: null };
  if (given[0] === 'image') {
    value.image = cleanImage(body.image);
    if (!value.image) return { ok: false, error: 'bad_image' };
  } else if (given[0] === 'barcode') {
    if (typeof body.barcode !== 'string' || !/^\d{8,14}$/.test(body.barcode)) {
      return { ok: false, error: 'bad_barcode' };
    }
    value.barcode = body.barcode;
  } else {
    if (typeof body.qr !== 'string' || body.qr.length > MAX_QR) return { ok: false, error: 'bad_qr' };
    value.qr = cleanText(body.qr, MAX_QR);
    if (!value.qr) return { ok: false, error: 'bad_qr' };
  }
  return { ok: true, value };
}

export function validateReport(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return { ok: false, error: 'bad_request' };
  }
  const reason = pick(body.reason, REPORT_REASONS);
  const replyText = cleanText(body.replyText, MAX_HISTORY_TEXT);
  const replyId = cleanText(body.replyId, 64);
  if (!reason || !replyText) return { ok: false, error: 'bad_request' };
  return { ok: true, value: { reason, replyText, replyId } };
}
