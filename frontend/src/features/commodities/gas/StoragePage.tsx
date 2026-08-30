import { useEffect, useMemo, useState } from "react";
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { fetchGasHistory } from "./gasApi";

type StorageRow = {
  report_date: string;
  total_bcf: number | null;
  change_bcf: number | null;
  year_ago_bcf: number | null;
  five_year_avg_bcf: number | null;
  surplus_vs_year_ago_bcf: number | null;
  surplus_vs_five_year_avg_bcf: number | null;
  storage_week: number | null;
  storage_season: string | null;
};

type PressureDirection = "bullish" | "bearish" | "neutral";

export default function StoragePage() {
  const [rows, setRows] = useState<StorageRow[]>([]);
  const [limit, setLimit] = useState(104);
  const [showFiveYearAvg, setShowFiveYearAvg] = useState(true);
  const [showYearAgo, setShowYearAgo] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadStorage() {
      try {
        setLoading(true);
        setError(null);

        const data = await fetchGasHistory(limit);
        setRows(data ?? []);
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Failed to load storage data"
        );
      } finally {
        setLoading(false);
      }
    }

    loadStorage();
  }, [limit]);

  const latest = rows[0];
  const previous = rows[1];

  const chartData = useMemo(() => {
    return [...rows].reverse();
  }, [rows]);

  const pressure = getStoragePressure(latest);
  const pressureLabel = getPressureLabel(pressure);

  const loadedRangeMax = useMemo(() => {
    return Math.max(...rows.map((row) => row.total_bcf ?? 0));
  }, [rows]);

  const rangePosition =
    latest?.total_bcf && loadedRangeMax > 0
      ? Math.min((latest.total_bcf / loadedRangeMax) * 100, 100)
      : 0;

  if (loading) {
    return <div className="gas-status">Loading gas storage data...</div>;
  }

  if (error) {
    return <div className="gas-status gas-status--error">Error: {error}</div>;
  }

  if (!latest) {
    return (
      <div className="gas-status gas-status--error">
        No gas storage records found.
      </div>
    );
  }

  return (
    <div className="storage-dashboard">
      <section className="storage-hero">
        <div>
          <p className="gas-kicker">Storage Intelligence</p>
          <h2>Lower 48 Gas Storage</h2>
          <p>
            Weekly working gas in underground storage. This is one of the most
            important baseline signals for natural gas because it shows whether
            the market is carrying surplus or shortage pressure.
          </p>
        </div>

        <div className={`storage-pressure-card storage-pressure-card--${pressure}`}>
          <span>Market Pressure</span>
          <strong>{pressureLabel}</strong>
          <small>{buildPressureSentence(latest)}</small>
        </div>
      </section>

      <section className="storage-metric-grid">
        <StorageMetric
          label="Latest Storage"
          value={formatBcf(latest.total_bcf)}
          subtext={formatDate(latest.report_date)}
        />

        <StorageMetric
          label="Weekly Change"
          value={formatSignedBcf(latest.change_bcf)}
          subtext={getWeeklyChangeText(latest.change_bcf)}
          direction={getChangeDirection(latest.change_bcf)}
        />

        <StorageMetric
          label="Vs 5-Year Average"
          value={formatSignedBcf(latest.surplus_vs_five_year_avg_bcf)}
          subtext={getFiveYearText(latest.surplus_vs_five_year_avg_bcf)}
          direction={pressure}
        />

        <StorageMetric
          label="Vs Year Ago"
          value={formatSignedBcf(latest.surplus_vs_year_ago_bcf)}
          subtext={getYearAgoText(latest.surplus_vs_year_ago_bcf)}
          direction={getSurplusDirection(latest.surplus_vs_year_ago_bcf)}
        />

        <StorageMetric
          label="5-Year Average"
          value={formatBcf(latest.five_year_avg_bcf)}
          subtext="Seasonal benchmark"
        />

        <StorageMetric
          label="Storage Season"
          value={formatSeason(latest.storage_season)}
          subtext={`Week ${latest.storage_week ?? "—"}`}
        />
      </section>

      <section className="storage-layout">
        <div className="gas-card storage-chart-card">
          <div className="gas-card-header">
            <div>
              <h2>Storage Trend</h2>
              <p>Current storage compared with historical benchmarks.</p>
            </div>

            <div className="gas-chart-controls">
              <button
                onClick={() => setLimit(52)}
                className={limit === 52 ? "is-active" : ""}
              >
                1Y
              </button>

              <button
                onClick={() => setLimit(104)}
                className={limit === 104 ? "is-active" : ""}
              >
                2Y
              </button>

              <button
                onClick={() => setLimit(200)}
                className={limit === 200 ? "is-active" : ""}
              >
                4Y
              </button>

              <button
                onClick={() => setShowFiveYearAvg((value) => !value)}
                className={showFiveYearAvg ? "is-active" : ""}
              >
                5Y Avg
              </button>

              <button
                onClick={() => setShowYearAgo((value) => !value)}
                className={showYearAgo ? "is-active" : ""}
              >
                Year Ago
              </button>
            </div>
          </div>

          <div className="storage-chart">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
                <XAxis
                  dataKey="report_date"
                  stroke="#64748b"
                  tickFormatter={formatShortDate}
                  minTickGap={28}
                />
                <YAxis stroke="#64748b" />
                <Tooltip
                  contentStyle={{
                    background: "#020617",
                    border: "1px solid #1e293b",
                    borderRadius: "12px",
                    color: "#e2e8f0",
                  }}
                  labelFormatter={(value) => formatDate(String(value))}
                  formatter={(value: any, name: any) => [
                    `${Number(value).toLocaleString()} Bcf`,
                    name,
                  ]}
                />

                <Line
                  type="monotone"
                  dataKey="total_bcf"
                  name="Storage"
                  stroke="#22d3ee"
                  strokeWidth={2.4}
                  dot={false}
                />

                {showFiveYearAvg && (
                  <Line
                    type="monotone"
                    dataKey="five_year_avg_bcf"
                    name="5-Year Avg"
                    stroke="#f59e0b"
                    strokeWidth={2}
                    dot={false}
                  />
                )}

                {showYearAgo && (
                  <Line
                    type="monotone"
                    dataKey="year_ago_bcf"
                    name="Year Ago"
                    stroke="#a78bfa"
                    strokeWidth={2}
                    dot={false}
                  />
                )}
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <aside className="gas-card storage-side-panel">
          <div className="gas-card-header">
            <div>
              <h2>Latest Read</h2>
              <p>Quick interpretation of the newest storage report.</p>
            </div>
          </div>

          <div className="storage-range-box">
            <div className="storage-range-box__top">
              <span>Range Position</span>
              <strong>{rangePosition.toFixed(0)}%</strong>
            </div>

            <div className="storage-range-track">
              <div style={{ width: `${rangePosition}%` }} />
            </div>

            <p>
              Position within the loaded history range. This is not storage
              capacity, but it helps show where the latest value sits relative
              to the recent dataset.
            </p>
          </div>

          <div className="storage-read-list">
            <StorageReadItem
              label="Latest report"
              value={formatDate(latest.report_date)}
            />

            <StorageReadItem
              label="Previous report"
              value={previous ? formatDate(previous.report_date) : "—"}
            />

            <StorageReadItem
              label="Current season"
              value={formatSeason(latest.storage_season)}
            />

            <StorageReadItem
              label="Current bias"
              value={pressureLabel}
              direction={pressure}
            />
          </div>

          <div className="storage-explanation">
            <p>Interpretation</p>
            <span>{buildDetailedExplanation(latest)}</span>
          </div>
        </aside>
      </section>

      <section className="gas-card storage-table-card">
        <div className="gas-card-header">
          <div>
            <h2>Weekly Storage History</h2>
            <p>Latest reported Lower 48 storage entries.</p>
          </div>
        </div>

        <div className="storage-table-wrap">
          <table className="gas-data-table storage-table">
            <thead>
              <tr>
                <th>Report Date</th>
                <th>Total Storage</th>
                <th>Weekly Change</th>
                <th>Year Ago</th>
                <th>5-Year Avg</th>
                <th>Vs 5Y Avg</th>
                <th>Season</th>
              </tr>
            </thead>

            <tbody>
              {rows.slice(0, 80).map((row) => (
                <tr key={row.report_date}>
                  <td>
                    <strong>{formatDate(row.report_date)}</strong>
                  </td>
                  <td>{formatBcf(row.total_bcf)}</td>
                  <td className={getValueClass(row.change_bcf)}>
                    {formatSignedBcf(row.change_bcf)}
                  </td>
                  <td>{formatBcf(row.year_ago_bcf)}</td>
                  <td>{formatBcf(row.five_year_avg_bcf)}</td>
                  <td className={getValueClass(row.surplus_vs_five_year_avg_bcf)}>
                    {formatSignedBcf(row.surplus_vs_five_year_avg_bcf)}
                  </td>
                  <td>{formatSeason(row.storage_season)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

function StorageMetric({
  label,
  value,
  subtext,
  direction = "neutral",
}: {
  label: string;
  value: string;
  subtext: string;
  direction?: PressureDirection;
}) {
  return (
    <div className={`storage-metric storage-metric--${direction}`}>
      <p>{label}</p>
      <strong>{value}</strong>
      <span>{subtext}</span>
    </div>
  );
}

function StorageReadItem({
  label,
  value,
  direction = "neutral",
}: {
  label: string;
  value: string;
  direction?: PressureDirection;
}) {
  return (
    <div className="storage-read-item">
      <span>{label}</span>
      <strong className={`storage-value--${direction}`}>{value}</strong>
    </div>
  );
}

function getStoragePressure(row: StorageRow | undefined): PressureDirection {
  const surplus = row?.surplus_vs_five_year_avg_bcf;

  if (surplus === null || surplus === undefined) return "neutral";
  if (surplus > 0) return "bearish";
  if (surplus < 0) return "bullish";

  return "neutral";
}

function getPressureLabel(direction: PressureDirection) {
  if (direction === "bearish") return "Bearish";
  if (direction === "bullish") return "Bullish";
  return "Neutral";
}

function getChangeDirection(value: number | null | undefined): PressureDirection {
  if (value === null || value === undefined) return "neutral";

  /*
    More storage added is usually bearish for price.
    More storage withdrawn is usually bullish for price.
  */
  if (value > 0) return "bearish";
  if (value < 0) return "bullish";

  return "neutral";
}

function getSurplusDirection(value: number | null | undefined): PressureDirection {
  if (value === null || value === undefined) return "neutral";
  if (value > 0) return "bearish";
  if (value < 0) return "bullish";

  return "neutral";
}

function getValueClass(value: number | null | undefined) {
  if (value === null || value === undefined) return "";

  if (value > 0) return "storage-table-value storage-table-value--positive";
  if (value < 0) return "storage-table-value storage-table-value--negative";

  return "storage-table-value";
}

function buildPressureSentence(row: StorageRow | undefined) {
  if (!row) return "No latest storage row available.";

  const surplus = row.surplus_vs_five_year_avg_bcf;

  if (surplus === null || surplus === undefined) {
    return "No 5-year comparison available.";
  }

  if (surplus > 0) {
    return `${formatBcf(surplus)} above the 5-year average.`;
  }

  if (surplus < 0) {
    return `${formatBcf(Math.abs(surplus))} below the 5-year average.`;
  }

  return "Storage is exactly in line with the 5-year average.";
}

function buildDetailedExplanation(row: StorageRow) {
  const total = formatBcf(row.total_bcf);
  const change = formatSignedBcf(row.change_bcf);
  const surplus = row.surplus_vs_five_year_avg_bcf;
  const season = formatSeason(row.storage_season).toLowerCase();

  if (surplus === null || surplus === undefined) {
    return `Latest Lower 48 storage is ${total}, with a weekly change of ${change}. No 5-year average comparison is available for this row.`;
  }

  if (surplus > 0) {
    return `Latest Lower 48 storage is ${total}, with a weekly change of ${change}. Storage is ${formatBcf(
      surplus
    )} above the 5-year average, which usually creates bearish pressure unless demand, LNG exports or weather tighten the market. Current season: ${season}.`;
  }

  if (surplus < 0) {
    return `Latest Lower 48 storage is ${total}, with a weekly change of ${change}. Storage is ${formatBcf(
      Math.abs(surplus)
    )} below the 5-year average, which usually creates bullish pressure if demand remains strong. Current season: ${season}.`;
  }

  return `Latest Lower 48 storage is ${total}, with a weekly change of ${change}. Storage is exactly aligned with the 5-year average, so the storage signal is neutral. Current season: ${season}.`;
}

function getWeeklyChangeText(value: number | null | undefined) {
  if (value === null || value === undefined) return "No weekly change available";
  if (value > 0) return "Injection into storage";
  if (value < 0) return "Withdrawal from storage";

  return "No weekly movement";
}

function getFiveYearText(value: number | null | undefined) {
  if (value === null || value === undefined) return "No 5-year comparison";
  if (value > 0) return "Above normal storage";
  if (value < 0) return "Below normal storage";

  return "In line with normal";
}

function getYearAgoText(value: number | null | undefined) {
  if (value === null || value === undefined) return "No year-ago comparison";
  if (value > 0) return "Higher than last year";
  if (value < 0) return "Lower than last year";

  return "Same as last year";
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

function formatDate(value: string | null | undefined) {
  if (!value) return "—";

  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
}

function formatShortDate(value: string) {
  return new Intl.DateTimeFormat("en-GB", {
    month: "short",
    year: "2-digit",
  }).format(new Date(value));
}

function formatSeason(value: string | null | undefined) {
  if (!value) return "—";

  return value
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}