import React, { useEffect, useMemo, useRef, useState } from 'react';
import Globe from 'react-globe.gl';
import { useGlobeData } from './useGlobeData';
import { useVisibleLayers } from './layers/useVisibleLayers';

import {
  getDataAltitudeForZoomBand,
  getLayerRenderCaps,
  getZoomAltitudeMultiplier,
  getZoomBand,
  getZoomRadiusMultiplier,
  type LayerQuality,
} from './helpers/zoom';

import { createPlaneElement } from './helpers/createPlaneElement';

import DebugPanel from './panels/DebugPanel';
import AirportInfoPanel from './panels/AirportInfoPanel';
import PortInfoPanel from './panels/PortInfoPanel';
import PlaneInfoPanel from './panels/PlaneInfoPanel';
import GlobeSettingsPanel from './panels/GlobeSettingsPanel';

import {
  matchesAirportFilter,
  matchesPortFilter,
  matchesMiningFilter,
} from './layers/layerFilters';

import type {
  AirportPoint,
  CountryFeature,
  GlobePoint,
  GlobeViewProps,
  MiningAssetPoint,
  PlanePoint,
  PortPoint,
} from './types';

interface GlobeViewSettingsProps {
  showSettings?: boolean;
  setShowSettings?: (value: boolean) => void;
}

const GlobeView: React.FC<GlobeViewProps & GlobeViewSettingsProps> = ({
  onCountrySelect,
  selectedOptions = [],
  showSettings = false,
  setShowSettings,
}) => {
  const globeRef = useRef<any>(null);
  const containerRef = useRef<HTMLDivElement | null>(null);

  const [selectedCountry, setSelectedCountry] = useState<CountryFeature | null>(null);
  const [hoverCountry, setHoverCountry] = useState<CountryFeature | null>(null);

  const [hoverAirport, setHoverAirport] = useState<AirportPoint | null>(null);
  const [selectedAirport, setSelectedAirport] = useState<AirportPoint | null>(null);

  const [hoverPort, setHoverPort] = useState<PortPoint | null>(null);
  const [selectedPort, setSelectedPort] = useState<PortPoint | null>(null);

  const [hoverMiningAsset, setHoverMiningAsset] = useState<MiningAssetPoint | null>(null);
  const [selectedMiningAsset, setSelectedMiningAsset] = useState<MiningAssetPoint | null>(null);

  const [hoverPlane, setHoverPlane] = useState<PlanePoint | null>(null);
  const [selectedPlane, setSelectedPlane] = useState<PlanePoint | null>(null);

  const [globeAltitude, setGlobeAltitude] = useState(2.8);
  const [viewLat, setViewLat] = useState(0);
  const [viewLng, setViewLng] = useState(0);
  const [viewportTick, setViewportTick] = useState(0);

  const [pausePointRendering, setPausePointRendering] = useState(false);
  const [showDebug, setShowDebug] = useState(true);
  const [layerQuality, setLayerQuality] = useState<LayerQuality>('balanced');

  const renderResumeTimeoutRef = useRef<number | null>(null);
  const lastCameraRef = useRef({ altitude: 2.8, lat: 0, lng: 0 });

  const zoomBand = useMemo(() => getZoomBand(globeAltitude), [globeAltitude]);
  const renderCaps = useMemo(
    () => getLayerRenderCaps(zoomBand, layerQuality),
    [zoomBand, layerQuality]
  );
  const dataAltitude = useMemo(() => getDataAltitudeForZoomBand(zoomBand), [zoomBand]);

  const {
    countries,
    weatherPoints,
    airportPoints,
    portPoints,
    miningAssetPoints,
    planePoints,
  } = useGlobeData(selectedOptions, dataAltitude);

  const showAirportLayers = selectedOptions.some((id) => id.startsWith('airports-'));
  const showPortLayers = selectedOptions.some((id) => id.startsWith('ports-'));
  const showMiningLayers = selectedOptions.some((id) => id.startsWith('mining-'));
  const showPlaneLayers = selectedOptions.some((id) => id.startsWith('planes-'));

  useEffect(() => {
    const interval = window.setInterval(() => {
      const pov = globeRef.current?.pointOfView?.();
      if (!pov) return;

      const nextAltitude =
        typeof pov.altitude === 'number'
          ? pov.altitude
          : lastCameraRef.current.altitude;

      const nextLat =
        typeof pov.lat === 'number'
          ? pov.lat
          : lastCameraRef.current.lat;

      const nextLng =
        typeof pov.lng === 'number'
          ? pov.lng
          : lastCameraRef.current.lng;

      const last = lastCameraRef.current;
      const zoomChanged = Math.abs(nextAltitude - last.altitude) > 0.01;
      const cameraMoved =
        Math.abs(nextLat - last.lat) > 0.02 ||
        Math.abs(nextLng - last.lng) > 0.02;

      if (zoomChanged) {
        setPausePointRendering(true);

        if (renderResumeTimeoutRef.current) {
          window.clearTimeout(renderResumeTimeoutRef.current);
        }

        renderResumeTimeoutRef.current = window.setTimeout(() => {
          setPausePointRendering(false);
          setViewportTick((v) => v + 1);
        }, 180);
      }

      if (zoomChanged || cameraMoved) {
        setGlobeAltitude(nextAltitude);
        setViewLat(nextLat);
        setViewLng(nextLng);
        setViewportTick((v) => v + 1);
      }

      lastCameraRef.current = {
        altitude: nextAltitude,
        lat: nextLat,
        lng: nextLng,
      };
    }, 120);

    return () => {
      window.clearInterval(interval);

      if (renderResumeTimeoutRef.current) {
        window.clearTimeout(renderResumeTimeoutRef.current);
      }
    };
  }, []);

  useEffect(() => {
    const onResize = () => setViewportTick((v) => v + 1);
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  const filteredAirportPoints = useMemo(() => {
    return airportPoints.filter((point) =>
      matchesAirportFilter(point, selectedOptions)
    );
  }, [airportPoints, selectedOptions]);

  const filteredPortPoints = useMemo(() => {
    return portPoints.filter((point) =>
      matchesPortFilter(point, selectedOptions)
    );
  }, [portPoints, selectedOptions]);

  const filteredMiningAssetPoints = useMemo(() => {
    return miningAssetPoints.filter((point) =>
      matchesMiningFilter(point, selectedOptions)
    );
  }, [miningAssetPoints, selectedOptions]);

  const {
    visibleAirports: visibleAirportPoints,
    visiblePorts: visiblePortPoints,
    visibleMining: visibleMiningAssetPoints,
    visiblePlanes: visiblePlanePoints,
  } = useVisibleLayers({
    globeRef,
    containerRef: containerRef.current,
    viewLat,
    viewLng,
    globeAltitude,
    viewportTick,
    renderCaps,
    airports: showAirportLayers ? filteredAirportPoints : [],
    ports: showPortLayers ? filteredPortPoints : [],
    mining: showMiningLayers ? filteredMiningAssetPoints : [],
    planes: showPlaneLayers ? planePoints : [],
  });

  const selectedHighlights = useMemo<GlobePoint[]>(() => {
    const highlights: GlobePoint[] = [];

    if (selectedAirport) {
      highlights.push({
        ...selectedAirport,
        color: '#ffffff',
        size: selectedAirport.size * 2.1,
        layerKind: 'airport',
      });
    }

    if (selectedPort) {
      highlights.push({
        ...selectedPort,
        color: '#ffffff',
        size: selectedPort.size * 2,
        layerKind: 'port',
      });
    }

    if (selectedMiningAsset) {
      highlights.push({
        ...selectedMiningAsset,
        color: '#ffffff',
        size: selectedMiningAsset.size * 2.1,
        layerKind: 'mining',
      });
    }

    return highlights;
  }, [selectedAirport, selectedPort, selectedMiningAsset]);

  const allVisiblePointLayers = useMemo<GlobePoint[]>(() => {
    return [
      ...weatherPoints,
      ...visiblePortPoints,
      ...visibleAirportPoints,
      ...visibleMiningAssetPoints,
      ...selectedHighlights,
    ];
  }, [
    weatherPoints,
    visiblePortPoints,
    visibleAirportPoints,
    visibleMiningAssetPoints,
    selectedHighlights,
  ]);

  const activePlaneForRoute = selectedPlane ?? hoverPlane;

  const planeRouteLineData = useMemo(() => {
    if (!showPlaneLayers || !activePlaneForRoute) return [];

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

  const selectedCountryName = selectedCountry?.properties?.NAME ?? null;

  const activeAirport = selectedAirport ?? hoverAirport;
  const activePort = selectedPort ?? hoverPort;
  const activeMiningAsset = selectedMiningAsset ?? hoverMiningAsset;
  const activePlane = selectedPlane ?? hoverPlane;

  return (
    <div ref={containerRef} style={{ width: '100%', height: '100%', position: 'relative' }}>
      <Globe
        ref={globeRef}
        globeImageUrl="https://unpkg.com/three-globe/example/img/earth-dark.jpg"
        backgroundColor="#020202"
        atmosphereColor="#c4c5c5"
        atmosphereAltitude={0.15}
        lineHoverPrecision={0}
        pointsTransitionDuration={0}
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
          (d as CountryFeature).properties?.NAME === hoverCountry?.properties?.NAME ||
          (d as CountryFeature).properties?.NAME === selectedCountry?.properties?.NAME
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
          setSelectedPort(null);
          setSelectedMiningAsset(null);
          setSelectedPlane(null);
          onCountrySelect?.(country);

          globeRef.current?.pointOfView(
            { lat: coords.lat, lng: coords.lng, altitude: 1.6 },
            800
          );
        }}
        polygonsTransitionDuration={200}
        pointsData={pausePointRendering ? [] : allVisiblePointLayers}
        pointLat="lat"
        pointLng="lng"
        pointColor="color"
        pointRadius={(d: object) => {
          const point = d as GlobePoint;
          const zoomMultiplier = getZoomRadiusMultiplier(globeAltitude);

          if (point.layerKind === 'airport') return point.size * zoomMultiplier * 1.12;
          if (point.layerKind === 'port') return point.size * zoomMultiplier;
          if (point.layerKind === 'mining') return point.size * zoomMultiplier * 0.95;
          if (point.layerKind === 'weather') return point.size * Math.min(zoomMultiplier, 1.2);

          return point.size * zoomMultiplier;
        }}
        pointAltitude={(d: object) => {
          const point = d as GlobePoint;
          const altitudeMultiplier = getZoomAltitudeMultiplier(globeAltitude);

          if (point.layerKind === 'airport') return 0.012 * altitudeMultiplier;
          if (point.layerKind === 'port') return 0.007 * altitudeMultiplier;
          if (point.layerKind === 'mining') return 0.01 * altitudeMultiplier;
          if (point.layerKind === 'weather') return 0.002 * altitudeMultiplier;

          return 0.003 * altitudeMultiplier;
        }}
        onPointHover={(d: object | null) => {
          if (!d) {
            setHoverAirport(null);
            setHoverPort(null);
            setHoverMiningAsset(null);
            return;
          }

          const point = d as GlobePoint;

          if (point.layerKind === 'airport') {
            setHoverAirport(point as AirportPoint);
            setHoverPort(null);
            setHoverMiningAsset(null);
          } else if (point.layerKind === 'port') {
            setHoverPort(point as PortPoint);
            setHoverAirport(null);
            setHoverMiningAsset(null);
          } else if (point.layerKind === 'mining') {
            setHoverMiningAsset(point as MiningAssetPoint);
            setHoverAirport(null);
            setHoverPort(null);
          } else {
            setHoverAirport(null);
            setHoverPort(null);
            setHoverMiningAsset(null);
          }
        }}
        onPointClick={(d: object) => {
          const point = d as GlobePoint;

          if (point.layerKind === 'airport') {
            const airport = point as AirportPoint;

            setSelectedAirport(airport);
            setHoverAirport(airport);
            setSelectedPort(null);
            setSelectedMiningAsset(null);
            setSelectedPlane(null);
            setSelectedCountry(null);

            globeRef.current?.pointOfView(
              { lat: airport.lat, lng: airport.lng, altitude: 0.8 },
              800
            );
            return;
          }

          if (point.layerKind === 'port') {
            const port = point as PortPoint;

            setSelectedPort(port);
            setHoverPort(port);
            setSelectedAirport(null);
            setSelectedMiningAsset(null);
            setSelectedPlane(null);
            setSelectedCountry(null);

            globeRef.current?.pointOfView(
              { lat: port.lat, lng: port.lng, altitude: 0.9 },
              800
            );
            return;
          }

          if (point.layerKind === 'mining') {
            const asset = point as MiningAssetPoint;

            setSelectedMiningAsset(asset);
            setHoverMiningAsset(asset);
            setSelectedAirport(null);
            setSelectedPort(null);
            setSelectedPlane(null);
            setSelectedCountry(null);

            globeRef.current?.pointOfView(
              { lat: asset.lat, lng: asset.lng, altitude: 0.85 },
              800
            );
          }
        }}
        pointLabel={(d: object) => {
          const point = d as GlobePoint;

          if (point.layerKind === 'airport') {
            const airport = point as AirportPoint;
            return `<strong>${airport.name}</strong><br/>${airport.code || 'No code'}<br/>${airport.airport_type}`;
          }

          if (point.layerKind === 'port') {
            const port = point as PortPoint;
            return `<strong>${port.name}</strong><br/>${port.unlocode ?? 'No UN/LOCODE'}<br/>${port.harbor_use ?? 'Unknown use'}`;
          }

          if (point.layerKind === 'mining') {
            const asset = point as MiningAssetPoint;
            return `<strong>${asset.name}</strong><br/>${asset.assetTypeRaw ?? asset.entityType}<br/>${asset.primaryCommodity}`;
          }

          return '';
        }}
        htmlElementsData={pausePointRendering ? [] : visiblePlanePoints}
        htmlLat="lat"
        htmlLng="lng"
        htmlAltitude={() => 0.02}
        htmlElement={(d) => {
          const plane = d as PlanePoint;

          return createPlaneElement({
            plane,
            onHover: setHoverPlane,
            onLeave: (leavingPlane) =>
              setHoverPlane((current) =>
                current?.id === leavingPlane.id ? null : current
              ),
            onClick: (clickedPlane) => {
              setSelectedPlane(clickedPlane);
              setHoverPlane(clickedPlane);
              setSelectedAirport(null);
              setSelectedPort(null);
              setSelectedMiningAsset(null);
              setSelectedCountry(null);

              globeRef.current?.pointOfView(
                { lat: clickedPlane.lat, lng: clickedPlane.lng, altitude: 0.9 },
                800
              );
            },
          });
        }}
        arcsData={pausePointRendering ? [] : planeRouteLineData}
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

      {showDebug && (
        <DebugPanel
          pausePointRendering={pausePointRendering}
          weatherFetched={weatherPoints.length}
          airportsFetched={airportPoints.length}
          airportsRendered={visibleAirportPoints.length}
          airportCap={renderCaps.airports}
          portsFetched={portPoints.length}
          portsRendered={visiblePortPoints.length}
          portCap={renderCaps.ports}
          planesFetched={planePoints.length}
          planesRendered={visiblePlanePoints.length}
          planeCap={renderCaps.planes}
          totalWebGLPoints={allVisiblePointLayers.length}
          globeAltitude={globeAltitude}
          zoomBand={zoomBand}
          dataAltitude={dataAltitude}
          pointScale={getZoomRadiusMultiplier(globeAltitude)}
          poleScale={getZoomAltitudeMultiplier(globeAltitude)}
        />
      )}

      <GlobeSettingsPanel
        visible={showSettings}
        onClose={() => setShowSettings?.(false)}
        showDebug={showDebug}
        setShowDebug={setShowDebug}
        layerQuality={layerQuality}
        setLayerQuality={setLayerQuality}
      />

      {activeAirport && showAirportLayers && !selectedPlane && !selectedPort && !selectedMiningAsset && (
        <AirportInfoPanel airport={activeAirport} />
      )}

      {activePort && showPortLayers && !selectedPlane && !selectedAirport && !selectedMiningAsset && (
        <PortInfoPanel port={activePort} />
      )}

      {activePlane && showPlaneLayers && <PlaneInfoPanel plane={activePlane} />}

      {activeMiningAsset && showMiningLayers && !selectedPlane && !selectedAirport && !selectedPort && (
        <div
          style={{
            position: 'absolute',
            left: 20,
            top: 80,
            width: 280,
            padding: '12px 14px',
            background: 'rgba(15,23,42,0.94)',
            border: '1px solid rgba(148,163,184,0.35)',
            borderRadius: 12,
            color: '#e5e7eb',
            zIndex: 130,
            fontSize: 13,
            boxShadow: '0 18px 50px rgba(0,0,0,0.45)',
          }}
        >
          <div style={{ fontWeight: 700, fontSize: 15, marginBottom: 8 }}>
            {activeMiningAsset.name}
          </div>

          <div>Type: {activeMiningAsset.assetTypeRaw ?? activeMiningAsset.entityType}</div>
          <div>Country: {activeMiningAsset.country ?? 'Unknown'}</div>
          <div>Primary: {activeMiningAsset.primaryCommodity}</div>
          <div>Group: {activeMiningAsset.commodityGroup ?? 'Unknown'}</div>
          <div>
            Commodities:{' '}
            {activeMiningAsset.allCommodities.length > 0
              ? activeMiningAsset.allCommodities.join(', ')
              : 'Unknown'}
          </div>
          <div>Confidence: {activeMiningAsset.confidenceFactor ?? 'Unknown'}</div>
        </div>
      )}

      {selectedCountryName && !selectedAirport && !selectedPlane && !selectedPort && !selectedMiningAsset && (
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
          setSelectedPort(null);
          setSelectedMiningAsset(null);
          setSelectedPlane(null);
          setHoverAirport(null);
          setHoverPort(null);
          setHoverMiningAsset(null);
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