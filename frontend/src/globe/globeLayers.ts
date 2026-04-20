import type {
  Airport,
  AirportPoint,
  PlaneApiRow,
  PlanePoint,
  WeatherPoint,
} from './types';

function computeBearing(
  startLat: number,
  startLng: number,
  endLat: number,
  endLng: number
): number {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const toDeg = (rad: number) => (rad * 180) / Math.PI;

  const φ1 = toRad(startLat);
  const φ2 = toRad(endLat);
  const λ1 = toRad(startLng);
  const λ2 = toRad(endLng);

  const y = Math.sin(λ2 - λ1) * Math.cos(φ2);
  const x =
    Math.cos(φ1) * Math.sin(φ2) -
    Math.sin(φ1) * Math.cos(φ2) * Math.cos(λ2 - λ1);

  return (toDeg(Math.atan2(y, x)) + 360) % 360;
}

export function mapWeatherResponseToPoints(weatherRows: any[]): WeatherPoint[] {
  return (weatherRows ?? [])
    .filter((row) => row?.lat != null && row?.lng != null)
    .map((row, index) => ({
      id: String(row.id ?? index),
      name: row.name ?? 'Unknown',
      lat: Number(row.lat),
      lng: Number(row.lng),
      temp: row.temp ?? null,
      color: '#59c3ff',
      size: 0.12,
    }));
}

export function mapAirportsToPoints(rows: Airport[]): AirportPoint[] {
  return (rows ?? [])
    .filter((row) => row.lat != null && row.lng != null)
    .map((row) => {
      const airportType = row.airport_type ?? 'small_airport';

      return {
        id: row.id,
        lat: Number(row.lat),
        lng: Number(row.lng),
        color:
          airportType === 'large_airport'
            ? '#ffffff'
            : airportType === 'medium_airport'
              ? '#38bdf8'
              : '#0ea5e9',
        size:
          airportType === 'large_airport'
            ? 0.18
            : airportType === 'medium_airport'
              ? 0.14
              : 0.1,
        name: row.name ?? 'Unknown airport',
        code: row.code ?? row.ident ?? row.gps_code ?? '',
        airport_type: airportType,
        gps_code: row.gps_code ?? null,
        scheduled_service: row.scheduled_service ?? null,
        distance_km: row.distance_km ?? null,
      };
    });
}

export function mapPlanesToPoints(rows: PlaneApiRow[]): PlanePoint[] {
  return (rows ?? [])
    .filter((row) => row.lat != null && row.lng != null)
    .map((row, index) => {
      const lat = Number(row.lat);
      const lng = Number(row.lng);

      const destination_lat =
        row.destination_lat != null ? Number(row.destination_lat) : null;
      const destination_lng =
        row.destination_lng != null ? Number(row.destination_lng) : null;

      const bearing_deg =
        destination_lat != null && destination_lng != null
          ? computeBearing(lat, lng, destination_lat, destination_lng)
          : row.heading_deg ?? null;

      return {
        id: row.id ?? row.flight_id ?? `plane-${index}`,
        lat,
        lng,
        color:
          row.status === 'cargo'
            ? '#f59e0b'
            : row.status === 'private'
              ? '#a78bfa'
              : '#e5e7eb',
        size:
          row.status === 'private'
            ? 0.12
            : row.status === 'cargo'
              ? 0.15
              : 0.16,
        callsign: row.callsign ?? row.flight_id ?? `Plane ${index + 1}`,
        aircraft_type: row.aircraft_type ?? 'Unknown',
        altitude_ft: row.altitude_ft ?? null,
        ground_speed_kts: row.ground_speed_kts ?? null,
        heading_deg: row.heading_deg ?? null,
        origin: row.origin ?? null,
        destination: row.destination ?? null,
        origin_lat: row.origin_lat ?? null,
        origin_lng: row.origin_lng ?? null,
        destination_lat: row.destination_lat ?? null,
        destination_lng: row.destination_lng ?? null,
        status: row.status ?? null,
        bearing_deg,
      };
    });
}