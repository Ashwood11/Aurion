const API_BASE = "http://127.0.0.1:8000";

export async function fetchGasLatest() {
  const res = await fetch(`${API_BASE}/api/gas/latest`);

  if (!res.ok) {
    throw new Error("Failed to fetch latest gas data");
  }

  return res.json();
}

export async function fetchGasHistory(limit = 200) {
  const res = await fetch(`${API_BASE}/api/gas/history?limit=${limit}`);

  if (!res.ok) {
    throw new Error("Failed to fetch gas history");
  }

  return res.json();
}

export async function fetchGasConsumption(limit = 240) {
  const response = await fetch(
    `${API_BASE}/api/gas/consumption/monthly?limit=${limit}`
  );

  if (!response.ok) {
    throw new Error("Failed to fetch gas consumption");
  }

  return response.json();
}

export async function fetchGasPriceDaily(limit = 365) {
  const response = await fetch(`${API_BASE}/api/gas/price/daily?limit=${limit}`);

  if (!response.ok) {
    throw new Error("Failed to fetch gas price data");
  }

  return response.json();
}

export async function fetchGasPriceLatest() {
  const response = await fetch(`${API_BASE}/api/gas/price/latest`);

  if (!response.ok) {
    throw new Error("Failed to fetch latest gas price");
  }

  return response.json();
}

export async function fetchGasLngMonthly(limit = 240) {
  const response = await fetch(`${API_BASE}/api/gas/lng/monthly?limit=${limit}`);

  if (!response.ok) {
    throw new Error("Failed to fetch LNG data");
  }

  return response.json();
}

export async function fetchGasLngLatest() {
  const response = await fetch(`${API_BASE}/api/gas/lng/latest`);

  if (!response.ok) {
    throw new Error("Failed to fetch latest LNG data");
  }

  return response.json();
}

export async function fetchGasProductionMonthly(limit = 240) {
  const response = await fetch(
    `${API_BASE}/api/gas/production/monthly?limit=${limit}`
  );

  if (!response.ok) {
    throw new Error("Failed to fetch gas production data");
  }

  return response.json();
}

export async function fetchGasProductionLatest() {
  const response = await fetch(`${API_BASE}/api/gas/production/latest`);

  if (!response.ok) {
    throw new Error("Failed to fetch latest gas production");
  }

  return response.json();
}