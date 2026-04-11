import React, { useState } from 'react';

interface MainShellProps {
  left?: React.ReactNode;
  center?: React.ReactNode;
  right?: React.ReactNode;
  bottom?: React.ReactNode;
}

const MainShell: React.FC<MainShellProps> = ({ left, center, right, bottom }) => {
  const [modulesOpen, setModulesOpen] = useState(false);
  const [rightOpen, setRightOpen] = useState(true);   // Right panel starts open

  return (
    <div style={{
      width: '100vw',
      height: '100vh',
      background: '#05080f',
      color: '#e0e7ff',
      overflow: 'hidden',
      display: 'flex',
      flexDirection: 'column'
    }}>
      {/* Top Bar */}
      <div style={{
        height: '64px',
        background: '#0a0f1c',
        borderBottom: '1px solid #1e2a44',
        display: 'flex',
        alignItems: 'center',
        padding: '0 24px',
        zIndex: 30
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ fontSize: '28px' }}>🌍</div>
          <div>
            <div style={{ fontSize: '22px', fontWeight: 700 }}>AURION</div>
            <div style={{ fontSize: '11px', color: '#64748b' }}>
              ANALYTICAL UNIFIED REAL-TIME INTELLIGENCE OBSERVATION NETWORK
            </div>
          </div>
        </div>

        <button
          onClick={() => setModulesOpen(!modulesOpen)}
          style={{
            marginLeft: '30px',
            padding: '8px 16px',
            background: '#1e2937',
            border: '1px solid #334155',
            borderRadius: '6px',
            color: '#e0e7ff',
            cursor: 'pointer'
          }}
        >
          {modulesOpen ? 'Hide Modules' : 'Modules'}
        </button>

        <div style={{ marginLeft: 'auto', color: '#22c55e' }}>● LOCAL • LIVE</div>
      </div>

      {/* Main Content */}
      <div style={{ flex: 1, display: 'flex', minHeight: 0, position: 'relative' }}>
        {/* Left Modules (Overlay) */}
        {modulesOpen && (
          <div style={{
            position: 'absolute',
            left: '24px',
            top: '80px',
            width: '260px',
            background: '#0a0f1c',
            border: '1px solid #1e2a44',
            borderRadius: '8px',
            padding: '16px',
            zIndex: 40,
            boxShadow: '0 10px 30px rgba(0,0,0,0.6)'
          }}>
            {left}
          </div>
        )}

        {/* Globe - Takes remaining space */}
        <div style={{ 
          flex: 1, 
          position: 'relative',
          minWidth: 0,
          overflow: 'hidden'
        }}>
          {center}
        </div>

        {/* Right Panel */}
        {right && (
          <div style={{
            width: rightOpen ? '340px' : '0px',
            background: '#0a0f1c',
            borderLeft: rightOpen ? '1px solid #1e2a44' : 'none',
            overflow: 'hidden',
            transition: 'width 0.3s ease',
            zIndex: 20
          }}>
            <div style={{ width: '340px', height: '100%', overflowY: 'auto', padding: '20px' }}>
              {right}
            </div>
          </div>
        )}

        {/* Right Panel Toggle Button */}
        {right && (
          <button
            onClick={() => setRightOpen(!rightOpen)}
            style={{
              position: 'absolute',
              right: rightOpen ? '340px' : '0px',
              top: '50%',
              transform: 'translateY(-50%)',
              background: '#1e2937',
              border: '1px solid #334155',
              color: '#e0e7ff',
              padding: '12px 6px',
              borderRadius: '6px 0 0 6px',
              cursor: 'pointer',
              zIndex: 25,
              fontSize: '14px'
            }}
          >
            {rightOpen ? '▶' : '◀'}
          </button>
        )}
      </div>
    </div>
  );
};

export default MainShell;