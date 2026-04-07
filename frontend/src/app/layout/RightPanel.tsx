import type { RegionState } from '../../features/weatherGas/types';

function getColor(score: number) {
  if (score > 0.6) return '#ff4d4f';
  if (score > 0.25) return '#ff9f43';
  if (score < -0.25) return '#4da3ff';
  return '#b8c0cc';
}

function getSignalLabel(score: number) {
  if (score > 0.6) return 'Strong Bullish (Gas ↑)';
  if (score > 0.25) return 'Bullish (Gas ↑)';
  if (score < -0.6) return 'Strong Bearish (Gas ↓)';
  if (score < -0.25) return 'Bearish (Gas ↓)';
  return 'Neutral';
}

export default function RightPanel({ region }: { region: RegionState }) {
  const color = getColor(region.gasScore);

  return (
    <div style={{ padding: '16px' }}>
      <h2 style={{ borderBottom: `2px solid ${color}` }}>
        {region.name}
      </h2>

      <p style={{ color, fontWeight: 'bold' }}>
        {getSignalLabel(region.gasScore)} ({region.gasScore.toFixed(2)})
      </p>

      <p>{region.explanation}</p>

      <div style={{ marginTop: '10px' }}>
        <strong>Signals:</strong>
        {region.signals.map((s) => (
          <div key={s.signalType}>
            {s.signalType}: {s.summary}
          </div>
        ))}
      </div>
    </div>
  );
}