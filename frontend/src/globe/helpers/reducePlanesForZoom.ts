import type { PlanePoint } from '../types';

export function reducePlanesForZoom(
  planes: PlanePoint[],
  altitude: number
): PlanePoint[] {
  if (planes.length === 0) return planes;

  let cellSize = 0;
  let maxPlanes = Infinity;

  if (altitude >= 1) {
    cellSize = 1;
    maxPlanes = 1500;
  } else if (altitude >= 0.8) {
    cellSize = 6;
    maxPlanes = 260;
  } else if (altitude >= 0.6) {
    cellSize = 4;
    maxPlanes = 420;
  } else if (altitude >= 0.4) {
    cellSize = 2.5;
    maxPlanes = 700;
  } else {
    return planes;
  }

  const buckets = new Map<string, PlanePoint>();

  for (const plane of planes) {
    const latKey = Math.floor((plane.lat + 90) / cellSize);
    const lngKey = Math.floor((plane.lng + 180) / cellSize);
    const key = `${latKey}:${lngKey}`;

    const existing = buckets.get(key);

    if (!existing) {
      buckets.set(key, plane);
      continue;
    }

    const existingScore =
      (existing.ground_speed_kts ?? 0) + (existing.altitude_ft ?? 0);

    const currentScore =
      (plane.ground_speed_kts ?? 0) + (plane.altitude_ft ?? 0);

    if (currentScore > existingScore) {
      buckets.set(key, plane);
    }
  }

  const reduced = Array.from(buckets.values());
  return reduced.length <= maxPlanes ? reduced : reduced.slice(0, maxPlanes);
}