const API_BASE = 'http://127.0.0.1:8000';

async function getJson<T>(url: string): Promise<T> {
  const res = await fetch(url);

  if (!res.ok) {
    throw new Error(`Request failed ${res.status}: ${url}`);
  }

  return res.json();
}

export async function fetchGlobeData() {
  return getJson<any>(`${API_BASE}/globe/data`);
}

export async function fetchAirports(airportTypes: string, limit: number) {
  return getJson<any[]>(
    `${API_BASE}/api/airports?limit=${encodeURIComponent(limit)}&airport_types=${encodeURIComponent(airportTypes)}`
  );
}

export async function fetchPorts(params: URLSearchParams) {
  return getJson<any[]>(`${API_BASE}/api/ports?${params.toString()}`);
}

export async function fetchMiningAssets(params: URLSearchParams) {
  return getJson<any[]>(`${API_BASE}/api/mining/assets?${params.toString()}`);
}

export async function fetchPlanes(_planeTypes: string, limit: number) {
  return getJson<any[]>(
    `${API_BASE}/api/planes?limit=${encodeURIComponent(limit)}`
  );
}

export async function fetchCountries() {
  return getJson<any>(
    'https://raw.githubusercontent.com/vasturiano/react-globe.gl/master/example/datasets/ne_110m_admin_0_countries.geojson'
  );
}