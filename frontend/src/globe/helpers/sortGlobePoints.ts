import type { AirportPoint, PlanePoint, PortPoint } from '../types';

function getAirportPriority(airport: AirportPoint): number {
  const type = airport.airport_type?.toLowerCase() ?? '';

  if (type.includes('large')) return 100;
  if (type.includes('medium')) return 70;
  if (type.includes('small')) return 40;
  if (type.includes('heliport')) return 20;
  if (type.includes('seaplane')) return 15;
  if (type.includes('closed')) return 0;

  return 10;
}

function getPortPriority(port: PortPoint): number {
  let score = 0;

  const sizeClass = port.size_class?.toLowerCase() ?? '';
  const portType = port.port_type?.toLowerCase() ?? '';
  const harborUse = port.harbor_use?.toLowerCase() ?? '';

  if (sizeClass.includes('very large')) score += 100;
  else if (sizeClass.includes('large')) score += 80;
  else if (sizeClass.includes('medium')) score += 50;
  else if (sizeClass.includes('small')) score += 20;

  if (port.has_container) score += 35;
  if (port.has_oil_terminal) score += 30;
  if (port.has_lng_terminal) score += 30;

  if (portType.includes('deepwater')) score += 20;
  if (harborUse.includes('commercial')) score += 20;
  if (harborUse.includes('naval') || harborUse.includes('military')) score += 15;

  if (typeof port.significance_score === 'number') {
    score += port.significance_score;
  }

  return score;
}

function getPlanePriority(plane: PlanePoint): number {
  const speed = plane.ground_speed_kts ?? 0;
  const altitude = plane.altitude_ft ?? 0;

  let score = 0;

  score += speed * 0.3;
  score += altitude * 0.001;

  if (plane.destination_lat != null && plane.destination_lng != null) score += 25;
  if (plane.origin && plane.origin !== 'UNK') score += 10;
  if (plane.destination && plane.destination !== 'UNK') score += 10;

  return score;
}

export function sortAirportsByImportance(airports: AirportPoint[]): AirportPoint[] {
  return [...airports].sort((a, b) => getAirportPriority(b) - getAirportPriority(a));
}

export function sortPortsByImportance(ports: PortPoint[]): PortPoint[] {
  return [...ports].sort((a, b) => getPortPriority(b) - getPortPriority(a));
}

export function sortPlanesByImportance(planes: PlanePoint[]): PlanePoint[] {
  return [...planes].sort((a, b) => getPlanePriority(b) - getPlanePriority(a));
}