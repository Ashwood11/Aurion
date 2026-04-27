import type {
  Airport,
  AirportPoint,
  MiningAsset,
  MiningAssetPoint,
  PlaneApiRow,
  PlanePoint,
  Port,
  PortPoint,
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
      color: 'rgba(96,165,250,0.45)',
      size: 0.045,
      layerKind: 'weather' as const,
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
            ? '#1eff00'
            : airportType === 'medium_airport'
              ? 'rgb(1, 163, 9)'
              : '#016906',
        size:
          airportType === 'large_airport'
            ? 0.2
            : airportType === 'medium_airport'
              ? 0.15
              : 0.1,
        name: row.name ?? 'Unknown airport',
        code: row.code ?? row.ident ?? row.gps_code ?? '',
        airport_type: airportType,
        gps_code: row.gps_code ?? null,
        scheduled_service: row.scheduled_service ?? null,
        distance_km: row.distance_km ?? null,
        layerKind: 'airport' as const,
      };
    });
}

function getPortColor(row: Port): string {
  if (row.has_lng_terminal) return '#a855f7';
  if (row.has_oil_terminal) return '#f97316';
  if (row.has_container) return '#22d3ee';

  const harborUse = (row.harbor_use ?? '').toLowerCase();

  if (harborUse.includes('fishing')) return '#22c55e';
  if (harborUse.includes('ferry')) return '#ec4899';
  if (harborUse.includes('military') || harborUse.includes('naval')) return '#ef4444';

  return '#cbd5e1';
}

function getPortSize(sizeClass?: string | null): number {
  const value = (sizeClass ?? '').toLowerCase();

  if (value.includes('very large')) return 0.17;
  if (value.includes('large')) return 0.15;
  if (value.includes('medium')) return 0.11;
  if (value.includes('very small')) return 0.06;
  if (value.includes('small')) return 0.075;

  return 0.075;
}

export function mapPortsToPoints(rows: Port[]): PortPoint[] {
  return (rows ?? [])
    .filter((row) => row.lat != null && row.lng != null)
    .map((row) => ({
      id: row.id,
      lat: Number(row.lat),
      lng: Number(row.lng),
      color: getPortColor(row),
      size: getPortSize(row.size_class),
      name: row.name ?? 'Unknown port',
      alt_name: row.alt_name ?? null,
      unlocode: row.unlocode ?? null,
      country_code: row.country_code ?? null,
      water_body: row.water_body ?? null,
      port_type: row.port_type ?? null,
      size_class: row.size_class ?? null,
      harbor_use: row.harbor_use ?? null,
      tidal_range: row.tidal_range ?? null,
      channel_depth: row.channel_depth ?? null,
      anchorage_depth: row.anchorage_depth ?? null,
      cargo_pier_depth: row.cargo_pier_depth ?? null,
      max_vessel_length: row.max_vessel_length ?? null,
      max_vessel_beam: row.max_vessel_beam ?? null,
      max_vessel_draft: row.max_vessel_draft ?? null,
      shelter_afforded: row.shelter_afforded ?? null,
      has_container: row.has_container ?? null,
      has_oil_terminal: row.has_oil_terminal ?? null,
      has_lng_terminal: row.has_lng_terminal ?? null,
      significance_score: row.significance_score ?? null,
      layerKind: 'port' as const,
    }));
}

function getMiningCommodityColor(commodity: string): string {
  switch ((commodity ?? '').toLowerCase()) {
    case 'copper':
      return '#c46a2f';
    case 'gold':
      return '#ffd700';
    case 'silver':
      return '#d1d5db';
    case 'iron_ore':
      return '#8b0000';
    case 'coal':
      return '#262626';
    case 'lithium':
      return '#7dd3fc';
    case 'nickel':
      return '#94a3b8';
    case 'zinc':
      return '#60a5fa';
    case 'cobalt':
      return '#2563eb';
    case 'uranium':
      return '#84cc16';
    case 'bauxite':
    case 'alumina':
    case 'aluminium':
      return '#f97316';
    case 'rare_earth_elements':
      return '#a855f7';
    case 'diamond':
      return '#e0f2fe';
    case 'phosphate':
    case 'potash':
      return '#22c55e';
    default:
      return '#facc15';
  }
}

function getMiningSize(row: MiningAsset): number {
  const type = (row.entityType ?? '').toLowerCase();

  if (type === 'mine') return 0.11;
  if (type === 'mixed_mining_asset') return 0.13;
  if (type === 'smelter') return 0.1;
  if (type === 'refinery') return 0.1;
  if (type === 'plant') return 0.09;

  return 0.085;
}

export function mapMiningAssetsToPoints(rows: MiningAsset[]): MiningAssetPoint[] {
  return (rows ?? [])
    .filter((row) => row.lat != null && row.lng != null)
    .map((row) => ({
      id: row.id,
      lat: Number(row.lat),
      lng: Number(row.lng),
      color: getMiningCommodityColor(row.primaryCommodity),
      size: getMiningSize(row),
      name: row.name ?? 'Unknown mining asset',
      entityType: row.entityType ?? 'mining_asset',
      country: row.country ?? null,
      primaryCommodity: row.primaryCommodity,
      commodityGroup: row.commodityGroup ?? null,
      allCommodities: row.allCommodities ?? [],
      assetTypeRaw: row.assetTypeRaw ?? null,
      confidenceFactor: row.confidenceFactor ?? null,
      importanceScore: row.importanceScore ?? null,
      layerKind: 'mining' as const,
    }));
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
        destination_lat,
        destination_lng,
        status: row.status ?? null,
        bearing_deg,
      };
    });
}