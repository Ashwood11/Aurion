import { useEffect, useMemo, useState } from "react";
import { fetchGasLngLatest, fetchGasLngMonthly } from "./gasApi";

type GasLngRow = {
  month: string;
  region: string;
  lng_exports_bcf: number | null;
  lng_imports_bcf: number | null;
  net_lng_exports_bcf: number | null;
  lng_exports_bcfd: number | null;
  lng_imports_bcfd: number | null;
  net_lng_exports_bcfd: number | null;
  source_system: string | null;
  source_series: string | null;
  ingested_at: string | null;
};

function formatNumber(value: number | null | undefined, digits = 1) {
  if (value === null || value === undefined) return "—";

  return Number(value).toLocaleString("en-GB", {
    minimumFractionDigits: digits,
    maximumFractionDigits: digits,
  });
}

function formatMonth(value: string | null | undefined) {
  if (!value) return "—";

  return new Date(value).toLocaleDateString("en-GB", {
    month: "short",
    year: "numeric",
  });
}

function getLngSignal(latest: GasLngRow | null) {
  const netExports = latest?.net_lng_exports_bcfd;

  if (netExports === null || netExports === undefined) {
    return {
      label: "No signal",
      tone: "neutral",
      score: "—",
      text: "No LNG data has been loaded yet.",
    };
  }

  if (netExports >= 15) {
    return {
      label: "Bullish gas pressure",
      tone: "bullish",
      score: "High",
      text: "LNG export demand is pulling a large amount of gas out of the domestic market.",
    };
  }

  if (netExports >= 8) {
    return {
      label: "Moderate export pressure",
      tone: "neutral",
      score: "Medium",
      text: "LNG exports are meaningful, but not strong enough to dominate the market alone.",
    };
  }

  return {
    label: "Weak LNG pressure",
    tone: "bearish",
    score: "Low",
    text: "Lower LNG export flow reduces pressure on domestic gas supply.",
  };
}

function calculateChange(rows: GasLngRow[]) {
  if (rows.length < 2) return null;

  const latest = rows[0]?.net_lng_exports_bcfd;
  const previous = rows[1]?.net_lng_exports_bcfd;

  if (latest === null || latest === undefined || previous === null || previous === undefined) {
    return null;
  }

  return latest - previous;
}

export default function GasLng() {
  const [latest, setLatest] = useState<GasLngRow | null>(null);
  const [rows, setRows] = useState<GasLngRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const signal = getLngSignal(latest);

  const monthChange = useMemo(() => calculateChange(rows), [rows]);

  useEffect(() => {
    async function loadLng() {
      try {
        setLoading(true);
        setError(null);

        const latestJson = await fetchGasLngLatest();
        const monthlyJson = await fetchGasLngMonthly(24);

        setLatest(latestJson ?? null);
        setRows(monthlyJson.rows ?? []);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to load LNG data.");
      } finally {
        setLoading(false);
      }
    }

    loadLng();
  }, []);

  if (loading) {
    return (
      <section className="lng-page-card">
        <div className="lng-loading">
          <span className="lng-loading-dot" />
          Loading LNG market data...
        </div>
      </section>
    );
  }

  if (error) {
    return (
      <section className="lng-page-card">
        <div className="lng-error-card">
          <h2>LNG</h2>
          <p>{error}</p>
        </div>
      </section>
    );
  }

  return (
    <section className="lng-page-card">
      <div className="lng-hero">
        <div>
          <div className="lng-eyebrow">Natural Gas / LNG</div>
          <h2>LNG Market Flow</h2>
          <p>
            Tracks liquefied natural gas exports, imports, and net export pressure
            against the U.S. gas market.
          </p>
        </div>

        <div className="lng-hero-side">
          <span className="lng-source-pill">EIA Monthly</span>
          <strong>{formatMonth(latest?.month)}</strong>
          <small>{latest?.region ?? "United States"}</small>
        </div>
      </div>

      <div className="lng-dashboard-grid">
        <article className="lng-primary-metric">
          <span>Net LNG exports</span>
          <strong>{formatNumber(latest?.net_lng_exports_bcfd)} Bcf/d</strong>
          <p>{formatNumber(latest?.net_lng_exports_bcf)} Bcf monthly total</p>

          <div className="lng-change-row">
            <span>Month change</span>
            <strong>
              {monthChange === null
                ? "—"
                : `${monthChange >= 0 ? "+" : ""}${formatNumber(monthChange)} Bcf/d`}
            </strong>
          </div>
        </article>

        <article className="lng-metric-card">
          <span>LNG exports</span>
          <strong>{formatNumber(latest?.lng_exports_bcf)} Bcf</strong>
          <p>{formatNumber(latest?.lng_exports_bcfd)} Bcf/d</p>
        </article>

        <article className="lng-metric-card">
          <span>LNG imports</span>
          <strong>{formatNumber(latest?.lng_imports_bcf)} Bcf</strong>
          <p>{formatNumber(latest?.lng_imports_bcfd)} Bcf/d</p>
        </article>

        <article className={`lng-signal-card lng-signal-${signal.tone}`}>
          <div>
            <span>LNG pressure signal</span>
            <strong>{signal.label}</strong>
            <p>{signal.text}</p>
          </div>

          <div className="lng-signal-score">
            <small>Pressure</small>
            <b>{signal.score}</b>
          </div>
        </article>
      </div>

      <div className="lng-table-card">
        <div className="lng-table-header">
          <div>
            <h3>Monthly LNG history</h3>
            <p>Latest 24 monthly records, newest first.</p>
          </div>

          <span>{rows.length} rows</span>
        </div>

        <div className="lng-table-shell">
          <table className="lng-data-table">
            <thead>
              <tr>
                <th>Month</th>
                <th>Exports</th>
                <th>Exports / day</th>
                <th>Imports</th>
                <th>Imports / day</th>
                <th>Net / day</th>
              </tr>
            </thead>

            <tbody>
              {rows.map((row) => (
                <tr key={`${row.region}-${row.month}`}>
                  <td>
                    <strong>{formatMonth(row.month)}</strong>
                  </td>
                  <td>{formatNumber(row.lng_exports_bcf)} Bcf</td>
                  <td>{formatNumber(row.lng_exports_bcfd)} Bcf/d</td>
                  <td>{formatNumber(row.lng_imports_bcf)} Bcf</td>
                  <td>{formatNumber(row.lng_imports_bcfd)} Bcf/d</td>
                  <td>
                    <span className="lng-net-pill">
                      {formatNumber(row.net_lng_exports_bcfd)} Bcf/d
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}