import React, { useRef, useState, useEffect, useMemo } from 'react';
import Globe from 'react-globe.gl';

interface GlobeViewProps {
  onCountrySelect?: (country: any) => void;
  signals?: any[];           // We'll pass signals here later
}

const GlobeView: React.FC<GlobeViewProps> = ({ onCountrySelect, signals = [] }) => {
  const globeRef = useRef<any>(null);
  const [selectedCountry, setSelectedCountry] = useState<any>(null);
  const [hoverCountry, setHoverCountry] = useState<any>(null);
  const [countries, setCountries] = useState<any[]>([]);

  // Load countries
  useEffect(() => {
    fetch('https://raw.githubusercontent.com/vasturiano/react-globe.gl/master/example/datasets/ne_110m_admin_0_countries.geojson')
      .then(res => res.json())
      .then(data => setCountries(data.features))
      .catch(err => console.error(err));
  }, []);

  const handlePolygonClick = (polygon: any, event: any, coords: { lat: number; lng: number }) => {
    const country = polygon?.properties || polygon;
    if (country) {
      setSelectedCountry(country);
      onCountrySelect?.(country);

      globeRef.current?.pointOfView({
        lat: coords.lat,
        lng: coords.lng,
        altitude: 1.6
      }, 800);
    }
  };

  const handlePolygonHover = (polygon: any) => {
    const country = polygon?.properties || polygon;
    setHoverCountry(country || null);
  };

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative' }}>
      <Globe
        ref={globeRef}
        globeImageUrl="https://unpkg.com/three-globe@2.45.2/example/img/earth-dark.jpg"
        backgroundColor="#020202"
        atmosphereColor="#c4c5c5"
        atmosphereAltitude={0.15}

        polygonsData={countries}
        polygonGeoJsonGeometry={(d: any) => d.geometry}
        polygonCapColor={(d: any) => (d?.properties === selectedCountry || d === selectedCountry ? '#ffffff93' : '#181818')}
        polygonSideColor={() => '#5f5a5a'}
        polygonStrokeColor={() => '#ffffff'}
        polygonAltitude={(d: any) => (d?.properties === selectedCountry || d === selectedCountry ? 0.01 : 0.008)}

        // Real Signals from Weather Module
        pointsData={signals}
        pointAltitude="size"
        pointColor="color"
        pointRadius={0.65}
        pointLabel="type"

        onPolygonHover={handlePolygonHover}
        onPolygonClick={handlePolygonClick}
      />

      {/* Hover Label */}
      {hoverCountry && (
        <div style={{
          position: 'absolute',
          top: '20px',
          left: '50%',
          transform: 'translateX(-50%)',
          background: 'rgba(15, 23, 42, 0.95)',
          padding: '8px 20px',
          borderRadius: '6px',
          color: '#e0e7ff',
          fontSize: '16px',
          fontWeight: 500,
          border: '1px solid #475569',
          pointerEvents: 'none',
          zIndex: 100
        }}>
          {hoverCountry.ADMIN || hoverCountry.NAME || hoverCountry.name || 'Unknown'}
        </div>
      )}

      {/* Controls */}
      <div style={{
        position: 'absolute',
        bottom: '30px',
        right: '30px',
        display: 'flex',
        flexDirection: 'column',
        gap: '8px'
      }}>
        <button 
          onClick={() => globeRef.current?.pointOfView({ altitude: 2.8 }, 800)}
          style={{
            padding: '10px 18px',
            background: '#1e2937',
            color: '#e0e7ff',
            border: '1px solid #475569',
            borderRadius: '6px',
            cursor: 'pointer'
          }}
        >
          Reset View
        </button>
      </div>
    </div>
  );
};

export default GlobeView;