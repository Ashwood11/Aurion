import React from 'react';
import type { AirportPoint } from '../types';

interface AirportInfoPanelProps {
  airport: AirportPoint;
}

const AirportInfoPanel: React.FC<AirportInfoPanelProps> = ({ airport }) => {
  return (
    <div style={infoPanelStyle}>
      <div style={panelTitleStyle}>{airport.name}</div>
      <div style={panelAccentStyle}>
        {airport.code || airport.gps_code || 'No code'}
      </div>
      <div style={panelLineStyle}>
        Type: {airport.airport_type.replace(/_/g, ' ')}
      </div>
      <div style={panelLineStyle}>
        Scheduled service: {airport.scheduled_service ?? 'Unknown'}
      </div>
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

export default AirportInfoPanel;