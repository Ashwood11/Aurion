import { useEffect, useMemo, useState } from "react";
import { fetchGasConsumption } from "./gasApi";

type GasConsumptionRow = {
  month: string;
  region: string;
  total_consumption_bcf: number | null;
  residential_bcf: number | null;
  commercial_bcf: number | null;
  industrial_bcf: number | null;
  electric_power_bcf: number | null;
};

type SectorKey =
  | "residential_bcf"
  | "commercial_bcf"
  | "industrial_bcf"
  | "electric_power_bcf";

const sectors: {
  key: SectorKey;
  label: string;
  description: string;
}[] = [
  {
    key: "residential_bcf",
    label: "Residential",
    description: "Heating, cooking and household gas demand.",
  },
  {
    key: "commercial_bcf",
    label: "Commercial",
    description: "Shops, offices, public buildings and services.",
  },
  {
    key: "industrial_bcf",
    label: "Industrial",
    description: "Factories, manufacturing and process heat.",
  },
  {
    key: "electric_power_bcf",
    label: "Electric Power",
    description: "Gas burned by power stations for electricity.",
  },
];

export default function GasConsumption() {
  const [rows, setRows] = useState<GasConsumptionRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadConsumption() {
      try {
        setLoading(true);
        setError(null);

        const data = await fetchGasConsumption(240);
        setRows(data.rows ?? []);
      } catch (err) {
        setError(
          err instanceof Error
            ? err.message
            : "Failed to load consumption data"
        );
      } finally {
        setLoading(false);
      }
    }

    loadConsumption();
  }, []);

  const latest = rows[0];
  const previous = rows[1];

  const monthChange = useMemo(() => {
    if (!latest?.total_consumption_bcf || !previous?.total_consumption_bcf) {
      return null;
    }

    return latest.total_consumption_bcf - previous.total_consumption_bcf;
  }, [latest, previous]);

  const strongestSector = useMemo(() => {
    if (!latest) return null;

    return sectors
      .map((sector) => ({
        ...sector,
        value: latest[sector.key] ?? 0,
      }))
      .sort((a, b) => b.value - a.value)[0];
  }, [latest]);

  if (loading) {
    return <div className="gas-status">Loading gas consumption data...</div>;
  }

  if (error) {
    return <div className="gas-status gas-status--error">Error: {error}</div>;
  }

  if (rows.length === 0) {
    return (
      <div className="gas-status gas-status--error">
        No gas consumption rows found. Check that gas.consumption_monthly has
        data and that the backend is connected to the correct database.
      </div>
    );
  }

  return (
    <div className="gas-consumption-page">
      <div className="gas-consumption-hero">
        <div>
          <p className="gas-kicker">Demand Intelligence</p>
          <h2>Gas Consumption</h2>
          <p>
            Monthly US natural gas demand split by sector. This helps AURION
            understand whether demand pressure is coming from homes, industry,
            power generation or commercial use.
          </p>
        </div>

        <div className="gas-consumption-latest">
          <span>Latest Report</span>
          <strong>{formatMonth(latest.month)}</strong>
          <small>{latest.region}</small>
        </div>
      </div>

      <div className="gas-consumption-metrics">
        <MetricCard
          label="Latest Total Demand"
          value={formatBcf(latest.total_consumption_bcf)}
          subtext="All sectors combined"
        />

        <MetricCard
          label="Month-on-Month Change"
          value={monthChange === null ? "—" : formatSignedBcf(monthChange)}
          subtext={getChangeLabel(monthChange)}
          variant={
            monthChange === null ? "neutral" : monthChange > 0 ? "bullish" : "bearish"
          }
        />

        <MetricCard
          label="Largest Demand Sector"
          value={strongestSector?.label ?? "—"}
          subtext={
            strongestSector
              ? formatBcf(strongestSector.value)
              : "No sector data available"
          }
        />

        <MetricCard
          label="Rows Loaded"
          value={rows.length.toString()}
          subtext="Monthly records available"
        />
      </div>

      <div className="gas-consumption-layout">
        <div className="gas-card gas-consumption-sector-card">
          <div className="gas-card-header">
            <div>
              <h2>Latest Sector Split</h2>
              <p>How the latest monthly demand is distributed.</p>
            </div>
          </div>

          <div className="gas-sector-list">
            {sectors.map((sector) => {
              const value = latest[sector.key] ?? 0;
              const total = latest.total_consumption_bcf ?? 0;
              const percentage = total > 0 ? (value / total) * 100 : 0;

              return (
                <div className="gas-sector-row" key={sector.key}>
                  <div className="gas-sector-row__top">
                    <div>
                      <strong>{sector.label}</strong>
                      <span>{sector.description}</span>
                    </div>

                    <em>{formatBcf(value)}</em>
                  </div>

                  <div className="gas-sector-bar">
                    <div style={{ width: `${percentage}%` }} />
                  </div>

                  <small>{percentage.toFixed(1)}% of total demand</small>
                </div>
              );
            })}
          </div>
        </div>

        <div className="gas-card gas-consumption-table-card">
          <div className="gas-card-header">
            <div>
              <h2>Monthly History</h2>
              <p>Raw monthly consumption records from the database.</p>
            </div>
          </div>

          <div className="gas-consumption-table-wrap">
            <table className="gas-data-table gas-consumption-table">
              <thead>
                <tr>
                  <th>Month</th>
                  <th>Region</th>
                  <th>Total</th>
                  <th>Residential</th>
                  <th>Commercial</th>
                  <th>Industrial</th>
                  <th>Electric Power</th>
                </tr>
              </thead>

              <tbody>
                {rows.map((row) => (
                  <tr key={`${row.region}-${row.month}`}>
                    <td>
                      <strong>{formatMonth(row.month)}</strong>
                    </td>
                    <td>{row.region}</td>
                    <td>{formatBcf(row.total_consumption_bcf)}</td>
                    <td>{formatBcf(row.residential_bcf)}</td>
                    <td>{formatBcf(row.commercial_bcf)}</td>
                    <td>{formatBcf(row.industrial_bcf)}</td>
                    <td>{formatBcf(row.electric_power_bcf)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}

function MetricCard({
  label,
  value,
  subtext,
  variant = "neutral",
}: {
  label: string;
  value: string;
  subtext: string;
  variant?: "bullish" | "bearish" | "neutral";
}) {
  return (
    <div className={`gas-consumption-metric gas-consumption-metric--${variant}`}>
      <p>{label}</p>
      <strong>{value}</strong>
      <span>{subtext}</span>
    </div>
  );
}

function formatBcf(value: number | null | undefined) {
  if (value === null || value === undefined) return "—";

  return `${value.toLocaleString(undefined, {
    maximumFractionDigits: 1,
  })} Bcf`;
}

function formatSignedBcf(value: number) {
  const sign = value > 0 ? "+" : "";

  return `${sign}${value.toLocaleString(undefined, {
    maximumFractionDigits: 1,
  })} Bcf`;
}

function formatMonth(value: string) {
  return new Intl.DateTimeFormat("en-GB", {
    month: "short",
    year: "numeric",
  }).format(new Date(value));
}

function getChangeLabel(value: number | null) {
  if (value === null) return "No previous month available";
  if (value > 0) return "Demand increased from previous month";
  if (value < 0) return "Demand fell from previous month";
  return "No change from previous month";
}