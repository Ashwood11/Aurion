import { useEffect, useState } from 'react';
import type {
  Airport,
  AirportPoint,
  CountryFeature,
  MiningAsset,
  MiningAssetPoint,
  PlaneApiRow,
  PlanePoint,
  Port,
  PortPoint,
  WeatherPoint,
} from './types';
import {
  mapAirportsToPoints,
  mapMiningAssetsToPoints,
  mapPlanesToPoints,
  mapPortsToPoints,
  mapWeatherResponseToPoints,
} from './globeLayers';

interface UseGlobeDataResult {
  countries: CountryFeature[];
  weatherPoints: WeatherPoint[];
  airportPoints: AirportPoint[];
  portPoints: PortPoint[];
  miningAssetPoints: MiningAssetPoint[];
  planePoints: PlanePoint[];
  loading: boolean;
}

const API_BASE = 'http://127.0.0.1:8000';

function getAirportQueryBySelection(
  altitude: number,
  selectedOptions: string[]
): { airportTypes: string; limit: number } | null {
  const selectedAirportTypes: string[] = [];

  if (selectedOptions.includes('airports-large')) selectedAirportTypes.push('large_airport');
  if (selectedOptions.includes('airports-medium')) selectedAirportTypes.push('medium_airport');
  if (selectedOptions.includes('airports-small')) selectedAirportTypes.push('small_airport');

  if (selectedAirportTypes.length === 0) return null;

  if (altitude > 2.2) {
    return {
      airportTypes: selectedAirportTypes.join(','),
      limit: 5000,
    };
  }

  if (altitude > 1.2) {
    return {
      airportTypes: selectedAirportTypes.join(','),
      limit: 10000,
    };
  }

  return {
    airportTypes: selectedAirportTypes.join(','),
    limit: 15000,
  };
}

function getPortQueryBySelection(
  altitude: number,
  selectedOptions: string[]
): URLSearchParams | null {
  const wantsPorts = selectedOptions.some((id) => id.startsWith('ports-'));
  if (!wantsPorts) return null;

  const params = new URLSearchParams();

  if (altitude > 2.2) params.set('limit', '2000');
  else if (altitude > 1.2) params.set('limit', '5000');
  else params.set('limit', '12000');

  if (selectedOptions.includes('ports-all')) {
    return params;
  }

  const portTypes: string[] = [];
  const harborUses: string[] = [];
  const sizeClasses: string[] = [];

  if (selectedOptions.includes('ports-container')) params.set('has_container', 'true');
  if (selectedOptions.includes('ports-oil')) params.set('has_oil_terminal', 'true');
  if (selectedOptions.includes('ports-lng')) params.set('has_lng_terminal', 'true');

  if (selectedOptions.includes('ports-river')) portTypes.push('River');
  if (selectedOptions.includes('ports-coastal')) portTypes.push('Coastal');
  if (selectedOptions.includes('ports-lake')) portTypes.push('Lake');

  if (selectedOptions.includes('ports-commercial')) harborUses.push('Commercial');
  if (selectedOptions.includes('ports-industrial')) harborUses.push('Industrial');
  if (selectedOptions.includes('ports-fishing')) harborUses.push('Fishing');
  if (selectedOptions.includes('ports-naval')) harborUses.push('Military', 'Naval');

  if (selectedOptions.includes('ports-large')) sizeClasses.push('Large');
  if (selectedOptions.includes('ports-medium')) sizeClasses.push('Medium');
  if (selectedOptions.includes('ports-small')) sizeClasses.push('Small');

  if (portTypes.length > 0) params.set('port_types', portTypes.join(','));
  if (harborUses.length > 0) params.set('harbor_uses', harborUses.join(','));
  if (sizeClasses.length > 0) params.set('size_classes', sizeClasses.join(','));

  return params;
}

function getMiningQueryBySelection(
  altitude: number,
  selectedOptions: string[]
): URLSearchParams | null {
  const wantsMining = selectedOptions.some((id) => id.startsWith('mining-'));
  if (!wantsMining) return null;

  const params = new URLSearchParams();

  if (altitude > 2.2) params.set('limit', '2500');
  else if (altitude > 1.2) params.set('limit', '5000');
  else params.set('limit', '10000');

  const assetTypes: string[] = [];

  if (selectedOptions.includes('mining-mines')) assetTypes.push('mine');
  if (selectedOptions.includes('mining-smelters')) assetTypes.push('smelter');
  if (selectedOptions.includes('mining-refineries')) assetTypes.push('refinery');
  if (selectedOptions.includes('mining-plants')) assetTypes.push('plant');
  if (selectedOptions.includes('mining-mixed')) assetTypes.push('mixed_mining_asset');

  // Your current backend supports one asset_type at a time.
  // If multiple are selected, fetch all and filter later in the frontend.
  if (assetTypes.length === 1 && !selectedOptions.includes('mining-all')) {
    params.set('asset_type', assetTypes[0]);
  }

  const commodities: string[] = [];

  if (selectedOptions.includes('mining-copper')) commodities.push('copper');
  if (selectedOptions.includes('mining-gold')) commodities.push('gold');
  if (selectedOptions.includes('mining-iron')) commodities.push('iron_ore');
  if (selectedOptions.includes('mining-coal')) commodities.push('coal');
  if (selectedOptions.includes('mining-lithium')) commodities.push('lithium');
  if (selectedOptions.includes('mining-nickel')) commodities.push('nickel');
  if (selectedOptions.includes('mining-zinc')) commodities.push('zinc');
  if (selectedOptions.includes('mining-cobalt')) commodities.push('cobalt');
  if (selectedOptions.includes('mining-uranium')) commodities.push('uranium');
  if (selectedOptions.includes('mining-ree')) commodities.push('rare_earth_elements');

  // Your current backend supports one commodity at a time.
  if (commodities.length === 1 && !selectedOptions.includes('mining-all')) {
    params.set('commodity', commodities[0]);
  }

  return params;
}

function filterMiningPointsBySelection(
  points: MiningAssetPoint[],
  selectedOptions: string[]
): MiningAssetPoint[] {
  if (selectedOptions.includes('mining-all')) return points;

  const assetTypes: string[] = [];

  if (selectedOptions.includes('mining-mines')) assetTypes.push('mine');
  if (selectedOptions.includes('mining-smelters')) assetTypes.push('smelter');
  if (selectedOptions.includes('mining-refineries')) assetTypes.push('refinery');
  if (selectedOptions.includes('mining-plants')) assetTypes.push('plant');
  if (selectedOptions.includes('mining-mixed')) assetTypes.push('mixed_mining_asset');

  const commodities: string[] = [];

  if (selectedOptions.includes('mining-copper')) commodities.push('copper');
  if (selectedOptions.includes('mining-gold')) commodities.push('gold');
  if (selectedOptions.includes('mining-iron')) commodities.push('iron_ore');
  if (selectedOptions.includes('mining-coal')) commodities.push('coal');
  if (selectedOptions.includes('mining-lithium')) commodities.push('lithium');
  if (selectedOptions.includes('mining-nickel')) commodities.push('nickel');
  if (selectedOptions.includes('mining-zinc')) commodities.push('zinc');
  if (selectedOptions.includes('mining-cobalt')) commodities.push('cobalt');
  if (selectedOptions.includes('mining-uranium')) commodities.push('uranium');
  if (selectedOptions.includes('mining-ree')) commodities.push('rare_earth_elements');

  return points.filter((point) => {
    const assetTypeOk =
      assetTypes.length === 0 || assetTypes.includes(point.entityType);

    const commodityOk =
      commodities.length === 0 ||
      commodities.some((commodity) => point.allCommodities.includes(commodity));

    return assetTypeOk && commodityOk;
  });
}

function getPlaneQuery(selectedOptions: string[]): { planeTypes: string; limit: number } | null {
  const selectedPlaneTypes: string[] = [];

  if (selectedOptions.includes('planes-passenger')) selectedPlaneTypes.push('passenger');
  if (selectedOptions.includes('planes-cargo')) selectedPlaneTypes.push('cargo');
  if (selectedOptions.includes('planes-private')) selectedPlaneTypes.push('private');

  if (selectedPlaneTypes.length === 0) return null;

  return {
    planeTypes: selectedPlaneTypes.join(','),
    limit: 5000,
  };
}

export function useGlobeData(
  selectedOptions: string[],
  globeAltitude: number
): UseGlobeDataResult {
  const [countries, setCountries] = useState<CountryFeature[]>([]);
  const [weatherPoints, setWeatherPoints] = useState<WeatherPoint[]>([]);
  const [airportPoints, setAirportPoints] = useState<AirportPoint[]>([]);
  const [portPoints, setPortPoints] = useState<PortPoint[]>([]);
  const [miningAssetPoints, setMiningAssetPoints] = useState<MiningAssetPoint[]>([]);
  const [planePoints, setPlanePoints] = useState<PlanePoint[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function loadCountries() {
      try {
        const res = await fetch(
          'https://raw.githubusercontent.com/vasturiano/react-globe.gl/master/example/datasets/ne_110m_admin_0_countries.geojson'
        );
        if (!res.ok) throw new Error(`Countries request failed: ${res.status}`);

        const data = await res.json();
        if (!cancelled) setCountries(data?.features ?? []);
      } catch (error) {
        console.error('Failed to load countries:', error);
        if (!cancelled) setCountries([]);
      }
    }

    loadCountries();
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    let cancelled = false;

    async function loadWeather() {
      try {
        const res = await fetch(`${API_BASE}/globe/data`);
        if (!res.ok) throw new Error(`Weather request failed: ${res.status}`);

        const data = await res.json();
        if (!cancelled) setWeatherPoints(mapWeatherResponseToPoints(data?.weather ?? []));
      } catch (error) {
        console.error('Failed to load weather:', error);
        if (!cancelled) setWeatherPoints([]);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    loadWeather();
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    let cancelled = false;

    async function loadAirports() {
      const query = getAirportQueryBySelection(globeAltitude, selectedOptions);

      if (!query) {
        setAirportPoints([]);
        return;
      }

      try {
        const url =
          `${API_BASE}/api/airports` +
          `?limit=${encodeURIComponent(query.limit)}` +
          `&airport_types=${encodeURIComponent(query.airportTypes)}`;

        const res = await fetch(url);
        if (!res.ok) throw new Error(`Airports request failed: ${res.status}`);

        const data: Airport[] = await res.json();
        if (!cancelled) setAirportPoints(mapAirportsToPoints(data));
      } catch (error) {
        console.error('Failed to load airports:', error);
        if (!cancelled) setAirportPoints([]);
      }
    }

    loadAirports();
    return () => {
      cancelled = true;
    };
  }, [selectedOptions, globeAltitude]);

  useEffect(() => {
    let cancelled = false;

    async function loadPorts() {
      const params = getPortQueryBySelection(globeAltitude, selectedOptions);

      if (!params) {
        setPortPoints([]);
        return;
      }

      try {
        const res = await fetch(`${API_BASE}/api/ports?${params.toString()}`);
        if (!res.ok) throw new Error(`Ports request failed: ${res.status}`);

        const data: Port[] = await res.json();
        if (!cancelled) setPortPoints(mapPortsToPoints(data));
      } catch (error) {
        console.error('Failed to load ports:', error);
        if (!cancelled) setPortPoints([]);
      }
    }

    loadPorts();
    return () => {
      cancelled = true;
    };
  }, [selectedOptions, globeAltitude]);

  useEffect(() => {
    let cancelled = false;

    async function loadMiningAssets() {
      const params = getMiningQueryBySelection(globeAltitude, selectedOptions);

      if (!params) {
        setMiningAssetPoints([]);
        return;
      }

      try {
        const res = await fetch(`${API_BASE}/api/mining/assets?${params.toString()}`);
        if (!res.ok) throw new Error(`Mining assets request failed: ${res.status}`);

        const data: MiningAsset[] = await res.json();
        const mapped = mapMiningAssetsToPoints(data);
        const filtered = filterMiningPointsBySelection(mapped, selectedOptions);

        if (!cancelled) setMiningAssetPoints(filtered);
      } catch (error) {
        console.error('Failed to load mining assets:', error);
        if (!cancelled) setMiningAssetPoints([]);
      }
    }

    loadMiningAssets();
    return () => {
      cancelled = true;
    };
  }, [selectedOptions, globeAltitude]);

  useEffect(() => {
    let cancelled = false;

    async function loadPlanes() {
      const query = getPlaneQuery(selectedOptions);

      if (!query) {
        setPlanePoints([]);
        return;
      }

      try {
        const url =
          `${API_BASE}/api/planes` +
          `?limit=${encodeURIComponent(query.limit)}` +
          `&plane_types=${encodeURIComponent(query.planeTypes)}`;

        const res = await fetch(url);
        if (!res.ok) throw new Error(`Planes request failed: ${res.status}`);

        const data: PlaneApiRow[] = await res.json();
        if (!cancelled) setPlanePoints(mapPlanesToPoints(data));
      } catch (error) {
        console.error('Failed to load planes:', error);
        if (!cancelled) setPlanePoints([]);
      }
    }

    loadPlanes();
    return () => {
      cancelled = true;
    };
  }, [selectedOptions]);

  return {
    countries,
    weatherPoints,
    airportPoints,
    portPoints,
    miningAssetPoints,
    planePoints,
    loading,
  };
}