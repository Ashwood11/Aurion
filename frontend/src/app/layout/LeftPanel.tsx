export default function LeftPanel({
  regions,
  selectedRegionId,
  onSelectRegion,
}: any) {
  const sorted = [...regions].sort(
    (a, b) => Math.abs(b.gasScore) - Math.abs(a.gasScore)
  );

  return (
    <div>
      {sorted.map((r) => (
        <button
          key={r.id}
          onClick={() => onSelectRegion(r.id)}
          style={{
            display: 'block',
            width: '100%',
            marginBottom: '10px',
            padding: '10px',
            textAlign: 'left',
            background:
              r.id === selectedRegionId ? '#1a2744' : '#162038',
            border: '1px solid #2b3955',
            borderRadius: '8px',
            color: '#fff',
          }}
        >
          <div>
            <strong>{r.name}</strong> ({r.gasScore.toFixed(2)})
          </div>

          <div style={{ fontSize: '12px', opacity: 0.8 }}>
            {r.signals[0]?.summary}
          </div>
        </button>
      ))}
    </div>
  );
}