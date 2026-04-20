import React, { useEffect, useMemo, useRef, useState } from 'react';
import Globe from 'react-globe.gl';
import { useGlobeData } from './useGlobeData';
import type {
  AirportPoint,
  CountryFeature,
  GlobeViewProps,
  PlanePoint,
  WeatherPoint,
} from './types';

function isPointFrontFacing(
  pointLat: number,
  pointLng: number,
  viewLat: number,
  viewLng: number
): boolean {
  const toRad = (deg: number) => (deg * Math.PI) / 180;

  const lat1 = toRad(pointLat);
  const lon1 = toRad(pointLng);
  const lat2 = toRad(viewLat);
  const lon2 = toRad(viewLng);

  const x1 = Math.cos(lat1) * Math.cos(lon1);
  const y1 = Math.cos(lat1) * Math.sin(lon1);
  const z1 = Math.sin(lat1);

  const x2 = Math.cos(lat2) * Math.cos(lon2);
  const y2 = Math.cos(lat2) * Math.sin(lon2);
  const z2 = Math.sin(lat2);

  return x1 * x2 + y1 * y2 + z1 * z2 > 0;
}

function reducePlanesForZoom(planes: PlanePoint[], altitude: number): PlanePoint[] {
  if (planes.length === 0) return planes;

  let cellSize = 0;
  let maxPlanes = Infinity;

  if (altitude >= 1) {
    cellSize = 1;
    maxPlanes = 1500;
  } else if (altitude >= .8) {
    cellSize = 6;
    maxPlanes = 260;
  } else if (altitude >= .6) {
    cellSize = 4;
    maxPlanes = 420;
  } else if (altitude >= .4) {
    cellSize = 2.5;
    maxPlanes = 700;
  } else {
    return planes;
  }

  const buckets = new Map<string, PlanePoint>();

  for (const plane of planes) {
    const latKey = Math.floor((plane.lat + 90) / cellSize);
    const lngKey = Math.floor((plane.lng + 180) / cellSize);
    const key = `${latKey}:${lngKey}`;

    const existing = buckets.get(key);

    if (!existing) {
      buckets.set(key, plane);
      continue;
    }

    const existingSpeed = existing.ground_speed_kts ?? 0;
    const currentSpeed = plane.ground_speed_kts ?? 0;
    const existingAlt = existing.altitude_ft ?? 0;
    const currentAlt = plane.altitude_ft ?? 0;

    if (currentSpeed > existingSpeed || currentAlt > existingAlt) {
      buckets.set(key, plane);
    }
  }

  const reduced = Array.from(buckets.values());

  if (reduced.length <= maxPlanes) {
    return reduced;
  }

  return reduced.slice(0, maxPlanes);
}

const GlobeView: React.FC<GlobeViewProps> = ({
  onCountrySelect,
  selectedOptions = [],
}) => {
  const globeRef = useRef<any>(null);
  const containerRef = useRef<HTMLDivElement | null>(null);

  const [selectedCountry, setSelectedCountry] = useState<CountryFeature | null>(null);
  const [hoverCountry, setHoverCountry] = useState<CountryFeature | null>(null);

  const [hoverAirport, setHoverAirport] = useState<AirportPoint | null>(null);
  const [selectedAirport, setSelectedAirport] = useState<AirportPoint | null>(null);

  const [hoverPlane, setHoverPlane] = useState<PlanePoint | null>(null);
  const [selectedPlane, setSelectedPlane] = useState<PlanePoint | null>(null);

  const [globeAltitude, setGlobeAltitude] = useState(2.8);
  const [viewLat, setViewLat] = useState(0);
  const [viewLng, setViewLng] = useState(0);
  const [viewportTick, setViewportTick] = useState(0);

  const { countries, weatherPoints, airportPoints, planePoints } = useGlobeData(
    selectedOptions,
    globeAltitude
  );

  const showAirportLayers = selectedOptions.some((id) => id.startsWith('airports-'));
  const showPlaneLayers = selectedOptions.some((id) => id.startsWith('planes-'));

  useEffect(() => {
    const interval = setInterval(() => {
      const pov = globeRef.current?.pointOfView?.();

      if (pov) {
        if (typeof pov.altitude === 'number') setGlobeAltitude(pov.altitude);
        if (typeof pov.lat === 'number') setViewLat(pov.lat);
        if (typeof pov.lng === 'number') setViewLng(pov.lng);
      }

      setViewportTick((v) => v + 1);
    }, 250);

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const onResize = () => setViewportTick((v) => v + 1);
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  const visibleAirportPoints = useMemo(() => {
    if (!showAirportLayers || !globeRef.current || !containerRef.current) {
      return [];
    }

    const globe = globeRef.current;
    const rect = containerRef.current.getBoundingClientRect();
    const margin = 20;

    return airportPoints.filter((airport) => {
      if (!isPointFrontFacing(airport.lat, airport.lng, viewLat, viewLng)) {
        return false;
      }

      const coords = globe.getScreenCoords?.(airport.lat, airport.lng, 0);

      if (!coords || typeof coords.x !== 'number' || typeof coords.y !== 'number') {
        return false;
      }

      return (
        coords.x >= rect.left - margin &&
        coords.x <= rect.right + margin &&
        coords.y >= rect.top - margin &&
        coords.y <= rect.bottom + margin
      );
    });
  }, [airportPoints, showAirportLayers, viewLat, viewLng, viewportTick]);

  const visiblePlanePoints = useMemo(() => {
    if (!showPlaneLayers || !globeRef.current || !containerRef.current) {
      return [];
    }

    const globe = globeRef.current;
    const rect = containerRef.current.getBoundingClientRect();
    const margin = 20;

    const frontFacingVisible = planePoints.filter((plane) => {
      if (!isPointFrontFacing(plane.lat, plane.lng, viewLat, viewLng)) {
        return false;
      }

      const coords = globe.getScreenCoords?.(plane.lat, plane.lng, 0);

      if (!coords || typeof coords.x !== 'number' || typeof coords.y !== 'number') {
        return false;
      }

      return (
        coords.x >= rect.left - margin &&
        coords.x <= rect.right + margin &&
        coords.y >= rect.top - margin &&
        coords.y <= rect.bottom + margin
      );
    });

    return reducePlanesForZoom(frontFacingVisible, globeAltitude);
  }, [planePoints, showPlaneLayers, viewLat, viewLng, viewportTick, globeAltitude]);

  const activePlaneForRoute = selectedPlane ?? hoverPlane;

  const planeRouteLineData = useMemo(() => {
    if (!showPlaneLayers || !activePlaneForRoute) {
      return [];
    }

    if (
      activePlaneForRoute.destination_lat == null ||
      activePlaneForRoute.destination_lng == null
    ) {
      return [];
    }

    return [
      {
        startLat: activePlaneForRoute.lat,
        startLng: activePlaneForRoute.lng,
        endLat: activePlaneForRoute.destination_lat,
        endLng: activePlaneForRoute.destination_lng,
        color: activePlaneForRoute.color,
      },
    ];
  }, [showPlaneLayers, activePlaneForRoute]);

  const selectedCountryName = useMemo(
    () => selectedCountry?.properties?.NAME ?? null,
    [selectedCountry]
  );

  return (
    <div
      ref={containerRef}
      style={{ width: '100%', height: '100%', position: 'relative' }}
    >
      <Globe
        ref={globeRef}
        globeImageUrl="https://unpkg.com/three-globe/example/img/earth-dark.jpg"
        backgroundColor="#020202"
        atmosphereColor="#c4c5c5"
        atmosphereAltitude={0.15}
        lineHoverPrecision={0}
        polygonsData={countries.filter((d) => d.properties?.ISO_A2 !== 'AQ')}
        polygonCapColor={(d) =>
          (d as CountryFeature).properties?.NAME === hoverCountry?.properties?.NAME
            ? 'rgba(70,130,180,0.75)'
            : (d as CountryFeature).properties?.NAME === selectedCountry?.properties?.NAME
              ? 'rgba(255,255,255,0.35)'
              : 'rgba(255,255,255,0.05)'
        }
        polygonSideColor={() => 'rgba(255,255,255,0.03)'}
        polygonStrokeColor={() => 'rgba(255,255,255,0.7)'}
        polygonAltitude={(d) =>
          (d as CountryFeature).properties?.NAME === hoverCountry?.properties?.NAME
            ? 0.008
            : (d as CountryFeature).properties?.NAME === selectedCountry?.properties?.NAME
              ? 0.008
              : 0.006
        }
        onPolygonHover={(polygon) =>
          setHoverCountry((polygon as CountryFeature | null) ?? null)
        }
        onPolygonClick={(polygon: object, _event: any, coords: { lat: number; lng: number }) => {
          const country = polygon as CountryFeature;

          setSelectedCountry(country);
          setSelectedAirport(null);
          setSelectedPlane(null);
          onCountrySelect?.(country);

          globeRef.current?.pointOfView(
            { lat: coords.lat, lng: coords.lng, altitude: 1.6 },
            800
          );
        }}
        polygonsTransitionDuration={200}
        pointsData={weatherPoints}
        pointLat="lat"
        pointLng="lng"
        pointColor="color"
        pointRadius="size"
        pointAltitude="size"
        pointLabel={(d) => {
          const point = d as WeatherPoint;
          return `${point.name}<br />${
            point.temp !== null ? `${point.temp.toFixed(1)}°C` : 'N/A'
          }`;
        }}
        htmlElementsData={[...visibleAirportPoints, ...visiblePlanePoints]}
        htmlLat="lat"
        htmlLng="lng"
        htmlAltitude={(d) => ('callsign' in (d as object) ? 0.02 : 0.008)}
        htmlElement={(d) => {
          if ('callsign' in (d as object)) {
            const plane = d as PlanePoint;
            const el = document.createElement('div');

            const rawHeading = Number(plane.heading_deg);
            const heading = Number.isFinite(rawHeading) ? rawHeading : 0;

            el.innerHTML = `
              <div style="
                width: 16px;
                height: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
                transform: rotate(${heading}deg);
                transform-origin: center center;
              ">
                <svg
                  width="16"
                  height="16"
                  viewBox="0 0 64 64"
                  xmlns="http://www.w3.org/2000/svg"
                  style="display:block;"
                >
                  <path
                    d="M32 2
                       L38 22
                       L58 28
                       L58 34
                       L38 36
                       L35 62
                       L29 62
                       L26 36
                       L6 34
                       L6 28
                       L26 22
                       Z"
                    fill="${plane.color}"
                  />
                  <path
                    d="M28 30
                       L10 39
                       L10 44
                       L28 40
                       Z"
                    fill="${plane.color}"
                  />
                  <path
                    d="M36 30
                       L54 39
                       L54 44
                       L36 40
                       Z"
                    fill="${plane.color}"
                  />
                  <path
                    d="M29 8
                       L35 8
                       L34 18
                       L30 18
                       Z"
                    fill="#dbeafe"
                    opacity="0.9"
                  />
                </svg>
              </div>
            `;

            el.style.cursor = 'pointer';
            el.style.pointerEvents = 'auto';
            el.style.userSelect = 'none';
            el.style.lineHeight = '1';

            el.onmouseenter = () => setHoverPlane(plane);
            el.onmouseleave = () =>
              setHoverPlane((current) => (current?.id === plane.id ? null : current));

            el.onclick = () => {
              setSelectedPlane(plane);
              setHoverPlane(plane);
              setSelectedAirport(null);
              setSelectedCountry(null);

              globeRef.current?.pointOfView(
                { lat: plane.lat, lng: plane.lng, altitude: 0.9 },
                800
              );
            };

            return el;
          }

          const airport = d as AirportPoint;
          const el = document.createElement('div');

          const sizePx =
            airport.airport_type === 'large_airport'
              ? 5
              : airport.airport_type === 'medium_airport'
                ? 4
                : 3;

          el.style.width = `${sizePx}px`;
          el.style.height = `${sizePx}px`;
          el.style.borderRadius = '50%';
          el.style.background = airport.color;
          el.style.cursor = 'pointer';
          el.style.pointerEvents = 'auto';

          el.onmouseenter = () => setHoverAirport(airport);
          el.onmouseleave = () =>
            setHoverAirport((current) => (current?.id === airport.id ? null : current));

          el.onclick = () => {
            setSelectedAirport(airport);
            setHoverAirport(airport);
            setSelectedPlane(null);
            setSelectedCountry(null);

            globeRef.current?.pointOfView(
              { lat: airport.lat, lng: airport.lng, altitude: 0.8 },
              800
            );
          };

          return el;
        }}
        arcsData={planeRouteLineData}
        arcStartLat="startLat"
        arcStartLng="startLng"
        arcEndLat="endLat"
        arcEndLng="endLng"
        arcColor="color"
        arcDashLength={1}
        arcDashGap={0}
        arcDashAnimateTime={0}
        arcStroke={0.1}
        arcAltitudeAutoScale={0.1}
      />

      {(hoverAirport || selectedAirport) && showAirportLayers && !selectedPlane && (
        <div
          style={{
            position: 'absolute',
            top: 20,
            right: 20,
            background: 'rgba(15,23,42,0.96)',
            padding: '12px 16px',
            borderRadius: 10,
            border: '1px solid #475569',
            color: '#e0e7ff',
            zIndex: 120,
            minWidth: 220,
          }}
        >
          {(() => {
            const airport = selectedAirport ?? hoverAirport;
            if (!airport) return null;

            return (
              <>
                <div style={{ fontWeight: 700, fontSize: 14, marginBottom: 6 }}>
                  {airport.name}
                </div>
                <div style={{ color: '#93c5fd', fontSize: 12, marginBottom: 4 }}>
                  {airport.code || airport.gps_code || 'No code'}
                </div>
                <div style={{ color: '#94a3b8', fontSize: 12 }}>
                  Type: {airport.airport_type.replace(/_/g, ' ')}
                </div>
                {airport.scheduled_service && (
                  <div style={{ color: '#94a3b8', fontSize: 12, marginTop: 4 }}>
                    Scheduled service: {airport.scheduled_service}
                  </div>
                )}
              </>
            );
          })()}
        </div>
      )}

      {(hoverPlane || selectedPlane) && showPlaneLayers && (
        <div
          style={{
            position: 'absolute',
            top: 20,
            right: 20,
            background: 'rgba(15,23,42,0.96)',
            padding: '12px 16px',
            borderRadius: 10,
            border: '1px solid #475569',
            color: '#e0e7ff',
            zIndex: 120,
            minWidth: 240,
          }}
        >
          {(() => {
            const plane = selectedPlane ?? hoverPlane;
            if (!plane) return null;

            return (
              <>
                <div style={{ fontWeight: 700, fontSize: 14, marginBottom: 6 }}>
                  {plane.callsign}
                </div>
                <div style={{ color: '#cbd5e1', fontSize: 12, marginBottom: 4 }}>
                  {plane.aircraft_type}
                </div>
                <div style={{ color: '#94a3b8', fontSize: 12 }}>
                  Altitude: {plane.altitude_ft ?? 'N/A'} ft
                </div>
                <div style={{ color: '#94a3b8', fontSize: 12 }}>
                  Speed: {plane.ground_speed_kts ?? 'N/A'} kts
                </div>
                <div style={{ color: '#94a3b8', fontSize: 12 }}>
                  Heading: {plane.heading_deg ?? 'N/A'}°
                </div>
                <div style={{ color: '#94a3b8', fontSize: 12 }}>
                  Route: {plane.origin ?? 'UNK'} → {plane.destination ?? 'UNK'}
                </div>
                <div style={{ color: '#94a3b8', fontSize: 12 }}>
                  Type: {plane.status ?? 'unknown'}
                </div>
              </>
            );
          })()}
        </div>
      )}

      {selectedCountryName && !selectedAirport && !selectedPlane && (
        <div
          style={{
            position: 'absolute',
            left: 20,
            bottom: 20,
            padding: '10px 14px',
            background: 'rgba(15,23,42,0.92)',
            border: '1px solid #475569',
            borderRadius: 10,
            color: '#e0e7ff',
            zIndex: 110,
          }}
        >
          {selectedCountryName}
        </div>
      )}

      <button
        onClick={() => {
          setSelectedCountry(null);
          setSelectedAirport(null);
          setSelectedPlane(null);
          setHoverAirport(null);
          setHoverPlane(null);
          onCountrySelect?.(null);

          globeRef.current?.pointOfView(
            { lat: 15, lng: -20, altitude: 2.8 },
            900
          );
        }}
        style={{
          position: 'absolute',
          right: 28,
          bottom: 28,
          padding: '10px 14px',
          borderRadius: 10,
          border: '1px solid rgba(255,255,255,0.14)',
          background: 'rgba(15,23,42,0.92)',
          color: '#e5e7eb',
          cursor: 'pointer',
          zIndex: 120,
        }}
      >
        Reset View
      </button>
    </div>
  );
};

export default GlobeView;