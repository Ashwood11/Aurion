import React, { useRef, useState, useEffect } from 'react';
import Globe from 'react-globe.gl';

interface GlobeViewProps {
  onCountrySelect?: (country: any) => void;
  signals?: any[];           
}

interface WeatherPoint {
  name: string;
  lat: number;
  lng: number;
  temp: number | null;
  wind: number;
  precip: number;
  color: string;
  size: number;
}

const GlobeView: React.FC<GlobeViewProps> = ({ onCountrySelect, signals = [] }) => {
  const globeRef = useRef<any>(null);
  const [selectedCountry, setSelectedCountry] = useState<any>(null);
  const [hoverCountry, setHoverCountry] = useState<any>(null);
  const [countries, setCountries] = useState<any[]>([]);
  const [weatherPoints, setWeatherPoints] = useState<WeatherPoint[]>([]);

  // Load country polygons
  useEffect(() => {
    fetch('https://raw.githubusercontent.com/vasturiano/react-globe.gl/master/example/datasets/ne_110m_admin_0_countries.geojson')
      .then(res => res.json())
      .then(data => setCountries(data.features))
      .catch(err => console.error('Failed to load countries:', err));
  }, []);

  // Fetch live weather points from backend
  useEffect(() => {
    fetch('http://127.0.0.1:8000/globe/data')
      .then(res => res.json())
      .then(data => {
        const mapped = data.weather.map((w: any) => {
          const locationMap: { [key: string]: { lat: number; lng: number } } = {
            "New York": { lat: 40.7128, lng: -74.0060 },
            "London": { lat: 51.5074, lng: -0.1278 },
            "Tokyo": { lat: 35.6762, lng: 139.6503 },
            "Singapore": { lat: 1.3521, lng: 103.8198 },
            "Rotterdam": { lat: 51.9225, lng: 4.4792 },
            "Houston": { lat: 29.7604, lng: -95.3698 },
            "Chicago": { lat: 41.8781, lng: -87.6298 },
            "São Paulo": { lat: -23.5505, lng: -46.6333 },
            "Buenos Aires": { lat: -34.6037, lng: -58.3816 },
            "Moscow": { lat: 55.7558, lng: 37.6173 },
            "Shanghai": { lat: 31.2304, lng: 121.4737 },
            "Dubai": { lat: 25.2048, lng: 55.2708 },
          };

          const coords = locationMap[w.name] || { lat: 20, lng: 0 };
          const temp = w.temp;

          return {
            name: w.name,
            lat: coords.lat,
            lng: coords.lng,
            temp: temp,
            wind: w.wind || 0,
            precip: w.precip || 0,
            color: temp > 30 ? '#ff4444' : temp < 5 ? '#4488ff' : '#ffcc00',
            size: 0.35 + (temp ? Math.min(Math.abs(temp) / 80, 0.6) : 0.3)
          };
        });
        setWeatherPoints(mapped);
      })
      .catch(err => console.error("Failed to load weather points:", err));
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
    setHoverCountry(polygon?.properties || polygon || null);
  };

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative' }}>
      <Globe
        ref={globeRef}
        globeImageUrl="https://unpkg.com/three-globe@2.45.2/example/img/earth-dark.jpg"
        backgroundColor="#020202"
        atmosphereColor="#c4c5c5"
        atmosphereAltitude={0.15}

        // Your country polygons
        polygonsData={countries}
        polygonGeoJsonGeometry={(d: any) => d.geometry}
        polygonCapColor={(d: any) => 
          (d?.properties === selectedCountry || d === selectedCountry) ? '#ffffff93' : '#181818'
        }
        polygonSideColor={() => '#5f5a5a'}
        polygonStrokeColor={() => '#ffffff'}
        polygonAltitude={(d: any) => 
          (d?.properties === selectedCountry || d === selectedCountry) ? 0.01 : 0.008
        }
        onPolygonHover={handlePolygonHover}
        onPolygonClick={handlePolygonClick}

        // Weather Points
        pointsData={weatherPoints}
        pointAltitude="size"
        pointColor="color"
        pointRadius="size"
        pointLabel={(d: any) => `${d.name}\n${d.temp !== null ? d.temp.toFixed(1)+'°C' : 'N/A'}`}
      />

      {/* Hover Label */}
      {hoverCountry && (
        <div style={{
          position: 'absolute', top: '20px', left: '50%', transform: 'translateX(-50%)',
          background: 'rgba(15, 23, 42, 0.95)', padding: '8px 20px', borderRadius: '6px',
          color: '#e0e7ff', fontSize: '16px', fontWeight: 500, border: '1px solid #475569',
          pointerEvents: 'none', zIndex: 100
        }}>
          {hoverCountry.ADMIN || hoverCountry.NAME || hoverCountry.name || 'Unknown'}
        </div>
      )}

      {/* Legend */}
      <div style={{
        position: 'absolute', bottom: '30px', left: '30px',
        background: 'rgba(15, 23, 42, 0.9)', padding: '10px 15px',
        borderRadius: '6px', color: '#e0e7ff', fontSize: '14px', border: '1px solid #475569'
      }}>
        🔴 Hot &gt;30°C &nbsp;&nbsp; 🔵 Cold &lt;5°C &nbsp;&nbsp; 🟡 Normal
      </div>

      {/* Reset Button */}
      <div style={{ position: 'absolute', bottom: '30px', right: '30px' }}>
        <button 
          onClick={() => globeRef.current?.pointOfView({ altitude: 2.8 }, 800)}
          style={{ padding: '10px 18px', background: '#1e2937', color: '#e0e7ff', border: '1px solid #475569', borderRadius: '6px', cursor: 'pointer' }}
        >
          Reset View
        </button>
      </div>
    </div>
  );
};

export default GlobeView;