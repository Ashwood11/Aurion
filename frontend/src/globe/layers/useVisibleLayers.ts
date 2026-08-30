import { useMemo } from 'react';
import { filterVisibleGlobePoints } from '../helpers/filterVisiblePoints';
import {
  sortAirportsByImportance,
  sortPortsByImportance,
  sortPlanesByImportance,
} from '../helpers/sortGlobePoints';

import { reducePlanesForZoom } from '../helpers/reducePlanesForZoom';

import type {
  AirportPoint,
  PortPoint,
  MiningAssetPoint,
  PlanePoint,
} from '../types';

interface Params {
  globeRef: any;
  containerRef: HTMLDivElement | null;
  viewLat: number;
  viewLng: number;
  globeAltitude: number;
  viewportTick: number;
  renderCaps: {
    airports: number;
    ports: number;
    planes: number;
  };

  airports: AirportPoint[];
  ports: PortPoint[];
  mining: MiningAssetPoint[];
  planes: PlanePoint[];
}

export function useVisibleLayers({
  globeRef,
  containerRef,
  viewLat,
  viewLng,
  globeAltitude,
  viewportTick,
  renderCaps,
  airports,
  ports,
  mining,
  planes,
}: Params) {
  const visibleAirports = useMemo(() => {
    const visible = filterVisibleGlobePoints({
      points: airports,
      globe: globeRef.current,
      container: containerRef,
      viewLat,
      viewLng,
      margin: 20,
    });

    return sortAirportsByImportance(visible).slice(0, renderCaps.airports);
  }, [airports, viewLat, viewLng, viewportTick, renderCaps.airports]);

  const visiblePorts = useMemo(() => {
    const visible = filterVisibleGlobePoints({
      points: ports,
      globe: globeRef.current,
      container: containerRef,
      viewLat,
      viewLng,
      margin: 20,
    });

    return sortPortsByImportance(visible).slice(0, renderCaps.ports);
  }, [ports, viewLat, viewLng, viewportTick, renderCaps.ports]);

  const visibleMining = useMemo(() => {
    const visible = filterVisibleGlobePoints({
      points: mining,
      globe: globeRef.current,
      container: containerRef,
      viewLat,
      viewLng,
      margin: 20,
    });

    return visible.slice(0, 3500);
  }, [mining, viewLat, viewLng, viewportTick]);

  const visiblePlanes = useMemo(() => {
    const visible = filterVisibleGlobePoints({
      points: planes,
      globe: globeRef.current,
      container: containerRef,
      viewLat,
      viewLng,
      margin: 20,
    });

    const reduced = reducePlanesForZoom(visible, globeAltitude);

    return sortPlanesByImportance(reduced).slice(0, renderCaps.planes);
  }, [planes, viewLat, viewLng, viewportTick, globeAltitude, renderCaps.planes]);

  return {
    visibleAirports,
    visiblePorts,
    visibleMining,
    visiblePlanes,
  };
}