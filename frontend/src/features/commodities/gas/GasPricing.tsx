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
import { fetchGasPriceDaily } from "./gasApi";

type PriceRow = {
  market: string;
  region: string;
  price_date: string;
  price_usd_per_mmbtu: number | null;
  change_usd: number | null;
  change_pct: number | null;
  data_status: string;
  source_system: string;
  source_series: string;
  ingested_at: string;
};

type PriceDirection = "bullish" | "bearish" | "neutral";

export default function PricePage() {
  const [rows, setRows] = useState<PriceRow[]>([]);
  const [limit, setLimit] = useState(365);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadPriceData() {
      try {
        setLoading(true);
        setError(null);

        const data = await fetchGasPriceDaily(limit);
        setRows(data.rows ?? []);
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Failed to load gas price data"
        );
      } finally {
        setLoading(false);
      }
    }

    loadPriceData();
  }, [limit]);

  const latest = rows[0];

  const chartData = useMemo(() => {
    return [...rows].reverse();
  }, [rows]);

  const priceStats = useMemo(() => {
    const values = rows
      .map((row) => row.price_usd_per_mmbtu)
      .filter((value): value is number => value !== null && value !== undefined);

    if (values.length === 0) {
      return {
        high: null,
        low: null,
        average: null,
      };
    }

    const high = Math.max(...values);
    const low = Math.min(...values);
    const average = values.reduce((sum, value) => sum + value, 0) / values.length;

    return {
      high,
      low,
      average,
    };
  }, [rows]);

  const direction = getPriceDirection(latest?.change_usd);

  if (loading) {
    return <div className="gas-status">Loading gas price data...</div>;
  }

  if (error) {
    return <div className="gas-status gas-status--error">Error: {error}</div>;
  }

  if (!latest) {
    return (
      <div className="gas-status gas-status--error">
        No gas price records found.
      </div>
    );
  }

  return (
    <div className="price-dashboard">
      <section className="price-hero">
        <div>
          <p className="gas-kicker">Price Intelligence</p>
          <h2>Henry Hub Daily Spot Price</h2>
          <p>
            Daily Henry Hub natural gas spot price in USD per MMBtu. This gives
            AURION a direct market-price layer to compare against storage,
            demand, weather and LNG pressure.
          </p>
        </div>

        <div className={`price-latest-card price-latest-card--${direction}`}>
          <span>Latest Price</span>
          <strong>{formatUsd(latest.price_usd_per_mmbtu)}</strong>
          <small>{formatDate(latest.price_date)}</small>
        </div>
      </section>

      <section className="price-metric-grid">
        <PriceMetric
          label="Daily Change"
          value={formatSignedUsd(latest.change_usd)}
          subtext={formatSignedPercent(latest.change_pct)}
          direction={direction}
        />

        <PriceMetric
          label="Loaded High"
          value={formatUsd(priceStats.high)}
          subtext={`${limit} record window`}
        />

        <PriceMetric
          label="Loaded Low"
          value={formatUsd(priceStats.low)}
          subtext={`${limit} record window`}
        />

        <PriceMetric
          label="Loaded Average"
          value={formatUsd(priceStats.average)}
          subtext="Simple average"
        />

        <PriceMetric
          label="Market"
          value={latest.market}
          subtext={latest.region}
        />
      </section>

      <section className="price-layout">
        <div className="gas-card price-chart-card">
          <div className="gas-card-header">
            <div>
              <h2>Price Trend</h2>
              <p>Daily Henry Hub spot price movement.</p>
            </div>

            <div className="gas-chart-controls">
              <button
                onClick={() => setLimit(90)}
                className={limit === 90 ? "is-active" : ""}
              >
                3M
              </button>

              <button
                onClick={() => setLimit(180)}
                className={limit === 180 ? "is-active" : ""}
              >
                6M
              </button>

              <button
                onClick={() => setLimit(365)}
                className={limit === 365 ? "is-active" : ""}
              >
                1Y
              </button>

              <button
                onClick={() => setLimit(730)}
                className={limit === 730 ? "is-active" : ""}
              >
                2Y
              </button>
            </div>
          </div>

          <div className="price-chart">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />

                <XAxis
                  dataKey="price_date"
                  stroke="#64748b"
                  tickFormatter={formatShortDate}
                  minTickGap={28}
                />

                <YAxis
                  stroke="#64748b"
                  tickFormatter={(value) => `$${value}`}
                />

                <Tooltip
                  contentStyle={{
                    background: "#020617",
                    border: "1px solid #1e293b",
                    borderRadius: "12px",
                    color: "#e2e8f0",
                  }}
                  labelFormatter={(value) => formatDate(String(value))}
                  formatter={(value: any) => [
                    `$${Number(value).toFixed(2)} / MMBtu`,
                    "Henry Hub",
                  ]}
                />

                <Line
                  type="monotone"
                  dataKey="price_usd_per_mmbtu"
                  name="Henry Hub"
                  stroke="#22d3ee"
                  strokeWidth={2.4}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <aside className="gas-card price-side-panel">
          <div className="gas-card-header">
            <div>
              <h2>Price Read</h2>
              <p>Latest market interpretation.</p>
            </div>
          </div>

          <div className="price-read-list">
            <PriceReadItem label="Latest date" value={formatDate(latest.price_date)} />
            <PriceReadItem label="Latest price" value={formatUsd(latest.price_usd_per_mmbtu)} />
            <PriceReadItem label="Daily move" value={formatSignedUsd(latest.change_usd)} direction={direction} />
            <PriceReadItem label="Daily %" value={formatSignedPercent(latest.change_pct)} direction={direction} />
            <PriceReadItem label="Source" value={latest.source_system} />
            <PriceReadItem label="Series" value={latest.source_series} />
          </div>

          <div className="price-explanation">
            <p>Interpretation</p>
            <span>{buildPriceExplanation(latest)}</span>
          </div>
        </aside>
      </section>

      <section className="gas-card price-table-card">
        <div className="gas-card-header">
          <div>
            <h2>Daily Price History</h2>
            <p>Latest Henry Hub spot price records from the database.</p>
          </div>
        </div>

        <div className="price-table-wrap">
          <table className="gas-data-table price-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Market</th>
                <th>Price</th>
                <th>Change</th>
                <th>Change %</th>
                <th>Status</th>
                <th>Source</th>
              </tr>
            </thead>

            <tbody>
              {rows.slice(0, 120).map((row) => {
                const rowDirection = getPriceDirection(row.change_usd);

                return (
                  <tr key={`${row.market}-${row.price_date}`}>
                    <td>
                      <strong>{formatDate(row.price_date)}</strong>
                    </td>
                    <td>{row.market}</td>
                    <td>{formatUsd(row.price_usd_per_mmbtu)}</td>
                    <td className={`price-table-value price-table-value--${rowDirection}`}>
                      {formatSignedUsd(row.change_usd)}
                    </td>
                    <td className={`price-table-value price-table-value--${rowDirection}`}>
                      {formatSignedPercent(row.change_pct)}
                    </td>
                    <td>{row.data_status}</td>
                    <td>{row.source_system}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

function PriceMetric({
  label,
  value,
  subtext,
  direction = "neutral",
}: {
  label: string;
  value: string;
  subtext: string;
  direction?: PriceDirection;
}) {
  return (
    <div className={`price-metric price-metric--${direction}`}>
      <p>{label}</p>
      <strong>{value}</strong>
      <span>{subtext}</span>
    </div>
  );
}

function PriceReadItem({
  label,
  value,
  direction = "neutral",
}: {
  label: string;
  value: string;
  direction?: PriceDirection;
}) {
  return (
    <div className="price-read-item">
      <span>{label}</span>
      <strong className={`price-value--${direction}`}>{value}</strong>
    </div>
  );
}

function getPriceDirection(value: number | null | undefined): PriceDirection {
  if (value === null || value === undefined) return "neutral";
  if (value > 0) return "bullish";
  if (value < 0) return "bearish";

  return "neutral";
}

function buildPriceExplanation(row: PriceRow) {
  const price = formatUsd(row.price_usd_per_mmbtu);
  const change = formatSignedUsd(row.change_usd);
  const percent = formatSignedPercent(row.change_pct);

  if (row.change_usd === null || row.change_usd === undefined) {
    return `Latest Henry Hub spot price is ${price}. No previous daily change is available for this record.`;
  }

  if (row.change_usd > 0) {
    return `Latest Henry Hub spot price is ${price}, up ${change} (${percent}) from the previous available trading day. Rising price action can confirm bullish pressure from storage, weather, LNG or supply-side stress.`;
  }

  if (row.change_usd < 0) {
    return `Latest Henry Hub spot price is ${price}, down ${change} (${percent}) from the previous available trading day. Falling price action can confirm bearish pressure from high storage, weak demand or loose supply.`;
  }

  return `Latest Henry Hub spot price is ${price}, unchanged from the previous available trading day.`;
}

function formatUsd(value: number | null | undefined) {
  if (value === null || value === undefined) return "—";

  return `$${value.toLocaleString(undefined, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
}

function formatSignedUsd(value: number | null | undefined) {
  if (value === null || value === undefined) return "—";

  const sign = value > 0 ? "+" : "";

  return `${sign}$${value.toLocaleString(undefined, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
}

function formatSignedPercent(value: number | null | undefined) {
  if (value === null || value === undefined) return "—";

  const sign = value > 0 ? "+" : "";

  return `${sign}${value.toLocaleString(undefined, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}%`;
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