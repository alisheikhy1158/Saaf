// Checks a Firebase sign-in token (a JWT signed by Google) with the Web Crypto
// API, as Firebase documents: right algorithm and key, right project, not
// expired, and a real user id.

const JWK_URL =
  'https://www.googleapis.com/robot/v1/metadata/jwk/securetoken@system.gserviceaccount.com';

export class AuthError extends Error {}

let keyCache = { keys: null, expires: 0 };

function b64urlToBytes(text) {
  const base64 = text.replace(/-/g, '+').replace(/_/g, '/');
  const padded = base64 + '='.repeat((4 - (base64.length % 4)) % 4);
  return Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
}

function b64urlToJson(text) {
  return JSON.parse(new TextDecoder().decode(b64urlToBytes(text)));
}

/** Google's current public keys (cached for as long as Google says). */
export async function fetchGoogleKeys(now = Date.now()) {
  if (keyCache.keys && keyCache.expires > now) return keyCache.keys;
  const response = await fetch(JWK_URL);
  if (!response.ok) throw new AuthError('keys_unavailable');
  const { keys } = await response.json();
  const maxAge = /max-age=(\d+)/.exec(response.headers.get('cache-control') ?? '');
  keyCache = { keys, expires: now + (maxAge ? Number(maxAge[1]) : 3600) * 1000 };
  return keys;
}

/**
 * @param {string} token the Firebase ID token
 * @param {string} projectId the Firebase project id
 * @returns {Promise<{uid: string}>}
 */
export async function verifyFirebaseToken(
  token,
  projectId,
  { now = Date.now(), fetchKeys = fetchGoogleKeys } = {},
) {
  if (typeof token !== 'string' || !projectId) throw new AuthError('format');
  const parts = token.split('.');
  if (parts.length !== 3) throw new AuthError('format');

  let header;
  let payload;
  try {
    header = b64urlToJson(parts[0]);
    payload = b64urlToJson(parts[1]);
  } catch {
    throw new AuthError('format');
  }

  if (header.alg !== 'RS256' || typeof header.kid !== 'string') throw new AuthError('algorithm');

  const seconds = Math.floor(now / 1000);
  const skew = 60;
  if (payload.aud !== projectId) throw new AuthError('audience');
  if (payload.iss !== `https://securetoken.google.com/${projectId}`) throw new AuthError('issuer');
  if (typeof payload.sub !== 'string' || payload.sub.length === 0 || payload.sub.length > 128) {
    throw new AuthError('subject');
  }
  if (typeof payload.exp !== 'number' || payload.exp <= seconds - skew) throw new AuthError('expired');
  if (typeof payload.iat !== 'number' || payload.iat > seconds + skew) throw new AuthError('issued_later');
  if (typeof payload.auth_time === 'number' && payload.auth_time > seconds + skew) {
    throw new AuthError('auth_time');
  }

  const keys = await fetchKeys(now);
  const jwk = keys.find((k) => k.kid === header.kid);
  if (!jwk) throw new AuthError('unknown_key');

  const key = await crypto.subtle.importKey(
    'jwk',
    jwk,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify'],
  );
  const valid = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5',
    key,
    b64urlToBytes(parts[2]),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
  );
  if (!valid) throw new AuthError('signature');

  return { uid: payload.sub };
}
