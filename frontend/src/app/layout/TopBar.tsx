export default function TopBar() {
  return (
    <div
      style={{
        height: '64px',
        background: 'rgba(175, 10, 10, 0.92)',
        borderBottom: '1px solid #f8f8f8',
        display: 'flex',
        alignItems: 'center',
        padding: '0 24px',
        color: '#e0e7ff',
        backdropFilter: 'blur(12px)',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <div style={{ fontSize: '28px' }}>🌍</div>
        <div>
          <div style={{ fontSize: '22px', fontWeight: 700 }}>AURION</div>
          <div style={{ fontSize: '11px', color: '#272d36' }}>
            ANALYTICAL UNIFIED REAL-TIME INTELLIGENCE OBSERVATION NETWORK Fuck you
          </div>
        </div>
      </div>

      <div
        style={{
          marginLeft: '28px',
          padding: '8px 12px',
          borderRadius: '999px',
          background: 'rgba(99,102,241,0.10)',
          border: '1px solid rgba(99,102,241,0.25)',
          color: '#c7d2fe',
          fontSize: '12px',
          letterSpacing: '0.08em',
          textTransform: 'uppercase',
        }}
      >
        Weather → Gas
      </div>

      <div style={{ marginLeft: 'auto', color: '#22c55e', fontSize: '13px' }}>● LOCAL • LIVE nah</div>
    </div>
  );
}