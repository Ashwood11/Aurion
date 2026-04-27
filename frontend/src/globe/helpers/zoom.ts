export type ZoomBand = 'far' | 'medium' | 'close' | 'veryClose';
export type LayerQuality = 'performance' | 'balanced' | 'high';

export interface LayerRenderCaps {
  airports: number;
  ports: number;
  planes: number;
}

export function getZoomBand(altitude: number): ZoomBand {
  if (altitude >= 2.0) return 'far';
  if (altitude >= 1.0) return 'medium';
  if (altitude >= 0.45) return 'close';
  return 'veryClose';
}

export function getLayerRenderCaps(
  zoomBand: ZoomBand,
  quality: LayerQuality = 'balanced'
): LayerRenderCaps {
  const capsByQuality: Record<LayerQuality, Record<ZoomBand, LayerRenderCaps>> = {
    performance: {
      far: { airports: 200, ports: 150, planes: 500 },
      medium: { airports: 600, ports: 350, planes: 800 },
      close: { airports: 1200, ports: 700, planes: 1000 },
      veryClose: { airports: 2500, ports: 1200, planes: 1500 },
    },

    balanced: {
      far: { airports: 400, ports: 250, planes: 900 },
      medium: { airports: 1200, ports: 700, planes: 1200 },
      close: { airports: 2500, ports: 1400, planes: 1500 },
      veryClose: { airports: 5000, ports: 2500, planes: 2500 },
    },

    high: {
      far: { airports: 8000, ports: 5000, planes: 1500 },
      medium: { airports: 25000, ports: 1500, planes: 2500 },
      close: { airports: 60000, ports: 3000, planes: 3500 },
      veryClose: { airports: 10000, ports: 5000, planes: 5000 },
    },
  };

  return capsByQuality[quality][zoomBand];
}

export function getDataAltitudeForZoomBand(zoomBand: ZoomBand): number {
  switch (zoomBand) {
    case 'far':
      return 2.8;
    case 'medium':
      return 1.5;
    case 'close':
      return 0.8;
    case 'veryClose':
      return 0.35;
  }
}

export function getZoomRadiusMultiplier(altitude: number): number {
  if (altitude >= 2.4) return 1.4;
  if (altitude >= 1.6) return 1.1;
  if (altitude >= 1.0) return 0.85;
  if (altitude >= 0.55) return 0.55;
  if (altitude >= 0.4) return 0.4;
  if (altitude >= 0.1) return 0.3;
  if (altitude >= 0.05) return 0.2;
  return 0.1;
}

export function getZoomAltitudeMultiplier(altitude: number): number {
  if (altitude >= 2.4) return 1.4;
  if (altitude >= 1.6) return 1.1;
  if (altitude >= 1.0) return 0.85;
  if (altitude >= 0.55) return 0.55;
  if (altitude >= 0.4) return 0.4;
  if (altitude >= 0.1) return 0.3;
  if (altitude >= 0.05) return 0.2;
  return 0.1;
}