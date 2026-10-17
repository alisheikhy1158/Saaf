// Asks Groq (an OpenAI-compatible API running open-source models) for the reply.
// https://console.groq.com/docs/text-chat  and  https://console.groq.com/docs/vision

import { PHOTO_ONLY_QUESTION, buildSystemPrompt } from './prompt.js';

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';

export const TEXT_MODEL = 'openai/gpt-oss-120b';
export const VISION_MODEL = 'qwen/qwen3.8-27b';

export class UpstreamError extends Error {
  constructor(status, code) {
    super(code);
    this.status = status;
    this.code = code;
  }
}

/** The messages Groq receives: our rules first, the chat, then the question. */
export function buildMessages({ question, images, history, context }) {
  const messages = [
    { role: 'system', content: buildSystemPrompt(context) },
    ...history.map((m) => ({ role: m.role, content: m.text })),
  ];
  const text = question || PHOTO_ONLY_QUESTION;
  if (images.length === 0) {
    messages.push({ role: 'user', content: text });
  } else {
    messages.push({ role: 'user', content: withImages(text, images) });
  }
  return messages;
}

/** A user message with pictures, as Groq's vision models expect it. */
export function withImages(text, images) {
  return [
    { type: 'text', text },
    ...images.map((image) => ({
      type: 'image_url',
      image_url: { url: `data:${image.type};base64,${image.base64}` },
    })),
  ];
}

/**
 * Removes any visible "thinking" some models add and the citation marks the web
 * search leaves (like 【3†L1-L4】), and tidies the text.
 */
export function cleanReply(text) {
  return String(text ?? '')
    .replace(/<think>[\s\S]*?<\/think>/gi, '')
    .replace(/<think>[\s\S]*$/i, '')
    .replace(/【[^】]*】/g, '')
    .trim();
}

/** The text model for questions, the vision model when there are photos. */
export function modelFor(env, hasImages) {
  return hasImages
    ? { model: env.MODEL_VISION || VISION_MODEL, effort: env.REASONING_VISION ?? 'none' }
    : { model: env.MODEL_TEXT || TEXT_MODEL, effort: env.REASONING_TEXT ?? 'low' };
}

/**
 * Sends one chat completion to Groq and gives back the reply text (unclean).
 * Every Groq call goes through here, so the key is only ever in this header.
 */
export async function callGroq(env, body, { fetchImpl = fetch, timeoutMs = 45_000 } = {}) {
  if (!env.GROQ_API_KEY) throw new UpstreamError(503, 'not_configured');

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  let response;
  try {
    response = await fetchImpl(GROQ_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${env.GROQ_API_KEY}`,
      },
      body: JSON.stringify({ include_reasoning: false, stream: false, ...body }),
      signal: controller.signal,
    });
  } catch {
    console.error(`groq timeout after ${timeoutMs} ms (${body.model}${body.tools ? ', tools' : ''})`);
    throw new UpstreamError(504, 'timeout');
  } finally {
    clearTimeout(timer);
  }

  // Groq's own limits or an outage are "busy" for the app, not the user's fault.
  if (response.status === 429) throw new UpstreamError(503, 'busy');
  if (!response.ok) {
    // Groq's own error message (never the person's question) helps fix problems.
    let detail = '';
    try {
      detail = (await response.text()).slice(0, 300);
    } catch {
      // No detail.
    }
    console.error(`groq ${response.status} (${body.model}${body.tools ? ', tools' : ''}): ${detail}`);
    throw new UpstreamError(502, `groq_${response.status}`);
  }

  try {
    const data = await response.json();
    return String(data?.choices?.[0]?.message?.content ?? '');
  } catch {
    throw new UpstreamError(502, 'bad_reply');
  }
}

export async function askGroq(env, request, options = {}) {
  const { model, effort } = modelFor(env, request.images.length > 0);
  const body = {
    model,
    messages: buildMessages(request),
    temperature: 0.4,
    max_completion_tokens: 900,
  };
  if (effort) body.reasoning_effort = effort;

  const reply = cleanReply(await callGroq(env, body, options));
  if (!reply) throw new UpstreamError(502, 'empty_reply');
  return reply;
}
