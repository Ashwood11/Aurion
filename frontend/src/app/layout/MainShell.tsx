import React, { useState } from 'react';

interface MainShellProps {
  left?: React.ReactNode;
  center?: React.ReactNode;
  right?: React.ReactNode;
  bottom?: React.ReactNode;
}

const MainShell: React.FC<MainShellProps> = ({ left, center, right, bottom }) => {
  const [leftExpanded, setLeftExpanded] = useState(false);
  const [rightOpen, setRightOpen] = useState(true);
  const [showGlobeSettings, setShowGlobeSettings] = useState(false);

  const renderedLeft = React.isValidElement(left)
    ? React.cloneElement(left as React.ReactElement<any>, {
        expanded: leftExpanded,
        onOpenSettings: () => setShowGlobeSettings(true),
      })
    : left;

  const renderedCenter = React.isValidElement(center)
    ? React.cloneElement(center as React.ReactElement<any>, {
        showSettings: showGlobeSettings,
        setShowSettings: setShowGlobeSettings,
      })
    : center;

  return (
    <div
      style={{
        width: '100vw',
        height: '100vh',
        background:
          'radial-gradient(circle at top, rgba(22,36,70,0.38), transparent 28%), #05080f',
        color: '#e0e7ff',
        overflow: 'hidden',
        position: 'relative',
      }}
    >
      {left && (
        <div
          onMouseEnter={() => setLeftExpanded(true)}
          onMouseLeave={() => setLeftExpanded(false)}
          style={{
            position: 'absolute',
            left: 0,
            top: 0,
            bottom: 0,
            width: leftExpanded ? 220 : 56,
            background: 'rgba(3, 8, 18, 0.98)',
            borderRight: '1px solid rgba(255,255,255,0.14)',
            padding: leftExpanded ? '10px 8px' : '8px 6px',
            zIndex: 80,
            overflow: 'hidden',
            transition: 'width 0.22s ease, padding 0.22s ease',
            boxShadow: '8px 0 28px rgba(0,0,0,0.38)',
            backdropFilter: 'blur(14px)',
            boxSizing: 'border-box',
          }}
        >
          {renderedLeft}
        </div>
      )}

      <div
        style={{
          position: 'absolute',
          inset: 0,
          minWidth: 0,
          overflow: 'hidden',
          zIndex: 1,
        }}
      >
        {renderedCenter}
      </div>

      {right && (
        <div
          style={{
            position: 'absolute',
            top: 0,
            right: 0,
            bottom: 0,
            width: rightOpen ? 340 : 0,
            background: 'rgba(3, 8, 18, 0.985)',
            borderLeft: rightOpen ? '1px solid rgba(255,255,255,0.10)' : 'none',
            overflow: 'hidden',
            transition: 'width 0.24s ease',
            zIndex: 90,
            backdropFilter: 'blur(14px)',
            boxShadow: '-8px 0 28px rgba(0,0,0,0.35)',
          }}
        >
          <div
            style={{
              width: 340,
              height: '100%',
              overflowY: 'auto',
              padding: 20,
              boxSizing: 'border-box',
              position: 'relative',
              zIndex: 2,
              background: 'rgba(3, 8, 18, 0.98)',
            }}
          >
            {right}
          </div>
        </div>
      )}

      {right && (
        <button
          onClick={() => setRightOpen(!rightOpen)}
          style={{
            position: 'absolute',
            right: rightOpen ? 340 : 0,
            top: '50%',
            transform: 'translateY(-50%)',
            background: 'rgba(37, 54, 89, 0.96)',
            border: '1px solid rgba(255,255,255,0.16)',
            color: '#e0e7ff',
            padding: '12px 7px',
            borderRadius: '10px 0 0 10px',
            cursor: 'pointer',
            zIndex: 95,
            fontSize: 14,
            transition: 'right 0.24s ease',
          }}
        >
          {rightOpen ? '▶' : '◀'}
        </button>
      )}

      {bottom && (
        <div
          style={{
            position: 'absolute',
            left: left ? (leftExpanded ? 236 : 72) : 18,
            right: right && rightOpen ? 356 : 18,
            bottom: 16,
            zIndex: 85,
            transition: 'left 0.22s ease, right 0.24s ease',
          }}
        >
          {bottom}
        </div>
      )}
    </div>
  );
};

export default MainShell;