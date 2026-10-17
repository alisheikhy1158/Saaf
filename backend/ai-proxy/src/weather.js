// Today's "skin weather" for a place: temperature, humidity, UV (now and the
// day's highest) and air quality, from Open-Meteo (no key needed for the free,
// non-commercial tier; a paid plan is needed once Saaf charges money — swap the
// URLs or add the key here, no app update needed).
// https://open-meteo.com/en/docs  ·  https://open-meteo.com/en/docs/air-quality-api
// Data: Open-Meteo.com (CC BY 4.0) and CAMS; the app shows the attribution.

import { UpstreamError } from './groq.js';

const FORECAST_URL = 'https://api.open-meteo.com/v1/forecast';
const AIR_URL = 'https://air-quality-api.open-meteo.com/v1/air-quality';

async function getJson(fetchImpl, url, timeoutMs) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetchImpl(url, { signal: controller.signal });
    if (!response.ok) return null;
    return await response.json();
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

function number(value, digits = 0) {
  if (typeof value !== 'number' || !Number.isFinite(value)) return null;
  const f = 10 ** digits;
  return Math.round(value * f) / f;
}

/** {temperature, humidity, uvNow, uvMax, aqi, pm25}; air quality may be null. */
export async function fetchSkinWeather(env, { lat, lon }, { fetchImpl = fetch, timeoutMs = 10_000 } = {}) {
  const place = `latitude=${lat}&longitude=${lon}`;
  const forecastUrl = `${env.WEATHER_URL || FORECAST_URL}?${place}`
    + '&current=temperature_2m,relative_humidity_2m,uv_index&daily=uv_index_max&timezone=auto&forecast_days=1';
  const airUrl = `${env.AIR_QUALITY_URL || AIR_URL}?${place}&current=us_aqi,pm2_5&timezone=auto`;

  const [forecast, air] = await Promise.all([
    getJson(fetchImpl, forecastUrl, timeoutMs),
    getJson(fetchImpl, airUrl, timeoutMs),
  ]);
  const current = forecast?.current;
  const temperature = number(current?.temperature_2m);
  if (temperature === null) throw new UpstreamError(503, 'weather_unavailable');

  return {
    temperature,
    humidity: number(current.relative_humidity_2m),
    uvNow: number(current.uv_index, 1),
    uvMax: number(forecast?.daily?.uv_index_max?.[0], 1),
    aqi: number(air?.current?.us_aqi),
    pm25: number(air?.current?.pm2_5),
  };
}
