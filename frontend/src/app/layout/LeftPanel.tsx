type ModuleItem = {
  id: string;
  label: string;
  subtitle?: string;
  icon: string;
  accent?: string;
  status?: string;
};

interface LeftPanelProps {
  modules: ModuleItem[];
  activeModule: string;
  onSelectModule: (id: string) => void;
  expanded?: boolean;
  onOpenSettings?: () => void;
}

export default function LeftPanel({
  modules,
  activeModule,
  onSelectModule,
  expanded = false,
  onOpenSettings,
}: LeftPanelProps) {
  return (
    <div
      style={{
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        background: '#0a0f1a',
        color: '#e0e7ff',
        width: '100%',
        boxSizing: 'border-box',
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: expanded ? 'flex-start' : 'center',
          gap: expanded ? '10px' : '0',
          minHeight: '52px',
          padding: expanded ? '0 14px' : '0 6px',
          borderBottom: '1px solid rgba(255,255,255,0.06)',
        }}
      >
        <div
          style={{
            width: '28px',
            height: '28px',
            borderRadius: '8px',
            background: '#1e2937',
            display: 'grid',
            placeItems: 'center',
            color: '#fff',
            fontSize: '17px',
            fontWeight: 700,
            border: '1px solid #334155',
          }}
        >
          A
        </div>

        {expanded && (
          <div>
            <div style={{ fontSize: '14.5px', fontWeight: 700 }}>AURION</div>
          </div>
        )}
      </div>

      <div
        style={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: '1px',
          padding: '8px 0',
          overflowY: 'auto',
        }}
      >
        {modules.map((module) => {
          const isActive = module.id === activeModule;

          return (
            <button
              key={module.id}
              onClick={() => onSelectModule(module.id)}
              title={module.label}
              style={{
                position: 'relative',
                display: 'flex',
                alignItems: 'center',
                height: '38px',
                paddingLeft: '10px',
                border: 'none',
                background: isActive ? 'rgba(255, 255, 255, 0.12)' : 'transparent',
                cursor: 'pointer',
              }}
            >
              <div
                style={{
                  width: '26px',
                  height: '26px',
                  display: 'grid',
                  placeItems: 'center',
                  fontSize: '15.5px',
                  color: '#ffffff',
                  flexShrink: 0,
                }}
              >
                {module.icon}
              </div>

              <span
                style={{
                  marginLeft: expanded ? '12px' : '0',
                  opacity: expanded ? 1 : 0,
                  width: expanded ? 'auto' : '0',
                  overflow: 'hidden',
                  whiteSpace: 'nowrap',
                  fontSize: '13.2px',
                  fontWeight: isActive ? 600 : 500,
                  color: '#ffffff',
                  transition: 'margin-left 0.22s ease, opacity 0.2s ease',
                }}
              >
                {module.label}
              </span>
            </button>
          );
        })}
      </div>

      <div
        style={{
          padding: '8px 0',
          borderTop: '1px solid rgba(255,255,255,0.06)',
        }}
      >
        <button
          onClick={onOpenSettings}
          title="System Settings"
          style={{
            width: '100%',
            display: 'flex',
            alignItems: 'center',
            height: '38px',
            paddingLeft: '10px',
            border: 'none',
            background: 'transparent',
            color: '#ffffff',
            cursor: 'pointer',
          }}
        >
          <div
            style={{
              width: '26px',
              height: '26px',
              display: 'grid',
              placeItems: 'center',
              fontSize: '15.5px',
            }}
          >
            ⚙
          </div>

          <span
            style={{
              marginLeft: expanded ? '12px' : '0',
              opacity: expanded ? 1 : 0,
              width: expanded ? 'auto' : '0',
              overflow: 'hidden',
              whiteSpace: 'nowrap',
              fontSize: '13.2px',
              color: '#ffffff',
              transition: 'margin-left 0.22s ease, opacity 0.2s ease',
            }}
          >
            System Settings
          </span>
        </button>
      </div>
    </div>
  );
}