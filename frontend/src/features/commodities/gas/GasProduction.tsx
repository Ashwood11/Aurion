import { useEffect, useMemo, useState } from "react";
import {
  fetchGasProductionLatest,
  fetchGasProductionMonthly,
} from "./gasApi";

type GasProductionRow = {
  month: string;
  region: string;
  dry_production_bcf: number | null;
  marketed_production_bcf: number | null;
  gross_withdrawals_bcf: number | null;
  dry_production_bcfd: number | null;
  marketed_production_bcfd: number | null;
  gross_withdrawals_bcfd: number | null;
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

function getProductionSignal(latest: GasProductionRow | null) {
  const dryBcfd = latest?.dry_production_bcfd;

  if (dryBcfd === null || dryBcfd === undefined) {
    return {
      label: "No signal",
      tone: "neutral",
      score: "—",
      text: "No production data has been loaded yet.",
    };
  }

  if (dryBcfd >= 105) {
    return {
      label: "Bearish supply pressure",
      tone: "bearish",
      score: "High",
      text: "High dry gas production adds more supply into the market and can weigh on prices unless demand is equally strong.",
    };
  }

  if (dryBcfd >= 95) {
    return {
      label: "Balanced supply flow",
      tone: "neutral",
      score: "Medium",
      text: "Production is strong but not extreme enough by itself to dominate the gas signal.",
    };
  }

  return {
    label: "Bullish supply pressure",
    tone: "bullish",
    score: "Low",
    text: "Lower production reduces new supply entering the system, which can support prices if demand remains firm.",
  };
}

function calculateMonthChange(rows: GasProductionRow[]) {
  if (rows.length < 2) return null;

  const latest = rows[0]?.dry_production_bcfd;
  const previous = rows[1]?.dry_production_bcfd;

  if (
    latest === null ||
    latest === undefined ||
    previous === null ||
    previous === undefined
  ) {
    return null;
  }

  return latest - previous;
}

export default function GasProduction() {
  const [latest, setLatest] = useState<GasProductionRow | null>(null);
  const [rows, setRows] = useState<GasProductionRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const signal = getProductionSignal(latest);

  const monthChange = useMemo(() => calculateMonthChange(rows), [rows]);

  useEffect(() => {
    async function loadProduction() {
      try {
        setLoading(true);
        setError(null);

        const latestJson = await fetchGasProductionLatest();
        const monthlyJson = await fetchGasProductionMonthly(24);

        setLatest(latestJson ?? null);
        setRows(monthlyJson.rows ?? []);
      } catch (err) {
        setError(
          err instanceof Error
            ? err.message
            : "Failed to load production data."
        );
      } finally {
        setLoading(false);
      }
    }

    loadProduction();
  }, []);

  if (loading) {
    return (
      <section className="production-page-card">
        <div className="production-loading">
          <span className="production-loading-dot" />
          Loading production data...
        </div>
      </section>
    );
  }

  if (error) {
    return (
      <section className="production-page-card">
        <div className="production-error-card">
          <h2>Production</h2>
          <p>{error}</p>
        </div>
      </section>
    );
  }

  return (
    <section className="production-page-card">
      <div className="production-hero">
        <div>
          <div className="production-eyebrow">Natural Gas / Production</div>
          <h2>Gas Production Flow</h2>
          <p>
            Tracks dry gas production, marketed production, and gross withdrawals
            to measure how much new supply is entering the U.S. gas system.
          </p>
        </div>

        <div className="production-hero-side">
          <span className="production-source-pill">EIA Monthly</span>
          <strong>{formatMonth(latest?.month)}</strong>
          <small>{latest?.region ?? "United States"}</small>
        </div>
      </div>

      <div className="production-dashboard-grid">
        <article className="production-primary-metric">
          <span>Dry production</span>
          <strong>{formatNumber(latest?.dry_production_bcfd)} Bcf/d</strong>
          <p>{formatNumber(latest?.dry_production_bcf)} Bcf monthly total</p>

          <div className="production-change-row">
            <span>Month change</span>
            <strong>
              {monthChange === null
                ? "—"
                : `${monthChange >= 0 ? "+" : ""}${formatNumber(
                    monthChange
                  )} Bcf/d`}
            </strong>
          </div>
        </article>

        <article className="production-metric-card">
          <span>Marketed production</span>
          <strong>{formatNumber(latest?.marketed_production_bcf)} Bcf</strong>
          <p>{formatNumber(latest?.marketed_production_bcfd)} Bcf/d</p>
        </article>

        <article className="production-metric-card">
          <span>Gross withdrawals</span>
          <strong>{formatNumber(latest?.gross_withdrawals_bcf)} Bcf</strong>
          <p>{formatNumber(latest?.gross_withdrawals_bcfd)} Bcf/d</p>
        </article>

        <article
          className={`production-signal-card production-signal-${signal.tone}`}
        >
          <div>
            <span>Production pressure signal</span>
            <strong>{signal.label}</strong>
            <p>{signal.text}</p>
          </div>

          <div className="production-signal-score">
            <small>Supply</small>
            <b>{signal.score}</b>
          </div>
        </article>
      </div>

      <div className="production-table-card">
        <div className="production-table-header">
          <div>
            <h3>Monthly production history</h3>
            <p>Latest 24 monthly records, newest first.</p>
          </div>

          <span>{rows.length} rows</span>
        </div>

        <div className="production-table-shell">
          <table className="production-data-table">
            <thead>
              <tr>
                <th>Month</th>
                <th>Dry production</th>
                <th>Dry / day</th>
                <th>Marketed</th>
                <th>Marketed / day</th>
                <th>Gross withdrawals / day</th>
              </tr>
            </thead>

            <tbody>
              {rows.map((row) => (
                <tr key={`${row.region}-${row.month}`}>
                  <td>
                    <strong>{formatMonth(row.month)}</strong>
                  </td>
                  <td>{formatNumber(row.dry_production_bcf)} Bcf</td>
                  <td>
                    <span className="production-flow-pill">
                      {formatNumber(row.dry_production_bcfd)} Bcf/d
                    </span>
                  </td>
                  <td>{formatNumber(row.marketed_production_bcf)} Bcf</td>
                  <td>{formatNumber(row.marketed_production_bcfd)} Bcf/d</td>
                  <td>{formatNumber(row.gross_withdrawals_bcfd)} Bcf/d</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}