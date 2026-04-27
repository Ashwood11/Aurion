export interface CountryFeature {
  type: 'Feature';
  properties: {
    NAME?: string;
    ISO_A2?: string;
    ADMIN?: string;
    [key: string]: unknown;
  };
  geometry: unknown;
}

export interface GlobeViewProps {
  onCountrySelect?: (country: CountryFeature | null) => void;
  signals?: unknown[];
  selectedOptions?: string[];
}

export interface WeatherPoint {
  id: string;
  name: string;
  lat: number;
  lng: number;
  temp: number | null;
  color: string;
  size: number;
  layerKind?: 'weather';
}

export interface Airport {
  id: number;
  name: string;
  lat: number;
  lng: number;
  code?: string | null;
  ident?: string | null;
  gps_code?: string | null;
  airport_type?: string | null;
  scheduled_service?: string | null;
  distance_km?: number | null;
}

export interface AirportPoint {
  id: number;
  lat: number;
  lng: number;
  color: string;
  size: number;
  name: string;
  code: string;
  airport_type: string;
  gps_code?: string | null;
  scheduled_service?: string | null;
  distance_km?: number | null;
  layerKind: 'airport';
}

export interface Port {
  id: string;
  name: string;
  alt_name?: string | null;
  unlocode?: string | null;
  country_code?: string | null;
  water_body?: string | null;
  lat: number;
  lng: number;
  port_type?: string | null;
  size_class?: string | null;
  harbor_use?: string | null;
  tidal_range?: number | null;
  channel_depth?: number | null;
  anchorage_depth?: number | null;
  cargo_pier_depth?: number | null;
  max_vessel_length?: number | null;
  max_vessel_beam?: number | null;
  max_vessel_draft?: number | null;
  shelter_afforded?: string | null;
  has_container?: boolean | null;
  has_oil_terminal?: boolean | null;
  has_lng_terminal?: boolean | null;
  significance_score?: number | null;
}

export interface PortPoint {
  id: string;
  lat: number;
  lng: number;
  color: string;
  size: number;
  name: string;
  alt_name?: string | null;
  unlocode?: string | null;
  country_code?: string | null;
  water_body?: string | null;
  port_type?: string | null;
  size_class?: string | null;
  harbor_use?: string | null;
  tidal_range?: number | null;
  channel_depth?: number | null;
  anchorage_depth?: number | null;
  cargo_pier_depth?: number | null;
  max_vessel_length?: number | null;
  max_vessel_beam?: number | null;
  max_vessel_draft?: number | null;
  shelter_afforded?: string | null;
  has_container?: boolean | null;
  has_oil_terminal?: boolean | null;
  has_lng_terminal?: boolean | null;
  significance_score?: number | null;
  layerKind: 'port';
}

export interface MiningAsset {
  id: number;
  name: string;
  entityType: string;
  lat: number;
  lng: number;
  country?: string | null;
  primaryCommodity: string;
  commodityGroup?: string | null;
  allCommodities: string[];
  assetTypeRaw?: string | null;
  confidenceFactor?: string | null;
  importanceScore?: number | null;
}

export interface MiningAssetPoint {
  id: number;
  lat: number;
  lng: number;
  color: string;
  size: number;
  name: string;
  entityType: string;
  country?: string | null;
  primaryCommodity: string;
  commodityGroup?: string | null;
  allCommodities: string[];
  assetTypeRaw?: string | null;
  confidenceFactor?: string | null;
  importanceScore?: number | null;
  layerKind: 'mining';
}

export interface PlaneApiRow {
  id?: string;
  flight_id?: string;
  icao24?: string | null;
  callsign?: string | null;
  aircraft_type?: string | null;
  lat: number;
  lng: number;
  altitude_ft?: number | null;
  ground_speed_kts?: number | null;
  heading_deg?: number | null;
  vertical_rate_fpm?: number | null;
  origin?: string | null;
  destination?: string | null;
  origin_lat?: number | null;
  origin_lng?: number | null;
  destination_lat?: number | null;
  destination_lng?: number | null;
  status?: string | null;
  source?: string | null;
  last_seen_at?: string | null;
}

export interface PlanePoint {
  id: string;
  lat: number;
  lng: number;
  color: string;
  size: number;
  callsign: string;
  aircraft_type: string;
  altitude_ft?: number | null;
  ground_speed_kts?: number | null;
  heading_deg?: number | null;
  origin?: string | null;
  destination?: string | null;
  origin_lat?: number | null;
  origin_lng?: number | null;
  destination_lat?: number | null;
  destination_lng?: number | null;
  status?: string | null;
  bearing_deg?: number | null;
}

export type GlobePoint = WeatherPoint | AirportPoint | PortPoint | MiningAssetPoint;