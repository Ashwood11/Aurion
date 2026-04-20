import React from 'react';

type LayerOption = {
  id: string;
  label: string;
  description?: string;
};

type LayerGroup = {
  id: string;
  label: string;
  icon: string;
  color: string;
  options: LayerOption[];
};

interface RightPanelProps {
  groups: LayerGroup[];
  selectedGroups: string[];
  selectedOptions: string[];
  onToggleGroup: (groupId: string) => void;
  onToggleOption: (optionId: string) => void;
  onClearAll: () => void;
}

export default function RightPanel({
  groups,
  selectedGroups,
  selectedOptions,
  onToggleGroup,
  onToggleOption,
  onClearAll,
}: RightPanelProps) {
  const activeGroups = groups.filter((group) => selectedGroups.includes(group.id));

  const visibleGroups = activeGroups.length > 0 ? activeGroups : groups;

  return (
    <div
      style={{
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        color: '#e5e7eb',
      }}
    >
      {/* Header */}
      <div style={{ marginBottom: '18px' }}>
        <div
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            padding: '8px 12px',
            borderRadius: '999px',
            background: 'rgba(59,130,246,0.10)',
            border: '1px solid rgba(59,130,246,0.25)',
            color: '#c7d2fe',
            fontSize: '12px',
            letterSpacing: '0.08em',
            textTransform: 'uppercase',
            marginBottom: '12px',
          }}
        >
          Layer Control
        </div>

        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
          }}
        >
          <h2
            style={{
              margin: 0,
              fontSize: '28px',
              color: '#f8fafc',
              letterSpacing: '-0.02em',
            }}
          >
            Data Layers
          </h2>

          <button
            onClick={onClearAll}
            style={{
              border: '1px solid rgba(255,255,255,0.10)',
              background: 'rgba(15,23,42,0.85)',
              color: '#cbd5e1',
              borderRadius: '10px',
              padding: '8px 12px',
              cursor: 'pointer',
              fontSize: '12px',
            }}
          >
            Clear all
          </button>
        </div>

        <p
          style={{
            margin: '8px 0 0 0',
            color: '#64748b',
            lineHeight: 1.5,
            fontSize: '13px',
          }}
        >
          Select one or more categories, then enable the layers you want visible on the globe.
        </p>
      </div>

      {/* Group selector */}
      <div
        style={{
          background: 'rgba(15,23,42,0.90)',
          border: '1px solid rgba(255,255,255,0.08)',
          borderRadius: '16px',
          padding: '14px',
          marginBottom: '16px',
        }}
      >
        <div
          style={{
            fontSize: '13px',
            fontWeight: 700,
            color: '#cbd5e1',
            marginBottom: '12px',
            letterSpacing: '0.04em',
            textTransform: 'uppercase',
          }}
        >
          Categories
        </div>

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: '10px',
          }}
        >
          {groups.map((group) => {
            const active = selectedGroups.includes(group.id);

            return (
              <button
                key={group.id}
                onClick={() => onToggleGroup(group.id)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '12px',
                  borderRadius: '14px',
                  border: `1px solid ${active ? `${group.color}55` : 'rgba(255,255,255,0.08)'}`,
                  background: active
                    ? `linear-gradient(135deg, ${group.color}1f, rgba(15,23,42,0.96))`
                    : 'rgba(2,6,23,0.72)',
                  color: '#e2e8f0',
                  cursor: 'pointer',
                  textAlign: 'left',
                  transition: 'all 0.18s ease',
                }}
              >
                <div
                  style={{
                    width: '34px',
                    height: '34px',
                    minWidth: '34px',
                    borderRadius: '10px',
                    display: 'grid',
                    placeItems: 'center',
                    background: active ? `${group.color}24` : 'rgba(255,255,255,0.04)',
                    border: `1px solid ${active ? `${group.color}45` : 'rgba(255,255,255,0.08)'}`,
                    fontSize: '16px',
                  }}
                >
                  {group.icon}
                </div>

                <div style={{ minWidth: 0 }}>
                  <div
                    style={{
                      fontSize: '14px',
                      fontWeight: 600,
                      color: active ? '#f8fafc' : '#dbe2ea',
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {group.label}
                  </div>
                  <div
                    style={{
                      fontSize: '11px',
                      color: active ? '#cbd5e1' : '#64748b',
                      marginTop: '2px',
                    }}
                  >
                    {group.options.length} layers
                  </div>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Options list */}
      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          paddingRight: '2px',
        }}
      >
        {visibleGroups.map((group) => (
          <div
            key={group.id}
            style={{
              background: 'rgba(15,23,42,0.92)',
              border: `1px solid ${selectedGroups.includes(group.id) ? `${group.color}35` : 'rgba(255,255,255,0.08)'}`,
              borderRadius: '16px',
              padding: '14px',
              marginBottom: '14px',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
                marginBottom: '12px',
              }}
            >
              <div
                style={{
                  width: '32px',
                  height: '32px',
                  minWidth: '32px',
                  borderRadius: '10px',
                  display: 'grid',
                  placeItems: 'center',
                  background: `${group.color}1f`,
                  border: `1px solid ${group.color}40`,
                  fontSize: '15px',
                }}
              >
                {group.icon}
              </div>

              <div>
                <div
                  style={{
                    color: '#f8fafc',
                    fontWeight: 700,
                    fontSize: '15px',
                  }}
                >
                  {group.label}
                </div>
                <div
                  style={{
                    color: '#64748b',
                    fontSize: '11px',
                    marginTop: '2px',
                    textTransform: 'uppercase',
                    letterSpacing: '0.06em',
                  }}
                >
                  Select visible layers
                </div>
              </div>
            </div>

            <div style={{ display: 'grid', gap: '8px' }}>
              {group.options.map((option) => {
                const checked = selectedOptions.includes(option.id);

                return (
                  <button
                    key={option.id}
                    onClick={() => onToggleOption(option.id)}
                    style={{
                      width: '100%',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '12px',
                      padding: '11px 12px',
                      borderRadius: '12px',
                      border: `1px solid ${checked ? `${group.color}50` : 'rgba(255,255,255,0.08)'}`,
                      background: checked
                        ? `linear-gradient(90deg, ${group.color}18, rgba(2,6,23,0.88))`
                        : 'rgba(2,6,23,0.70)',
                      color: '#e5e7eb',
                      cursor: 'pointer',
                      textAlign: 'left',
                    }}
                  >
                    <div
                      style={{
                        width: '18px',
                        height: '18px',
                        minWidth: '18px',
                        borderRadius: '6px',
                        border: `1px solid ${checked ? group.color : 'rgba(255,255,255,0.25)'}`,
                        background: checked ? group.color : 'transparent',
                        display: 'grid',
                        placeItems: 'center',
                        color: '#03111f',
                        fontSize: '11px',
                        fontWeight: 800,
                      }}
                    >
                      {checked ? '✓' : ''}
                    </div>

                    <div style={{ minWidth: 0 }}>
                      <div
                        style={{
                          fontSize: '14px',
                          fontWeight: 600,
                          color: checked ? '#f8fafc' : '#dbe2ea',
                          whiteSpace: 'nowrap',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                        }}
                      >
                        {option.label}
                      </div>
                      {option.description && (
                        <div
                          style={{
                            marginTop: '3px',
                            fontSize: '11px',
                            color: '#64748b',
                          }}
                        >
                          {option.description}
                        </div>
                      )}
                    </div>
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* Summary */}
      <div
        style={{
          marginTop: '14px',
          background: 'rgba(15,23,42,0.94)',
          border: '1px solid rgba(255,255,255,0.08)',
          borderRadius: '16px',
          padding: '14px',
        }}
      >
        <div
          style={{
            fontSize: '12px',
            color: '#94a3b8',
            textTransform: 'uppercase',
            letterSpacing: '0.08em',
            marginBottom: '10px',
          }}
        >
          Active Layers
        </div>

        {selectedOptions.length === 0 ? (
          <div style={{ color: '#64748b', fontSize: '13px' }}>
            No layers selected
          </div>
        ) : (
          <div
            style={{
              display: 'flex',
              flexWrap: 'wrap',
              gap: '8px',
            }}
          >
            {groups.flatMap((group) =>
              group.options
                .filter((option) => selectedOptions.includes(option.id))
                .map((option) => (
                  <div
                    key={option.id}
                    style={{
                      padding: '7px 10px',
                      borderRadius: '999px',
                      background: 'rgba(59,130,246,0.10)',
                      border: '1px solid rgba(59,130,246,0.22)',
                      color: '#dbeafe',
                      fontSize: '12px',
                    }}
                  >
                    {option.label}
                  </div>
                ))
            )}
          </div>
        )}
      </div>
    </div>
  );
}