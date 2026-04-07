export type WeatherGasSignalType =
  | 'temp_anomaly'
  | 'heating_demand'
  | 'wind_anomaly'
  | 'gas_risk';

export type RegionSignal = {
  signalType: WeatherGasSignalType;
  strength: number;
  confidence: number;
  summary: string;
};

export type RegionState = {
  id: string;
  name: string;
  lat: number;
  lng: number;

  currentTempC: number;
  tempAnomalyC: number;
  hdd: number;
  windAnomalyPct: number;

  gasScore: number;
  confidence: number;
  explanation: string;
  timestamp: string;

  signals: RegionSignal[];
};