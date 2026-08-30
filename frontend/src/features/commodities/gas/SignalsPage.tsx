import { useEffect, useMemo, useState } from "react";
import { fetchGasLatest } from "./gasApi";

type StorageData = {
  report_date: string;
  total_bcf: number | null;
  change_bcf: number | null;
  five_year_avg_bcf: number | null;
  surplus_vs_five_year_avg_bcf: number | null;
  surplus_vs_year_ago_bcf: number | null;
  storage_season: string | null;
};

type SignalData = {
  signal_date: string;
  region: string;
  signal_type: string;
  direction: string;
  score: number | null;
  confidence: string | number | null;
  explanation: string | null;
  source_system: string | null;
  created_at: string | null;
};

type LatestResponse = {
  storage: StorageData | null;
  signal: SignalData | null;
};

type SignalTone = "bullish" | "bearish" | "neutral";

export default function SignalsPage() {
  const [data, setData] = useState<LatestResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadSignals() {
      try {
        setLoading(true);
        setError(null);

        const result = await fetchGasLatest();
        setData(result);
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Failed to load gas signals"
        );
      } finally {
        setLoading(false);
      }
    }

    loadSignals();
  }, []);

  const signal = data?.signal ?? null;
  const storage = data?.storage ?? null;

  const tone = getSignalTone(signal?.direction);
  const scorePercent = clampScore(signal?.score);
  const confidenceLabel = formatConfidence(signal?.confidence);

  const summary = useMemo(() => {
    return buildSignalSummary(signal, storage);
  }, [signal, storage]);

  if (loading) {
    return <div className="gas-status">Loading gas signals...</div>;
  }

  if (error) {
    return <div className="gas-status gas-status--error">Error: {error}</div>;
  }

  if (!signal) {
    return (
      <div className="gas-status gas-status--error">
        No gas signal data found.
      </div>
    );
  }

  return (
    <div className="signals-dashboard">
      <section className="signals-hero">
        <div>
          <p className="gas-kicker">Signal Intelligence</p>
          <h2>Natural Gas Signals</h2>
          <p>
            This panel shows the current model direction, score, confidence and
            explanation for the gas market, based on the latest available
            storage and signal logic.
          </p>
        </div>

        <div className={`signals-bias-card signals-bias-card--${tone}`}>
          <span>Current Bias</span>
          <strong>{formatDirection(signal.direction)}</strong>
          <small>{signal.signal_type ?? "Market signal"}</small>
        </div>
      </section>

      <section className="signals-metric-grid">
        <SignalMetric
          label="Direction"
          value={formatDirection(signal.direction)}
          subtext="Current model bias"
          tone={tone}
        />

        <SignalMetric
          label="Score"
          value={formatScore(signal.score)}
          subtext="Signal strength"
          tone={tone}
        />

        <SignalMetric
          label="Confidence"
          value={confidenceLabel}
          subtext="Model confidence level"
          tone={getConfidenceTone(signal.confidence)}
        />

        <SignalMetric
          label="Signal Date"
          value={formatDate(signal.signal_date)}
          subtext={signal.region || "Lower 48"}
        />

        <SignalMetric
          label="Latest Storage"
          value={formatBcf(storage?.total_bcf)}
          subtext={storage ? formatDate(storage.report_date) : "No storage row"}
        />

        <SignalMetric
          label="Vs 5Y Average"
          value={formatSignedBcf(storage?.surplus_vs_five_year_avg_bcf)}
          subtext={getFiveYearText(storage?.surplus_vs_five_year_avg_bcf)}
          tone={getSurplusTone(storage?.surplus_vs_five_year_avg_bcf)}
        />
      </section>

      <section className="signals-layout">
        <div className="gas-card signals-main-card">
          <div className="gas-card-header">
            <div>
              <h2>Signal Strength</h2>
              <p>
                Visual reading of the current model score and directional bias.
              </p>
            </div>
          </div>

          <div className="signals-strength-panel">
            <div className="signals-strength-header">
              <div>
                <span>Model score</span>
                <strong>{formatScore(signal.score)}</strong>
              </div>

              <div className={`signals-direction-pill signals-direction-pill--${tone}`}>
                {formatDirection(signal.direction)}
              </div>
            </div>

            <div className="signals-strength-track">
              <div
                className={`signals-strength-fill signals-strength-fill--${tone}`}
                style={{ width: `${scorePercent}%` }}
              />
            </div>

            <div className="signals-strength-scale">
              <span>Weak</span>
              <span>Moderate</span>
              <span>Strong</span>
            </div>

            <div className="signals-summary-box">
              <p>Model Summary</p>
              <span>{summary}</span>
            </div>

            <div className="signals-explanation-box">
              <p>Explanation</p>
              <span>{signal.explanation || "No explanation provided."}</span>
            </div>
          </div>
        </div>

        <aside className="gas-card signals-side-card">
          <div className="gas-card-header">
            <div>
              <h2>Signal Read</h2>
              <p>Key facts behind the current model output.</p>
            </div>
          </div>

          <div className="signals-read-list">
            <SignalReadItem
              label="Direction"
              value={formatDirection(signal.direction)}
              tone={tone}
            />

            <SignalReadItem
              label="Score"
              value={formatScore(signal.score)}
              tone={tone}
            />

            <SignalReadItem
              label="Confidence"
              value={confidenceLabel}
              tone={getConfidenceTone(signal.confidence)}
            />

            <SignalReadItem
              label="Signal type"
              value={signal.signal_type || "—"}
            />

            <SignalReadItem
              label="Source"
              value={signal.source_system || "—"}
            />

            <SignalReadItem
              label="Storage season"
              value={formatSeason(storage?.storage_season)}
            />
          </div>

          <div className="signals-context-box">
            <p>Context</p>
            <span>
              {buildContextText(storage)}
            </span>
          </div>
        </aside>
      </section>
    </div>
  );
}

function SignalMetric({
  label,
  value,
  subtext,
  tone = "neutral",
}: {
  label: string;
  value: string;
  subtext: string;
  tone?: SignalTone;
}) {
  return (
    <div className={`signals-metric signals-metric--${tone}`}>
      <p>{label}</p>
      <strong>{value}</strong>
      <span>{subtext}</span>
    </div>
  );
}

function SignalReadItem({
  label,
  value,
  tone = "neutral",
}: {
  label: string;
  value: string;
  tone?: SignalTone;
}) {
  return (
    <div className="signals-read-item">
      <span>{label}</span>
      <strong className={`signals-value--${tone}`}>{value}</strong>
    </div>
  );
}

function getSignalTone(direction: string | null | undefined): SignalTone {
  const value = String(direction ?? "").toLowerCase();

  if (value.includes("bull")) return "bullish";
  if (value.includes("bear")) return "bearish";
  return "neutral";
}

function getConfidenceTone(
  confidence: string | number | null | undefined
): SignalTone {
  if (confidence === null || confidence === undefined) return "neutral";

  if (typeof confidence === "number") {
    if (confidence >= 70) return "bullish";
    if (confidence <= 30) return "bearish";
    return "neutral";
  }

  const value = String(confidence).toLowerCase();

  if (value.includes("high")) return "bullish";
  if (value.includes("low")) return "bearish";
  return "neutral";
}

function getSurplusTone(value: number | null | undefined): SignalTone {
  if (value === null || value === undefined) return "neutral";
  if (value > 0) return "bearish";
  if (value < 0) return "bullish";
  return "neutral";
}

function formatDirection(value: string | null | undefined) {
  if (!value) return "Neutral";

  return value.charAt(0).toUpperCase() + value.slice(1).toLowerCase();
}

function formatScore(value: number | null | undefined) {
  if (value === null || value === undefined) return "0";
  return value.toLocaleString(undefined, { maximumFractionDigits: 0 });
}

function clampScore(value: number | null | undefined) {
  if (value === null || value === undefined) return 0;
  return Math.max(0, Math.min(100, value));
}

function formatConfidence(value: string | number | null | undefined) {
  if (value === null || value === undefined) return "Unknown";

  if (typeof value === "number") {
    return `${value.toLocaleString(undefined, {
      maximumFractionDigits: 0,
    })}%`;
  }

  return value.charAt(0).toUpperCase() + value.slice(1).toLowerCase();
}

function formatDate(value: string | null | undefined) {
  if (!value) return "—";

  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
}

function formatBcf(value: number | null | undefined) {
  if (value === null || value === undefined) return "—";

  return `${value.toLocaleString(undefined, {
    maximumFractionDigits: 1,
  })} Bcf`;
}

function formatSignedBcf(value: number | null | undefined) {
  if (value === null || value === undefined) return "—";

  const sign = value > 0 ? "+" : "";

  return `${sign}${value.toLocaleString(undefined, {
    maximumFractionDigits: 1,
  })} Bcf`;
}

function getFiveYearText(value: number | null | undefined) {
  if (value === null || value === undefined) return "No 5Y comparison";
  if (value > 0) return "Above 5Y average";
  if (value < 0) return "Below 5Y average";
  return "In line with 5Y average";
}

function formatSeason(value: string | null | undefined) {
  if (!value) return "—";

  return value
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function buildSignalSummary(
  signal: SignalData | null,
  storage: StorageData | null
) {
  if (!signal) return "No signal summary available.";

  const direction = formatDirection(signal.direction);
  const score = formatScore(signal.score);
  const confidence = formatConfidence(signal.confidence);
  const storageCompare = storage?.surplus_vs_five_year_avg_bcf;

  if (storageCompare === null || storageCompare === undefined) {
    return `${direction} signal with score ${score} and ${confidence.toLowerCase()} confidence. No storage comparison against the 5-year average is currently available.`;
  }

  if (storageCompare > 0) {
    return `${direction} signal with score ${score} and ${confidence.toLowerCase()} confidence. Storage is above the 5-year average, which usually adds bearish pressure unless demand or LNG strength offsets it.`;
  }

  if (storageCompare < 0) {
    return `${direction} signal with score ${score} and ${confidence.toLowerCase()} confidence. Storage is below the 5-year average, which usually supports a more bullish market structure.`;
  }

  return `${direction} signal with score ${score} and ${confidence.toLowerCase()} confidence. Storage is close to the 5-year average, so the market baseline is relatively balanced.`;
}

function buildContextText(storage: StorageData | null) {
  if (!storage) {
    return "No supporting storage context is currently available.";
  }

  const total = formatBcf(storage.total_bcf);
  const change = formatSignedBcf(storage.change_bcf);
  const fiveYear = formatSignedBcf(storage.surplus_vs_five_year_avg_bcf);
  const season = formatSeason(storage.storage_season);

  return `Latest Lower 48 storage is ${total}, with a weekly change of ${change}. The market is ${fiveYear} versus the 5-year average. Current season: ${season}.`;
}