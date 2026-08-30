import { useEffect, useState } from 'react';
import {
  fetchGlobeData,
  fetchAirports,
  fetchPorts,
  fetchMiningAssets,
  fetchCountries,
} from '../services/api';

const API_BASE = 'http://127.0.0.1:8000';

async function getJson<T>(url: string): Promise<T> {
  const res = await fetch(url);

  if (!res.ok) {
    throw new Error(`Request failed ${res.status}: ${url}`);
  }

  return res.json();
}

async function safeFetch<T>(
  name: string,
  fn: () => Promise<T>,
  fallback: T
): Promise<T> {
  try {
    const result = await fn();
    console.log(`Fetched ${name}:`, result);
    return result;
  } catch (err) {
    console.error(`Failed to fetch ${name}:`, err);
    return fallback;
  }
}

async function fetchPlanesFlexible(): Promise<any[]> {
  const urls = [
    `${API_BASE}/api/planes?limit=10000`,
    `${API_BASE}/api/planes`,
    `${API_BASE}/api/flights?limit=10000`,
    `${API_BASE}/api/flights/live?limit=10000`,
    `${API_BASE}/api/aviation/planes?limit=10000`,
    `${API_BASE}/api/aviation/live?limit=10000`,
  ];

  for (const url of urls) {
    try {
      const data = await getJson<any>(url);
      console.log(`Plane endpoint worked: ${url}`, data);

      if (Array.isArray(data)) return data;
      if (Array.isArray(data?.planes)) return data.planes;
      if (Array.isArray(data?.flights)) return data.flights;
      if (Array.isArray(data?.items)) return data.items;
      if (Array.isArray(data?.data)) return data.data;

      console.warn(`Plane endpoint returned unsupported shape: ${url}`, data);
    } catch (err) {
      console.warn(`Plane endpoint failed: ${url}`, err);
    }
  }

  return [];
}

function getAirportColor(typeRaw: string): string {
  const type = typeRaw.toLowerCase();

  if (type === 'large_airport' || type.includes('large')) return '#1eff00';
  if (type === 'medium_airport' || type.includes('medium')) return 'rgb(1, 163, 9)';
  return '#016906';
}

function getAirportSize(typeRaw: string): number {
  const type = typeRaw.toLowerCase();

  if (type === 'large_airport' || type.includes('large')) return 0.2;
  if (type === 'medium_airport' || type.includes('medium')) return 0.15;
  return 0.1;
}

function getPortColor(p: any): string {
  if (p.has_lng_terminal) return '#a855f7';
  if (p.has_oil_terminal) return '#f97316';
  if (p.has_container) return '#22d3ee';

  const harborUse = String(p.harbor_use ?? '').toLowerCase();

  if (harborUse.includes('fishing')) return '#22c55e';
  if (harborUse.includes('ferry')) return '#ec4899';
  if (harborUse.includes('military') || harborUse.includes('naval')) return '#ef4444';

  return '#cbd5e1';
}

function getPortSize(sizeClassRaw: string | null | undefined): number {
  const sizeClass = String(sizeClassRaw ?? '').toLowerCase();

  if (sizeClass.includes('very large')) return 0.17;
  if (sizeClass.includes('large')) return 0.15;
  if (sizeClass.includes('medium')) return 0.11;
  if (sizeClass.includes('very small')) return 0.06;
  if (sizeClass.includes('small')) return 0.075;

  return 0.075;
}

function getMiningColor(commodityRaw: string | null | undefined): string {
  const commodity = String(commodityRaw ?? '').toLowerCase();

  if (commodity.includes('copper')) return '#c46a2f';
  if (commodity.includes('gold')) return '#ffd700';
  if (commodity.includes('silver')) return '#d1d5db';
  if (commodity.includes('iron')) return '#8b0000';
  if (commodity.includes('coal')) return '#262626';
  if (commodity.includes('lithium')) return '#7dd3fc';
  if (commodity.includes('nickel')) return '#94a3b8';
  if (commodity.includes('zinc')) return '#60a5fa';
  if (commodity.includes('cobalt')) return '#2563eb';
  if (commodity.includes('uranium')) return '#84cc16';
  if (commodity.includes('bauxite')) return '#f97316';
  if (commodity.includes('alumina')) return '#f97316';
  if (commodity.includes('aluminium')) return '#f97316';
  if (commodity.includes('rare')) return '#a855f7';
  if (commodity.includes('diamond')) return '#e0f2fe';
  if (commodity.includes('phosphate')) return '#22c55e';
  if (commodity.includes('potash')) return '#22c55e';

  return '#facc15';
}

function getMiningSize(entityTypeRaw: string | null | undefined): number {
  const type = String(entityTypeRaw ?? '').toLowerCase();

  if (type === 'mine') return 0.11;
  if (type === 'mixed_mining_asset') return 0.13;
  if (type === 'smelter') return 0.1;
  if (type === 'refinery') return 0.1;
  if (type === 'plant') return 0.09;

  return 0.085;
}

function getPlaneColor(statusRaw: string | null | undefined): string {
  const status = String(statusRaw ?? '').toLowerCase();

  if (status.includes('cargo')) return '#f59e0b';
  if (status.includes('private')) return '#a78bfa';

  return '#e5e7eb';
}

function getPlaneSize(statusRaw: string | null | undefined): number {
  const status = String(statusRaw ?? '').toLowerCase();

  if (status.includes('private')) return 0.12;
  if (status.includes('cargo')) return 0.15;

  return 0.16;
}

function normaliseCommodityList(value: any): string[] {
  if (Array.isArray(value)) return value;

  if (typeof value === 'string') {
    return value
      .split(/[;,]/)
      .map((item) => item.trim())
      .filter(Boolean);
  }

  return [];
}

export function useGlobeData(_selectedOptions?: string[], _dataAltitude?: number) {
  const [countries, setCountries] = useState<any[]>([]);
  const [weather, setWeather] = useState<any[]>([]);
  const [airports, setAirports] = useState<any[]>([]);
  const [ports, setPorts] = useState<any[]>([]);
  const [mining, setMining] = useState<any[]>([]);
  const [planes, setPlanes] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);

      const portParams = new URLSearchParams({ limit: '5000' });
      const miningParams = new URLSearchParams({ limit: '5000' });

      const globeData = await safeFetch<any>('globeData', fetchGlobeData, {
        weather: [],
      });

      const airportData = await safeFetch<any[]>(
        'airports',
        () => fetchAirports('large_airport,medium_airport,small_airport', 10000),
        []
      );

      const portData = await safeFetch<any[]>(
        'ports',
        () => fetchPorts(portParams),
        []
      );

      const miningData = await safeFetch<any[]>(
        'mining',
        () => fetchMiningAssets(miningParams),
        []
      );

      const planeData = await safeFetch<any[]>(
        'planes',
        fetchPlanesFlexible,
        []
      );

      const countryData = await safeFetch<any>('countries', fetchCountries, {
        features: [],
      });

      if (cancelled) return;

      const mappedCountries = countryData?.features || countryData || [];

      const mappedWeather = (globeData?.weather || [])
        .map((w: any, index: number) => ({
          id: `weather-${index}`,
          lat: Number(w.lat ?? w.latitude),
          lng: Number(w.lng ?? w.longitude),
          name: w.name ?? 'Weather',
          temp: w.temp ?? null,
          wind: w.wind ?? null,
          precip: w.precip ?? null,
          color: 'rgba(96,165,250,0.45)',
          size: 0.045,
          layerKind: 'weather',
        }))
        .filter((w: any) => Number.isFinite(w.lat) && Number.isFinite(w.lng));

      const mappedAirports = (airportData || [])
        .map((a: any, index: number) => {
          const airportType = a.airport_type ?? a.type ?? 'small_airport';

          return {
            ...a,
            id: String(a.id ?? a.airport_id ?? a.code ?? `airport-${index}`),
            lat: Number(a.lat ?? a.latitude),
            lng: Number(a.lng ?? a.longitude),
            color: a.color ?? getAirportColor(airportType),
            size: Number(a.size ?? getAirportSize(airportType)),
            name: a.name ?? 'Unknown airport',
            code: a.code ?? a.ident ?? a.gps_code ?? a.iata_code ?? a.icao_code ?? '',
            airport_type: airportType,
            gps_code: a.gps_code ?? null,
            scheduled_service: a.scheduled_service ?? null,
            distance_km: a.distance_km ?? null,
            layerKind: 'airport',
            importanceScore: Number(a.importanceScore ?? a.importance_score ?? 0),
          };
        })
        .filter((a: any) => Number.isFinite(a.lat) && Number.isFinite(a.lng));

      const mappedPorts = (portData || [])
        .map((p: any, index: number) => {
          const sizeClass = p.size_class ?? p.sizeClass ?? null;

          return {
            ...p,
            id: String(p.id ?? p.port_id ?? p.unlocode ?? `port-${index}`),
            lat: Number(p.lat ?? p.latitude),
            lng: Number(p.lng ?? p.longitude),
            color: p.color ?? getPortColor(p),
            size: Number(p.size ?? getPortSize(sizeClass)),
            name: p.name ?? 'Unknown port',
            alt_name: p.alt_name ?? null,
            unlocode: p.unlocode ?? p.un_locode ?? null,
            country_code: p.country_code ?? null,
            water_body: p.water_body ?? null,
            port_type: p.port_type ?? p.type ?? null,
            size_class: sizeClass,
            harbor_use: p.harbor_use ?? p.harborUse ?? null,
            tidal_range: p.tidal_range ?? null,
            channel_depth: p.channel_depth ?? null,
            anchorage_depth: p.anchorage_depth ?? null,
            cargo_pier_depth: p.cargo_pier_depth ?? null,
            max_vessel_length: p.max_vessel_length ?? null,
            max_vessel_beam: p.max_vessel_beam ?? null,
            max_vessel_draft: p.max_vessel_draft ?? null,
            shelter_afforded: p.shelter_afforded ?? null,
            has_container: Boolean(p.has_container ?? p.hasContainer ?? false),
            has_oil_terminal: Boolean(p.has_oil_terminal ?? p.hasOilTerminal ?? false),
            has_lng_terminal: Boolean(p.has_lng_terminal ?? p.hasLngTerminal ?? false),
            significance_score: p.significance_score ?? null,
            layerKind: 'port',
            importanceScore: Number(p.importanceScore ?? p.importance_score ?? p.significance_score ?? 0),
          };
        })
        .filter((p: any) => Number.isFinite(p.lat) && Number.isFinite(p.lng));

      const mappedMining = (miningData || [])
        .map((m: any, index: number) => {
          const primaryCommodity =
            m.primaryCommodity ?? m.primary_commodity ?? 'Unknown';

          const entityType =
            m.entityType ?? m.entity_type ?? 'mine';

          return {
            ...m,
            id: String(m.id ?? m.mine_id ?? m.icmm_id ?? `mining-${index}`),
            lat: Number(m.lat ?? m.latitude),
            lng: Number(m.lng ?? m.longitude),
            color: m.color ?? getMiningColor(primaryCommodity),
            size: Number(m.size ?? getMiningSize(entityType)),
            name: m.name ?? m.mine_name ?? 'Unknown mining asset',
            entityType,
            country: m.country ?? m.country_or_region ?? null,
            primaryCommodity,
            commodityGroup: m.commodityGroup ?? m.commodity_group ?? null,
            allCommodities: normaliseCommodityList(
              m.allCommodities ?? m.all_commodities ?? m.commodities
            ),
            assetTypeRaw: m.assetTypeRaw ?? m.asset_type ?? null,
            confidenceFactor: m.confidenceFactor ?? m.confidence_factor ?? null,
            importanceScore: Number(m.importanceScore ?? m.importance_score ?? 0),
            layerKind: 'mining',
          };
        })
        .filter((m: any) => Number.isFinite(m.lat) && Number.isFinite(m.lng));

      const mappedPlanes = (planeData || [])
        .map((p: any, index: number) => {
          const lat = Number(p.lat ?? p.latitude);
          const lng = Number(p.lng ?? p.longitude);

          const status =
            p.status ??
            p.flight_type ??
            p.plane_type ??
            p.type ??
            'passenger';

          const destinationLat =
            p.destination_lat != null
              ? Number(p.destination_lat)
              : p.destinationLat != null
                ? Number(p.destinationLat)
                : null;

          const destinationLng =
            p.destination_lng != null
              ? Number(p.destination_lng)
              : p.destinationLng != null
                ? Number(p.destinationLng)
                : null;

          return {
            ...p,
            id: String(p.id ?? p.flight_id ?? p.icao24 ?? p.callsign ?? `plane-${index}`),
            lat,
            lng,
            color: p.color ?? getPlaneColor(status),
            size: Number(p.size ?? getPlaneSize(status)),
            callsign: p.callsign ?? p.flight_id ?? `Plane ${index + 1}`,
            aircraft_type: p.aircraft_type ?? p.aircraftType ?? 'Unknown',
            altitude_ft:
              p.altitude_ft != null
                ? Number(p.altitude_ft)
                : p.altitude != null
                  ? Number(p.altitude)
                  : null,
            ground_speed_kts:
              p.ground_speed_kts != null
                ? Number(p.ground_speed_kts)
                : p.velocity != null
                  ? Number(p.velocity)
                  : p.speed != null
                    ? Number(p.speed)
                    : null,
            heading_deg:
              p.heading_deg != null
                ? Number(p.heading_deg)
                : p.heading != null
                  ? Number(p.heading)
                  : null,
            bearing_deg:
              p.bearing_deg != null
                ? Number(p.bearing_deg)
                : p.heading_deg != null
                  ? Number(p.heading_deg)
                  : p.heading != null
                    ? Number(p.heading)
                    : null,
            origin: p.origin ?? p.origin_airport ?? null,
            destination: p.destination ?? p.destination_airport ?? null,
            origin_lat: p.origin_lat ?? null,
            origin_lng: p.origin_lng ?? null,
            destination_lat: destinationLat,
            destination_lng: destinationLng,
            status,
            source: p.source ?? null,
            last_seen_at: p.last_seen_at ?? p.updated_at ?? null,
            layerKind: 'plane',
            importanceScore: Number(p.importanceScore ?? p.importance_score ?? 0),
          };
        })
        .filter((p: any) => Number.isFinite(p.lat) && Number.isFinite(p.lng));

      console.log('MAPPED DATA CHECK', {
        countries: mappedCountries.length,
        weather: mappedWeather.length,
        airports: mappedAirports.length,
        ports: mappedPorts.length,
        mining: mappedMining.length,
        planesRaw: planeData.length,
        planesMapped: mappedPlanes.length,
        samplePlaneRaw: planeData[0],
        samplePlaneMapped: mappedPlanes[0],
      });

      setCountries(mappedCountries);
      setWeather(mappedWeather);
      setAirports(mappedAirports);
      setPorts(mappedPorts);
      setMining(mappedMining);
      setPlanes(mappedPlanes);
      setLoading(false);
    }

    load();

    return () => {
      cancelled = true;
    };
  }, []);

  return {
    loading,
    countries,
    weatherPoints: weather,
    airportPoints: airports,
    portPoints: ports,
    miningAssetPoints: mining,
    planePoints: planes,
  };
}