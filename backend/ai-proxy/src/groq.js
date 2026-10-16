// Asks Groq (an OpenAI-compatible API running open-source models) for the reply.
// https://console.groq.com/docs/text-chat  and  https://console.groq.com/docs/vision

import { PHOTO_ONLY_QUESTION, buildSystemPrompt } from './prompt.js';

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';

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
    messages.push({
      role: 'user',
      content: [
        { type: 'text', text },
        ...images.map((image) => ({
          type: 'image_url',
          image_url: { url: `data:${image.type};base64,${image.base64}` },
        })),
      ],
    });
  }
  return messages;
}

/** Removes any visible "thinking" some models add, and tidies the text. */
export function cleanReply(text) {
  return String(text ?? '')
    .replace(/<think>[\s\S]*?<\/think>/gi, '')
    .replace(/<think>[\s\S]*$/i, '')
    .trim();
}

export async function askGroq(env, request, { fetchImpl = fetch, timeoutMs = 45_000 } = {}) {
  if (!env.GROQ_API_KEY) throw new UpstreamError(503, 'not_configured');

  const hasImages = request.images.length > 0;
  const model = hasImages
    ? (env.MODEL_VISION || 'qwen/qwen3.8-27b')
    : (env.MODEL_TEXT || 'openai/gpt-oss-120b');
  // Qwen can skip its reasoning ("none"); GPT-OSS cannot, "low" keeps it quick.
  const effort = hasImages ? (env.REASONING_VISION ?? 'none') : (env.REASONING_TEXT ?? 'low');

  const body = {
    model,
    messages: buildMessages(request),
    temperature: 0.4,
    max_completion_tokens: 900,
    include_reasoning: false,
    stream: false,
  };
  if (effort) body.reasoning_effort = effort;

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
      body: JSON.stringify(body),
      signal: controller.signal,
    });
  } catch {
    throw new UpstreamError(504, 'timeout');
  } finally {
    clearTimeout(timer);
  }

  // Groq's own limits or an outage are "busy" for the app, not the user's fault.
  if (response.status === 429) throw new UpstreamError(503, 'busy');
  if (!response.ok) throw new UpstreamError(502, `groq_${response.status}`);

  let data;
  try {
    data = await response.json();
  } catch {
    throw new UpstreamError(502, 'bad_reply');
  }
  const reply = cleanReply(data?.choices?.[0]?.message?.content);
  if (!reply) throw new UpstreamError(502, 'empty_reply');
  return reply;
}
