import { useEffect, useState } from 'react';
import type {
  Airport,
  AirportPoint,
  CountryFeature,
  PlaneApiRow,
  PlanePoint,
  WeatherPoint,
} from './types';
import {
  mapAirportsToPoints,
  mapPlanesToPoints,
  mapWeatherResponseToPoints,
} from './globeLayers';

interface UseGlobeDataResult {
  countries: CountryFeature[];
  weatherPoints: WeatherPoint[];
  airportPoints: AirportPoint[];
  planePoints: PlanePoint[];
  loading: boolean;
}

const API_BASE = 'http://127.0.0.1:8000';

function getAirportQueryBySelection(
  altitude: number,
  selectedOptions: string[]
): { airportTypes: string; limit: number } | null {
  const selectedAirportTypes: string[] = [];

  if (selectedOptions.includes('airports-large')) {
    selectedAirportTypes.push('large_airport');
  }

  if (selectedOptions.includes('airports-medium')) {
    selectedAirportTypes.push('medium_airport');
  }

  if (selectedOptions.includes('airports-small')) {
    selectedAirportTypes.push('small_airport');
  }

  if (selectedAirportTypes.length === 0) {
    return null;
  }

  if (altitude > 2.2) {
    return {
      airportTypes: selectedAirportTypes.includes('large_airport')
        ? 'large_airport'
        : selectedAirportTypes.join(','),
      limit: 5000,
    };
  }

  if (altitude > 1.2) {
    const filtered = selectedAirportTypes.filter(
      (t) => t === 'large_airport' || t === 'medium_airport'
    );

    return {
      airportTypes: (filtered.length > 0 ? filtered : selectedAirportTypes).join(','),
      limit: 10000,
    };
  }

  return {
    airportTypes: selectedAirportTypes.join(','),
    limit: 8000,
  };
}

function getPlaneQuery(selectedOptions: string[]): { planeTypes: string; limit: number } | null {
  const selectedPlaneTypes: string[] = [];

  if (selectedOptions.includes('planes-passenger')) {
    selectedPlaneTypes.push('passenger');
  }

  if (selectedOptions.includes('planes-cargo')) {
    selectedPlaneTypes.push('cargo');
  }

  if (selectedOptions.includes('planes-private')) {
    selectedPlaneTypes.push('private');
  }

  if (selectedPlaneTypes.length === 0) {
    return null;
  }

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
  const [planePoints, setPlanePoints] = useState<PlanePoint[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function loadCountries() {
      try {
        const res = await fetch(
          'https://raw.githubusercontent.com/vasturiano/react-globe.gl/master/example/datasets/ne_110m_admin_0_countries.geojson'
        );

        if (!res.ok) {
          throw new Error(`Countries request failed: ${res.status}`);
        }

        const data = await res.json();

        if (!cancelled) {
          setCountries(data?.features ?? []);
        }
      } catch (error) {
        console.error('Failed to load countries:', error);

        if (!cancelled) {
          setCountries([]);
        }
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

        if (!res.ok) {
          throw new Error(`Weather request failed: ${res.status}`);
        }

        const data = await res.json();

        if (!cancelled) {
          setWeatherPoints(mapWeatherResponseToPoints(data?.weather ?? []));
        }
      } catch (error) {
        console.error('Failed to load weather:', error);

        if (!cancelled) {
          setWeatherPoints([]);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
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

        if (!res.ok) {
          throw new Error(`Airports request failed: ${res.status}`);
        }

        const data: Airport[] = await res.json();

        if (!cancelled) {
          setAirportPoints(mapAirportsToPoints(data));
        }
      } catch (error) {
        console.error('Failed to load airports:', error);

        if (!cancelled) {
          setAirportPoints([]);
        }
      }
    }

    loadAirports();

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

        if (!res.ok) {
          throw new Error(`Planes request failed: ${res.status}`);
        }

        const data: PlaneApiRow[] = await res.json();

        if (!cancelled) {
          setPlanePoints(mapPlanesToPoints(data));
        }
      } catch (error) {
        console.error('Failed to load planes:', error);

        if (!cancelled) {
          setPlanePoints([]);
        }
      }
    }

    loadPlanes();

    return () => {
      cancelled = true;
    };
  }, [selectedOptions]);

  return { countries, weatherPoints, airportPoints, planePoints, loading };
}