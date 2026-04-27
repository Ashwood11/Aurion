import React from 'react';
import type { PortPoint } from '../types';

interface PortInfoPanelProps {
  port: PortPoint;
}

const PortInfoPanel: React.FC<PortInfoPanelProps> = ({ port }) => {
  return (
    <div style={{ ...infoPanelStyle, minWidth: 280 }}>
      <div style={panelTitleStyle}>{port.name}</div>
      <div style={panelAccentStyle}>UN/LOCODE: {port.unlocode ?? 'Unknown'}</div>

      <div style={panelLineStyle}>Country: {port.country_code ?? 'Unknown'}</div>
      <div style={panelLineStyle}>Harbor Type: {port.port_type ?? 'Unknown'}</div>
      <div style={panelLineStyle}>Size: {port.size_class ?? 'Unknown'}</div>
      <div style={panelLineStyle}>Use: {port.harbor_use ?? 'Unknown'}</div>
      <div style={panelLineStyle}>Water body: {port.water_body ?? 'Unknown'}</div>

      <div style={{ ...panelLineStyle, marginTop: 6 }}>
        Container: {port.has_container == null ? 'Unknown' : port.has_container ? 'Yes' : 'No'}
      </div>
      <div style={panelLineStyle}>
        Oil terminal: {port.has_oil_terminal == null ? 'Unknown' : port.has_oil_terminal ? 'Yes' : 'No'}
      </div>
      <div style={panelLineStyle}>
        LNG terminal: {port.has_lng_terminal == null ? 'Unknown' : port.has_lng_terminal ? 'Yes' : 'No'}
      </div>

      <div style={{ ...panelLineStyle, marginTop: 6 }}>
        Channel depth: {port.channel_depth != null ? `${port.channel_depth} m` : 'Unknown'}
      </div>
      <div style={panelLineStyle}>
        Anchorage depth: {port.anchorage_depth != null ? `${port.anchorage_depth} m` : 'Unknown'}
      </div>
      <div style={panelLineStyle}>
        Max vessel length: {port.max_vessel_length != null ? `${port.max_vessel_length} m` : 'Unknown'}
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

export default PortInfoPanel;