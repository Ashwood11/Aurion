import React, { useState, useMemo } from 'react';
import MainShell from './app/layout/MainShell';
import GlobeView from './globe/GlobeView';

function App() {
  const [selectedCountry, setSelectedCountry] = useState<any>(null);
  const [activeTab, setActiveTab] = useState<'overview' | 'signals' | 'analysis'>('overview');

  // Dummy signals (with strength)
  const signals = useMemo(() => [
    { lat: 40.71, lng: -74.01, size: 1.3, color: '#22ff88', type: 'Gas Price Spike', strength: 0.85 },
    { lat: 29.76, lng: -95.37, size: 1.1, color: '#ffaa00', type: 'Hurricane Risk', strength: 0.72 },
    { lat: 41.88, lng: -87.63, size: 0.9, color: '#ff4444', type: 'Cold Front', strength: -0.65 },
    { lat: 34.05, lng: -118.24, size: 1.0, color: '#4488ff', type: 'Drought Alert', strength: -0.45 },
  ], []);

  return (
    <MainShell
      left={
        <div style={{ width: '260px', background: '#0a0f1c', padding: '20px' }}>
          <h3 style={{ color: '#a5b4fc', marginBottom: '20px' }}>Modules</h3>
          {['Weather & Gas', 'Shipping', 'Natural Gas', 'Flights', 'Commodities', 'Stocks'].map((m, i) => (
            <div key={i} style={{
              padding: '12px 16px',
              marginBottom: '6px',
              background: i === 0 ? '#1e2937' : '#111827',
              borderRadius: '6px',
              cursor: 'pointer',
              borderLeft: i === 0 ? '3px solid #6366f1' : 'none'
            }}>
              {m} {i === 0 && <span style={{color: '#22c55e', float: 'right'}}>● LIVE</span>}
            </div>
          ))}
        </div>
      }
      center={
        <GlobeView 
          onCountrySelect={setSelectedCountry}
          signals={signals}
        />
      }
      right={
        <div style={{ width: '340px', background: '#0a0f1c', padding: '20px', overflowY: 'auto' }}>
          <h3 style={{ color: '#a5b4fc', marginBottom: '16px' }}>Selected Country</h3>
          
          {selectedCountry ? (
            <>
              <h2 style={{ margin: '0 0 4px 0' }}>{selectedCountry.ADMIN || selectedCountry.name}</h2>
              <p style={{ color: '#64748b' }}>{selectedCountry.ISO_A3}</p>

              {/* Tabs */}
              <div style={{ display: 'flex', gap: '8px', margin: '20px 0 16px 0', borderBottom: '1px solid #1e2a44' }}>
                {(['overview', 'signals', 'analysis'] as const).map(tab => (
                  <button
                    key={tab}
                    onClick={() => setActiveTab(tab)}
                    style={{
                      padding: '8px 16px',
                      background: activeTab === tab ? '#1e2937' : 'transparent',
                      border: 'none',
                      color: activeTab === tab ? '#e0e7ff' : '#64748b',
                      borderBottom: activeTab === tab ? '2px solid #6366f1' : 'none',
                      cursor: 'pointer'
                    }}
                  >
                    {tab.charAt(0).toUpperCase() + tab.slice(1)}
                  </button>
                ))}
              </div>

              {/* Tab Content */}
              {activeTab === 'overview' && (
                <p style={{ color: '#94a3b8' }}>Basic country overview and risk summary will go here.</p>
              )}
              {activeTab === 'signals' && (
                <div>
                  <h4 style={{ color: '#a5b4fc', marginBottom: '12px' }}>Live Signals</h4>
                  {signals.map((signal, i) => (
                    <div key={i} style={{
                      background: '#1e2937',
                      padding: '12px',
                      marginBottom: '8px',
                      borderRadius: '6px',
                      borderLeft: `4px solid ${signal.color}`
                    }}>
                      <strong>{signal.type}</strong><br />
                      <small style={{ color: '#94a3b8' }}>
                        Strength: {signal.strength}
                      </small>
                    </div>
                  ))}
                </div>
              )}
              {activeTab === 'analysis' && (
                <p style={{ color: '#94a3b8' }}>Deeper analysis, forecasts, and fusion results will appear here.</p>
              )}
            </>
          ) : (
            <p style={{ color: '#64748b' }}>Click a country on the globe to begin analysis</p>
          )}
        </div>
      }
      bottom={null}
    />
  );
}

export default App;