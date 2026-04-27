import React from 'react';
import type { PlanePoint } from '../types';

interface PlaneInfoPanelProps {
  plane: PlanePoint;
}

const PlaneInfoPanel: React.FC<PlaneInfoPanelProps> = ({ plane }) => {
  return (
    <div style={infoPanelStyle}>
      <div style={panelTitleStyle}>{plane.callsign}</div>
      <div style={panelAccentStyle}>{plane.aircraft_type}</div>
      <div style={panelLineStyle}>Altitude: {plane.altitude_ft ?? 'N/A'} ft</div>
      <div style={panelLineStyle}>Speed: {plane.ground_speed_kts ?? 'N/A'} kts</div>
      <div style={panelLineStyle}>Heading: {plane.heading_deg ?? 'N/A'}°</div>
      <div style={panelLineStyle}>
        Route: {plane.origin ?? 'UNK'} → {plane.destination ?? 'UNK'}
      </div>
      <div style={panelLineStyle}>Type: {plane.status ?? 'unknown'}</div>
    </div>
  );
};

const infoPanelStyle: React.CSSProperties = {
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
};

const panelTitleStyle: React.CSSProperties = {
  fontWeight: 700,
  fontSize: 14,
  marginBottom: 6,
};

const panelAccentStyle: React.CSSProperties = {
  color: '#86efac',
  fontSize: 12,
  marginBottom: 4,
};

const panelLineStyle: React.CSSProperties = {
  color: '#94a3b8',
  fontSize: 12,
};

export default PlaneInfoPanel;