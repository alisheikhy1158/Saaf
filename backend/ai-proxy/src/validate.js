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
  for (const image of rawImages) {
    if (
      typeof image !== 'string' ||
      image.length < 16 ||
      image.length > MAX_IMAGE_CHARS ||
      !BASE64.test(image)
    ) {
      return { ok: false, error: 'bad_image' };
    }
    const type = sniffImage(image);
    if (!type) return { ok: false, error: 'bad_image' };
    images.push({ type, base64: image });
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

  const ctx = body.context && typeof body.context === 'object' ? body.context : {};
  const context = {
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

  return { ok: true, value: { question, images, history, context } };
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
