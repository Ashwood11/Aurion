import { useEffect, useMemo, useRef, useState } from 'react';
import Globe from 'react-globe.gl';
import type { GridPoint, StrategicPoint } from '../App';

type GlobeRef = {
  pointOfView: (coords: { lat: number; lng: number; altitude: number }, ms?: number) => void;
};

type RenderPoint = {
  lat: number;
  lng: number;
  radius: number;
  color: string;
  label: string;
  kind: 'grid' | 'strategic';
  original?: StrategicPoint;
};

function getStrategicColor(type: string) {
  switch (type) {
    case 'city':
      return '#4fc3f7';
    case 'port':
      return '#66bb6a';
    case 'gas_hub':
      return '#ff4d4f';
    case 'storage_hub':
      return '#ffa726';
    case 'oil_gas_region':
      return '#ab47bc';
    case 'agriculture_region':
      return '#9ccc65';
    default:
      return '#ffffff';
  }
}

export default function GlobeView() {
  const ref = useRef<GlobeRef | null>(null);
  const container = useRef<HTMLDivElement>(null);

  const [size, setSize] = useState({ width: 800, height: 600 });
  const [grid, setGrid] = useState<GridPoint[]>([]);
  const [points, setPoints] = useState<StrategicPoint[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [showGrid, setShowGrid] = useState(true);
  const [showStrategicPoints, setShowStrategicPoints] = useState(true);
  const [showLabels, setShowLabels] = useState(true);
  const [gridLimit, setGridLimit] = useState(1200);

  const BACKEND_BASE_URL = 'http://127.0.0.1:8000';

  useEffect(() => {
    if (!container.current) return;

    const resize = () =>
      setSize({
        width: container.current!.clientWidth,
        height: container.current!.clientHeight,
      });

    resize();

    const obs = new ResizeObserver(resize);
    obs.observe(container.current);

    return () => obs.disconnect();
  }, []);

  useEffect(() => {
    if (!ref.current) return;
    ref.current.pointOfView({ lat: 20, lng: 10, altitude: 1.8 }, 0);
  }, []);

  useEffect(() => {
    async function loadSpatialData() {
      try {
        setLoading(true);
        setError(null);

        const [gridRes, pointsRes] = await Promise.all([
          fetch(`${BACKEND_BASE_URL}/grid?limit=${gridLimit}`),
          fetch(`${BACKEND_BASE_URL}/points`),
        ]);

        if (!gridRes.ok) {
          throw new Error(`Grid request failed: ${gridRes.status}`);
        }

        if (!pointsRes.ok) {
          throw new Error(`Points request failed: ${pointsRes.status}`);
        }

        const gridData: GridPoint[] = await gridRes.json();
        const pointsData: StrategicPoint[] = await pointsRes.json();

        setGrid(gridData);
        setPoints(pointsData);
      } catch (err) {
        console.error(err);
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    }

    loadSpatialData();
  }, [gridLimit]);

  const gridDots = useMemo<RenderPoint[]>(
    () =>
      grid.map((g) => ({
        lat: g.lat,
        lng: g.lng,
        radius: 0.018,
        color: 'rgba(255,255,255,0.30)',
        label: g.gridCode,
        kind: 'grid',
      })),
    [grid]
  );

  const strategicDots = useMemo<RenderPoint[]>(
    () =>
      points.map((p) => ({
        lat: p.lat,
        lng: p.lng,
        radius: 0.22,
        color: getStrategicColor(p.type),
        label: `${p.name} (${p.type})`,
        kind: 'strategic',
        original: p,
      })),
    [points]
  );

  const visiblePoints = useMemo(() => {
    const result: RenderPoint[] = [];

    if (showGrid) result.push(...gridDots);
    if (showStrategicPoints) result.push(...strategicDots);

    return result;
  }, [showGrid, showStrategicPoints, gridDots, strategicDots]);

  if (error) {
    return (
      <div className="globe-fallback">
        <h3>Globe backend error</h3>
        <p>{error}</p>
        <p>Make sure FastAPI is running at http://127.0.0.1:8000</p>
      </div>
    );
  }

  return (
    <div ref={container} className="globe-wrap">
      <div className="globe-controls">
        <label className="globe-toggle">
          <input
            type="checkbox"
            checked={showGrid}
            onChange={(e) => setShowGrid(e.target.checked)}
          />
          Grid
        </label>

        <label className="globe-toggle">
          <input
            type="checkbox"
            checked={showStrategicPoints}
            onChange={(e) => setShowStrategicPoints(e.target.checked)}
          />
          Strategic Points
        </label>

        <label className="globe-toggle">
          <input
            type="checkbox"
            checked={showLabels}
            onChange={(e) => setShowLabels(e.target.checked)}
          />
          Labels
        </label>

        <label className="globe-toggle">
          Grid Density
          <select
            value={gridLimit}
            onChange={(e) => setGridLimit(Number(e.target.value))}
            style={{ marginLeft: 8 }}
          >
            <option value={400}>Low</option>
            <option value={1200}>Medium</option>
            <option value={2500}>High</option>
          </select>
        </label>
      </div>

      {loading && (
        <div
          style={{
            position: 'absolute',
            top: 56,
            left: 12,
            zIndex: 10,
            padding: '8px 12px',
            borderRadius: 10,
            background: 'rgba(8,12,22,0.82)',
            border: '1px solid #24304a',
            color: '#e8edf7',
            fontSize: 13,
          }}
        >
          Loading grid and strategic points...
        </div>
      )}

      <Globe
        ref={ref as any}
        width={size.width}
        height={size.height}
        globeImageUrl="//unpkg.com/three-globe/example/img/earth-dark.jpg"
        backgroundImageUrl="//unpkg.com/three-globe/example/img/night-sky.png"
        showAtmosphere={true}
        atmosphereAltitude={0.12}
        atmosphereColor="#3a6ff2"
        pointsData={visiblePoints}
        pointLat="lat"
        pointLng="lng"
        pointColor="color"
        pointRadius="radius"
        pointLabel="label"
        pointAltitude={(d: any) => (d.kind === 'strategic' ? 0.03 : 0.008)}
        labelsData={
          showLabels && showStrategicPoints
            ? points.map((p) => ({
                lat: p.lat,
                lng: p.lng,
                text: p.name,
              }))
            : []
        }
        labelLat="lat"
        labelLng="lng"
        labelText="text"
        labelSize={0.9}
        labelDotRadius={0.28}
        labelAltitude={0.035}
        labelColor={() => 'rgba(255,255,255,0.85)'}
        onPointClick={(d: any) => {
          console.log('Clicked globe point:', d);
        }}
      />
    </div>
  );
}