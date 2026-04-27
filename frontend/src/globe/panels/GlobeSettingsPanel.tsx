import React from 'react';
import type { LayerQuality } from '../helpers/zoom';

interface Props {
  visible: boolean;
  onClose: () => void;

  showDebug: boolean;
  setShowDebug: (v: boolean) => void;

  layerQuality: LayerQuality;
  setLayerQuality: (q: LayerQuality) => void;
}

const GlobeSettingsPanel: React.FC<Props> = ({
  visible,
  onClose,
  showDebug,
  setShowDebug,
  layerQuality,
  setLayerQuality,
}) => {
  if (!visible) return null;

  return (
    <div style={wrapper}>
      <div style={panel}>
        <div style={title}>Settings</div>

        <div style={section}>
          <div style={label}>Debug Panel</div>
          <button onClick={() => setShowDebug(!showDebug)} style={btn}>
            {showDebug ? 'ON' : 'OFF'}
          </button>
        </div>

        <div style={section}>
          <div style={label}>Quality</div>
          <div style={{ display: 'flex', gap: 6 }}>
            {(['performance', 'balanced', 'high'] as LayerQuality[]).map((q) => (
              <button
                key={q}
                onClick={() => setLayerQuality(q)}
                style={{
                  ...btn,
                  background:
                    layerQuality === q
                      ? 'rgba(34,197,94,0.3)'
                      : 'rgba(15,23,42,0.9)',
                }}
              >
                {q}
              </button>
            ))}
          </div>
        </div>

        <button onClick={onClose} style={{ ...btn, marginTop: 10 }}>
          Close
        </button>
      </div>
    </div>
  );
};

const wrapper = {
  position: 'absolute' as const,
  top: 0,
  left: 0,
  width: '100%',
  height: '100%',
  background: 'rgba(0,0,0,0.4)',
  zIndex: 200,
};

const panel = {
  position: 'absolute' as const,
  top: 80,
  left: 80,
  background: '#020617',
  padding: 20,
  borderRadius: 12,
  border: '1px solid #475569',
  color: '#e2e8f0',
  minWidth: 240,
};

const title = {
  fontWeight: 700,
  marginBottom: 10,
};

const section = {
  marginBottom: 10,
};

const label = {
  fontSize: 12,
  marginBottom: 4,
};

const btn = {
  padding: '6px 10px',
  borderRadius: 6,
  border: '1px solid rgba(255,255,255,0.15)',
  background: 'rgba(15,23,42,0.9)',
  color: '#e5e7eb',
  cursor: 'pointer',
};

export default GlobeSettingsPanel;