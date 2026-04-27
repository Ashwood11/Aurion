import React from 'react';

interface DebugPanelProps {
  pausePointRendering: boolean;

  weatherFetched: number;

  airportsFetched: number;
  airportsRendered: number;
  airportCap: number;

  portsFetched: number;
  portsRendered: number;
  portCap: number;

  planesFetched: number;
  planesRendered: number;
  planeCap: number;

  totalWebGLPoints: number;

  globeAltitude: number;
  zoomBand: string;
  dataAltitude: number;

  pointScale: number;
  poleScale: number;
}

const DebugPanel: React.FC<DebugPanelProps> = ({
  pausePointRendering,

  weatherFetched,

  airportsFetched,
  airportsRendered,
  airportCap,

  portsFetched,
  portsRendered,
  portCap,

  planesFetched,
  planesRendered,
  planeCap,

  totalWebGLPoints,

  globeAltitude,
  zoomBand,
  dataAltitude,

  pointScale,
  poleScale,
}) => {
  return (
    <div
      style={{
        position: 'absolute',
        left: 140,
        top: 20,
        background: 'rgba(15,23,42,0.92)',
        border: '1px solid #475569',
        borderRadius: 10,
        color: '#e0e7ff',
        zIndex: 120,
        padding: '10px 12px',
        minWidth: 230,
        fontSize: 12,
        lineHeight: 1.45,
      }}
    >
      <div style={{ fontWeight: 700, marginBottom: 6 }}>Render Debug</div>

      <div>Render paused: {pausePointRendering ? 'Yes' : 'No'}</div>
      <div>Zoom band: {zoomBand}</div>
      <div>Data altitude: {dataAltitude.toFixed(2)}</div>

      <div>Weather fetched: {weatherFetched}</div>

      <div>Airports fetched: {airportsFetched}</div>
      <div>Airports rendered: {pausePointRendering ? 0 : airportsRendered}</div>
      <div>Airport cap: {airportCap}</div>

      <div>Ports fetched: {portsFetched}</div>
      <div>Ports rendered: {pausePointRendering ? 0 : portsRendered}</div>
      <div>Port cap: {portCap}</div>

      <div>Planes fetched: {planesFetched}</div>
      <div>Planes rendered: {pausePointRendering ? 0 : planesRendered}</div>
      <div>Plane cap: {planeCap}</div>

      <div>Total WebGL points: {pausePointRendering ? 0 : totalWebGLPoints}</div>
      <div>Camera altitude: {globeAltitude.toFixed(2)}</div>
      <div>Point scale: {pointScale.toFixed(2)}x</div>
      <div>Pole scale: {poleScale.toFixed(2)}x</div>
    </div>
  );
};

export default DebugPanel;