import type { RegionState, RegionSignal } from './types';

export function computeGasSignal(region: RegionState) {
  const tempScore = clamp(-region.tempAnomalyC / 10, -1, 1);
  const hddScore = clamp(region.hdd / 25, 0, 1);
  const windScore = clamp(-region.windAnomalyPct / 50, -1, 1);

  const gasScore =
    0.5 * tempScore +
    0.3 * hddScore +
    0.2 * windScore;

  const confidence = 0.75;

  const explanation = buildExplanation(region);

  const signals = buildSignals(
    region,
    tempScore,
    hddScore,
    windScore,
    confidence
  );

  return {
    gasScore: clamp(gasScore, -1, 1),
    confidence,
    explanation,
    signals,
  };
}

function buildSignals(
  region: RegionState,
  tempScore: number,
  hddScore: number,
  windScore: number,
  confidence: number
): RegionSignal[] {
  return [
    {
      signalType: 'temp_anomaly',
      strength: tempScore,
      confidence,
      summary:
        region.tempAnomalyC < 0
          ? `Temperature is ${Math.abs(region.tempAnomalyC).toFixed(1)}°C below normal`
          : `Temperature is ${region.tempAnomalyC.toFixed(1)}°C above normal`,
    },
    {
      signalType: 'heating_demand',
      strength: hddScore,
      confidence,
      summary: `Heating demand proxy is ${region.hdd} HDD`,
    },
    {
      signalType: 'wind_anomaly',
      strength: windScore,
      confidence,
      summary:
        region.windAnomalyPct < 0
          ? `Wind is ${Math.abs(region.windAnomalyPct)}% below normal`
          : `Wind is ${region.windAnomalyPct}% above normal`,
    },
  ];
}

function buildExplanation(region: RegionState) {
  const parts: string[] = [];

  // Temperature impact
  if (region.tempAnomalyC < -2) {
    parts.push(
      `Temperature is ${Math.abs(region.tempAnomalyC).toFixed(1)}°C below normal`
    );
  } else if (region.tempAnomalyC > 2) {
    parts.push(
      `Temperature is ${region.tempAnomalyC.toFixed(1)}°C above normal`
    );
  }

  // Heating demand
  if (region.hdd > 12) {
    parts.push(`Heating demand is elevated (HDD ${region.hdd})`);
  }

  // Wind impact
  if (region.windAnomalyPct < -5) {
    parts.push(`Wind generation is reduced (${region.windAnomalyPct}%)`);
  } else if (region.windAnomalyPct > 10) {
    parts.push(`Wind generation is strong (+${region.windAnomalyPct}%)`);
  }

  // No signal case
  if (parts.length === 0) {
    return 'Weather conditions are neutral with limited gas impact.';
  }

  // Final explanation
  return `${parts.join(' → ')} → Higher gas consumption expected`;
}

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
}