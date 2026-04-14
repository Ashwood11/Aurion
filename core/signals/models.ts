// core/signals/models.ts
export type SignalType = 'anomaly' | 'baseline' | 'trend' | 'fusion' | 'prediction';
export type Severity = 'low' | 'medium' | 'high' | 'extreme';
export type DataSource = 'open_meteo' | 'noaa' | 'cme' | 'flight_aware' | string;

export interface Signal {
  id?: string;
  module: string;
  signal_type: SignalType;
  name: string;
  value: number;
  baseline?: number;
  deviation?: number;
  severity: Severity;
  timestamp: string;           // ISO string
  expires_at?: string;
  source: DataSource;
  extra_metadata: Record<string, any>;   // ← Changed from metadata
  tags: string[];
  confidence: number;          // 0.0 to 1.0
}

export interface Anomaly extends Signal {
  signal_type: 'anomaly';
  expected_range: [number, number];
}