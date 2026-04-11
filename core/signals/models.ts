export interface AurionSignal {
  id: string;
  timestamp: string;
  lat: number;
  lng: number;
  
  signalType: string;      // e.g. "temperature_anomaly", "gas_price_spike"
  strength: number;        // -1.0 to 1.0
  confidence: number;      // 0.0 to 1.0
  
  summary: string;
  sourceModule: string;
  
  metadata?: Record<string, any>;
  tags: string[];
}

export interface FusedSignal extends AurionSignal {
  contributingSignals: string[];
  fusionScore: number;
}