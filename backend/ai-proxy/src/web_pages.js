// Public web pages the stores ask for: the Privacy Policy and Terms of Use (the
// same text as in the app, see legal_pages.js) and how to delete a Saaf account
// (Google Play's account deletion URL). No sign-in, no scripts, no cookies.

import { LEGAL_PAGES } from './legal_pages.js';

const TOKEN = '__SUPPORT_EMAIL__';

const STYLE = `body{font:16px/1.6 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;max-width:720px;margin:0 auto;padding:24px 16px;color:#1d2b24;background:#fbf9f1}
h1{font-size:28px;line-height:1.25}h2{font-size:19px;margin-top:28px}.meta{color:#5d6b63}a{color:#2f5d46}
nav{display:flex;gap:16px;flex-wrap:wrap;margin-bottom:24px}`;

const HEADERS = {
  'Content-Type': 'text/html; charset=utf-8',
  'Cache-Control': 'public, max-age=3600',
  'X-Content-Type-Options': 'nosniff',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Content-Security-Policy': "default-src 'none'; style-src 'unsafe-inline'; frame-ancestors 'none'",
  'Referrer-Policy': 'no-referrer',
  'X-Frame-Options': 'DENY',
};

function escape(text) {
  return text.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);
}

/** The support address when one is set (SUPPORT_EMAIL), as a mail link. */
function contact(env) {
  const email = typeof env.SUPPORT_EMAIL === 'string' && /^[^\s@<>"]+@[^\s@<>"]+$/.test(env.SUPPORT_EMAIL)
    ? env.SUPPORT_EMAIL
    : null;
  return email;
}

function withContact(html, env) {
  const email = contact(env);
  if (email) return html.replaceAll(TOKEN, `<a href="mailto:${escape(email)}">${escape(email)}</a>`);
  // No address yet: point to the store listing instead of a broken token.
  return html.replaceAll(`You can contact us at ${TOKEN}.`, 'You can contact us through the Saaf listing on the App Store or Google Play.')
    .replaceAll(TOKEN, 'us through the Saaf listing on the App Store or Google Play');
}

function layout(title, body) {
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${escape(title)} · Saaf</title><style>${STYLE}</style></head><body>
<nav><a href="/privacy">Privacy Policy</a><a href="/terms">Terms of Use</a><a href="/delete-account">Delete your account</a></nav>
${body}</body></html>`;
}

function deletionPage(env) {
  const email = contact(env);
  const ask = email
    ? `<p>Without the app, email <a href="mailto:${escape(email)}?subject=Delete%20my%20Saaf%20account">${escape(email)}</a> with the subject “Delete my Saaf account”, from the email address or with the mobile number you sign in with. We reply to confirm it is you, then delete the account.</p>`
    : '<p>Without the app, contact us through the Saaf listing on the App Store or Google Play and tell us the mobile number or email address you sign in with. We confirm it is you, then delete the account.</p>';
  return `<h1>Delete your Saaf account</h1>
<p>You can delete your Saaf account and its data at any time.</p>
<h2>In the app</h2>
<p>Open Saaf, go to <b>Profile</b>, then <b>Privacy</b>, then <b>Delete my account</b>, and confirm. This deletes your account straight away.</p>
<h2>Without the app</h2>
${ask}
<h2>What is deleted</h2>
<ul><li>Your account (sign-in by mobile number, Google or Apple) and the data kept with it.</li>
<li>Photos and skin answers are kept only on your phone: deleting the app or its data removes them.</li>
<li>Copies in our providers’ backups are removed within 30 days.</li></ul>
<h2>What may be kept</h2>
<ul><li>Payment records that Apple or Google must keep by law (we never see your card details).</li>
<li>Reports you sent about an AI answer, without your name, for up to 90 days.</li></ul>
<p><b>Deleting your account does not cancel a subscription.</b> Cancel it first in the App Store (Settings, your name, Subscriptions) or in Google Play (Payments and subscriptions).</p>`;
}

/** The page for [path], or null when it is not one of ours. */
export function webPage(path, env) {
  const html = path === '/privacy'
    ? layout('Privacy Policy', withContact(LEGAL_PAGES.privacy, env))
    : path === '/terms'
      ? layout('Terms of Use', withContact(LEGAL_PAGES.terms, env))
      : path === '/delete-account'
        ? layout('Delete your account', deletionPage(env))
        : null;
  return html === null ? null : new Response(html, { status: 200, headers: HEADERS });
}
