export interface GlobeScreenCoords {
  x: number;
  y: number;
}

export interface GlobeLike {
  getScreenCoords?: (
    lat: number,
    lng: number,
    altitude?: number
  ) => GlobeScreenCoords | null;
}

export interface LatLngPoint {
  lat: number;
  lng: number;
}

export interface FilterVisiblePointsArgs<TPoint extends LatLngPoint> {
  points: TPoint[];
  globe: GlobeLike | null;
  container: HTMLElement | null;
  viewLat: number;
  viewLng: number;
  margin?: number;
}

export function isPointFrontFacing(
  pointLat: number,
  pointLng: number,
  viewLat: number,
  viewLng: number
): boolean {
  const toRad = (deg: number) => (deg * Math.PI) / 180;

  const lat1 = toRad(pointLat);
  const lon1 = toRad(pointLng);
  const lat2 = toRad(viewLat);
  const lon2 = toRad(viewLng);

  const x1 = Math.cos(lat1) * Math.cos(lon1);
  const y1 = Math.cos(lat1) * Math.sin(lon1);
  const z1 = Math.sin(lat1);

  const x2 = Math.cos(lat2) * Math.cos(lon2);
  const y2 = Math.cos(lat2) * Math.sin(lon2);
  const z2 = Math.sin(lat2);

  return x1 * x2 + y1 * y2 + z1 * z2 > 0;
}

export function filterVisibleGlobePoints<TPoint extends LatLngPoint>({
  points,
  globe,
  container,
  viewLat,
  viewLng,
  margin = 20,
}: FilterVisiblePointsArgs<TPoint>): TPoint[] {
  if (!globe || !container) return [];

  const rect = container.getBoundingClientRect();

  return points.filter((point) => {
    if (!isPointFrontFacing(point.lat, point.lng, viewLat, viewLng)) {
      return false;
    }

    const coords = globe.getScreenCoords?.(point.lat, point.lng, 0);

    if (
      !coords ||
      typeof coords.x !== 'number' ||
      typeof coords.y !== 'number'
    ) {
      return false;
    }

    return (
      coords.x >= rect.left - margin &&
      coords.x <= rect.right + margin &&
      coords.y >= rect.top - margin &&
      coords.y <= rect.bottom + margin
    );
  });
}