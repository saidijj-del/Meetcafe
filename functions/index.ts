/**
 * MeetCafe - discoverCafe Cloud Function (Firebase Functions v2).
 *
 * Computes the geographic midpoint between two users, queries OpenStreetMap
 * for nearby cafés (Overpass API), then ranks them by travel fairness using
 * OSRM routing - ported 1:1 from the web app's backend function.
 *
 * Deploy: firebase deploy --only functions
 */

import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

const R = 6371000; // earth radius (m)
const toRad = (d: number) => (d * Math.PI) / 180;

function haversine(lat1: number, lon1: number, lat2: number, lon2: number) {
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) ** 2 +
        Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
    return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

async function fetchWithTimeout(url: string, opts: RequestInit = {}, ms = 14000) {
    const ctrl = new AbortController();
    const t = setTimeout(() => ctrl.abort(), ms);
    try {
        const res = await fetch(url, { ...opts, signal: ctrl.signal });
        return res;
    } finally {
        clearTimeout(t);
    }
}

const OVERPASS_ENDPOINTS = [
  "https://overpass-api.de/api/interpreter",
  "https://overpass-api.kumi.systems/api/interpreter",
];

async function queryCafes(lat: number, lng: number, radius: number) {
  const query = `[out:json][timeout:15];(node["amenity"="cafe"](around:${radius},${lat},${lng});way["amenity"="cafe"](around:${radius},${lat},${lng}););out center 40;`;
  const data = encodeURIComponent(query);

  for (const base of OVERPASS_ENDPOINTS) {
    try {
      const res = await fetchWithTimeout(`${base}?data=${data}`, {
        headers: { "User-Agent": "MeetCafe/1.0" },
      });
      if (!res.ok) continue;
      const json: any = await res.json();
      return (json.elements || []).map((el: any) => {
        const elat = el.lat ?? el.center?.lat;
        const elng = el.lon ?? el.center?.lon;
        const name = el.tags?.name;
        if (!name || elat == null || elng == null) return null;
        const rating = el.tags?.stars ? Number(el.tags.stars) : null;
        return { lat: elat, lng: elng, name, rating };
      }).filter(Boolean);
    } catch (e) {
      logger.warn("Overpass endpoint failed", { base, error: String(e) });
      continue;
    }
  }
  return [];
}

async function osrmTableDurations(
  iLat: number, iLng: number,
  fLat: number, fLng: number,
  candidates: { lat: number; lng: number }[]
): Promise<number[][] | null> {
  const coords = [
    `${iLng},${iLat}`,
    `${fLng},${fLat}`,
    ...candidates.map((c) => `${c.lng},${c.lat}`),
  ].join(";");
  const url = `https://router.project-osrm.org/table/v1/driving/${coords}?sources=0;1&annotations=duration`;
  try {
    const res = await fetchWithTimeout(url, {}, 7000);
    if (!res.ok) return null;
    const json: any = await res.json();
    return json?.durations ?? null;
  } catch {
    return null;
  }
}

function fallbackDuration(lat1: number, lon1: number, lat2: number, lon2: number) {
  // straight-line distance / 40 km/h, in seconds
  return haversine(lat1, lon1, lat2, lon2) / 11;
}

export const discoverCafe = onRequest(
  { timeoutSeconds: 30, cors: true },
  async (req, res) => {
    const body = req.body || {};
    const iLat = Number(body.initiator_lat);
    const iLng = Number(body.initiator_lng);
    const fLat = Number(body.friend_lat);
    const fLng = Number(body.friend_lng);

    if ([iLat, iLng, fLat, fLng].some((n) => Number.isNaN(n))) {
      res.status(400).json({ error: "invalid_coordinates" });
      return;
    }

    const midLat = (iLat + fLat) / 2;
    const midLng = (iLng + fLng) / 2;

    const radii = [2000, 4000, 8000, 15000];
    let cafes: any[] = [];
    for (const r of radii) {
      cafes = await queryCafes(midLat, midLng, r);
      if (cafes.length > 0) break;
    }

    if (cafes.length === 0) {
      res.json({ found: false, status: "no_cafe", mid_lat: midLat, mid_lng: midLng });
      return;
    }

    // sort by distance from midpoint, take closest 15
    cafes.sort(
      (a, b) =>
        haversine(midLat, midLng, a.lat, a.lng) -
        haversine(midLat, midLng, b.lat, b.lng)
    );
    const candidates = cafes.slice(0, 15);

    const durations = await osrmTableDurations(iLat, iLng, fLat, fLng, candidates);

    let best: any = null;
    let bestScore = Infinity;
    candidates.forEach((c, idx) => {
      let tI: number;
      let tF: number;
      if (durations) {
        tI = durations[0][idx + 2];
        tF = durations[1][idx + 2];
        if (tI == null || tF == null) return;
      } else {
        tI = fallbackDuration(iLat, iLng, c.lat, c.lng);
        tF = fallbackDuration(fLat, fLng, c.lat, c.lng);
      }
      const fairness = Math.abs(tI - tF);
      const total = tI + tF;
      const score = fairness + total * 0.15;
      if (score < bestScore) {
        bestScore = score;
        best = { c, tI, tF };
      }
    });

    if (!best) {
      res.json({ found: false, status: "no_cafe", mid_lat: midLat, mid_lng: midLng });
      return;
    }

    const minutes = (s: number) => Math.max(1, Math.round(s / 60));

    res.json({
      found: true,
      status: "found",
      mid_lat: midLat,
      mid_lng: midLng,
      cafe_name: best.c.name,
      cafe_lat: best.c.lat,
      cafe_lng: best.c.lng,
      cafe_rating: best.c.rating,
      initiator_duration_mins: minutes(best.tI),
      friend_duration_mins: minutes(best.tF),
    });
  }
);

