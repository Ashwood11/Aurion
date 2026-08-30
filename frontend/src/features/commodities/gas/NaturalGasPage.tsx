import { useEffect, useMemo, useState } from "react";
import {
  ResponsiveContainer,
  LineChart,
  Line,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
} from "recharts";

import {
  fetchGasLatest,
  fetchGasHistory,
  fetchGasPriceDaily,
  fetchGasPriceLatest,
  fetchGasConsumption,
  fetchGasLngMonthly,
  fetchGasProductionMonthly,
} from "./gasApi";

type StorageRow = {
  report_date: string;
  total_bcf: number | string | null;
  change_bcf: number | string | null;
  five_year_avg_bcf: number | string | null;
  surplus_vs_five_year_avg_bcf: number | string | null;
  storage_season?: string | null;
};

type PriceRow = {
  price_date: string;
  price_usd_per_mmbtu: number | string | null;
  change_usd?: number | string | null;
  change_pct?: number | string | null;
};

type ConsumptionRow = {
  month?: string;
  report_month?: string;
  region: string;
  total_consumption_bcf: number | string | null;
  residential_bcf: number | string | null;
  commercial_bcf: number | string | null;
  industrial_bcf: number | string | null;
  electric_power_bcf: number | string | null;
};

type LngRow = {
  month: string;
  region: string;
  lng_exports_bcf: number | string | null;
  lng_imports_bcf: number | string | null;
  net_lng_exports_bcf: number | string | null;
  lng_exports_bcfd: number | string | null;
  lng_imports_bcfd: number | string | null;
  net_lng_exports_bcfd: number | string | null;
};

type ProductionRow = {
  month: string;
  region: string;
  dry_production_bcf: number | string | null;
  marketed_production_bcf: number | string | null;
  gross_withdrawals_bcf: number | string | null;
  dry_production_bcfd: number | string | null;
  marketed_production_bcfd: number | string | null;
  gross_withdrawals_bcfd: number | string | null;
};

type LatestGasResponse = {
  storage: StorageRow | null;
  signal: {
    direction?: string | null;
    confidence?: string | null;
    score?: number | string | null;
    explanation?: string | null;
    signal_date?: string | null;
  } | null;
};

type OverviewChartRow = {
  date: string;
  label: string;
  storage: number | null;
  fiveYearAvg: number | null;
  surplus: number | null;
  price: number | null;
};

function toNumber(value: number | string | null | undefined): number | null {
  if (value === null || value === undefined || value === "") return null;

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function formatNumber(value: number | string | null | undefined, digits = 1) {
  const num = toNumber(value);

  if (num === null) return "—";

  return num.toLocaleString("en-GB", {
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

function formatDate(value: string | null | undefined) {
  if (!value) return "—";

  return new Date(value).toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function getMonthKey(value: string | null | undefined) {
  if (!value) return "";

  const date = new Date(value);
  const year = date.getFullYear();
  const month = `${date.getMonth() + 1}`.padStart(2, "0");

  return `${year}-${month}`;
}

function buildStoragePriceChart(
  storageHistory: StorageRow[],
  priceRows: PriceRow[]
): OverviewChartRow[] {
  const sortedStorage = [...storageHistory]
    .filter((row) => row.report_date)
    .sort(
      (a, b) =>
        new Date(a.report_date).getTime() - new Date(b.report_date).getTime()
    );

  const sortedPrices = [...priceRows]
    .filter((row) => row.price_date)
    .sort(
      (a, b) =>
        new Date(a.price_date).getTime() - new Date(b.price_date).getTime()
    );

  let priceIndex = 0;
  let latestPrice: PriceRow | null = null;

  return sortedStorage.map((storage) => {
    const storageDate = new Date(storage.report_date).getTime();

    while (
      priceIndex < sortedPrices.length &&
      new Date(sortedPrices[priceIndex].price_date).getTime() <= storageDate
    ) {
      latestPrice = sortedPrices[priceIndex];
      priceIndex += 1;
    }

    return {
      date: storage.report_date,
      label: formatDate(storage.report_date),
      storage: toNumber(storage.total_bcf),
      fiveYearAvg: toNumber(storage.five_year_avg_bcf),
      surplus: toNumber(storage.surplus_vs_five_year_avg_bcf),
      price: toNumber(latestPrice?.price_usd_per_mmbtu),
    };
  });
}

function getPressureTone(value: number | null, bullishWhenHigh: boolean) {
  if (value === null) return "neutral";

  if (bullishWhenHigh) {
    if (value > 0) return "bullish";
    if (value < 0) return "bearish";
    return "neutral";
  }

  if (value > 0) return "bearish";
  if (value < 0) return "bullish";
  return "neutral";
}

function CustomTooltip({ active, payload, label }: any) {
  if (!active || !payload?.length) return null;

  return (
    <div className="gas-overview-tooltip">
      <strong>{label}</strong>

      {payload.map((item: any) => (
        <div key={item.dataKey}>
          <span>{item.name}</span>
          <b>
            {item.dataKey === "price"
              ? `$${formatNumber(item.value, 2)}`
              : `${formatNumber(item.value, 1)} Bcf`}
          </b>
        </div>
      ))}
    </div>
  );
}

export default function NaturalGasPage() {
  const [latest, setLatest] = useState<LatestGasResponse | null>(null);
  const [storageHistory, setStorageHistory] = useState<StorageRow[]>([]);
  const [priceRows, setPriceRows] = useState<PriceRow[]>([]);
  const [latestPrice, setLatestPrice] = useState<PriceRow | null>(null);
  const [consumptionRows, setConsumptionRows] = useState<ConsumptionRow[]>([]);
  const [lngRows, setLngRows] = useState<LngRow[]>([]);
  const [productionRows, setProductionRows] = useState<ProductionRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const latestStorage = latest?.storage ?? null;
  const latestSignal = latest?.signal ?? null;

  useEffect(() => {
    async function loadOverview() {
      try {
        setLoading(true);
        setError(null);

        const [
          latestGasResult,
          historyResult,
          priceDailyResult,
          priceLatestResult,
          consumptionResult,
          lngResult,
          productionResult,
        ] = await Promise.allSettled([
          fetchGasLatest(),
          fetchGasHistory(260),
          fetchGasPriceDaily(730),
          fetchGasPriceLatest(),
          fetchGasConsumption(36),
          fetchGasLngMonthly(36),
          fetchGasProductionMonthly(36),
        ]);

        if (latestGasResult.status === "fulfilled") {
          setLatest(latestGasResult.value);
        }

        if (historyResult.status === "fulfilled") {
          setStorageHistory(Array.isArray(historyResult.value) ? historyResult.value : []);
        }

        if (priceDailyResult.status === "fulfilled") {
          setPriceRows(priceDailyResult.value.rows ?? []);
        }

        if (priceLatestResult.status === "fulfilled") {
          setLatestPrice(priceLatestResult.value ?? null);
        }

        if (consumptionResult.status === "fulfilled") {
          setConsumptionRows(consumptionResult.value.rows ?? []);
        }

        if (lngResult.status === "fulfilled") {
          setLngRows(lngResult.value.rows ?? []);
        }

        if (productionResult.status === "fulfilled") {
          setProductionRows(productionResult.value.rows ?? []);
        }
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Failed to load gas overview."
        );
      } finally {
        setLoading(false);
      }
    }

    loadOverview();
  }, []);

  const chartRows = useMemo(
    () => buildStoragePriceChart(storageHistory, priceRows),
    [storageHistory, priceRows]
  );

  const latestConsumption = consumptionRows[0] ?? null;
  const latestLng = lngRows[0] ?? null;
  const latestProduction = productionRows[0] ?? null;

  const storageSurplus = toNumber(latestStorage?.surplus_vs_five_year_avg_bcf);
  const weeklyChange = toNumber(latestStorage?.change_bcf);
  const dryProduction = toNumber(latestProduction?.dry_production_bcfd);
  const totalConsumption = toNumber(latestConsumption?.total_consumption_bcf);
  const lngExports = toNumber(latestLng?.net_lng_exports_bcfd);
  const price = toNumber(latestPrice?.price_usd_per_mmbtu);

  const storageTone = getPressureTone(storageSurplus, false);
  const productionTone =
    dryProduction === null
      ? "neutral"
      : dryProduction >= 105
      ? "bearish"
      : dryProduction >= 95
      ? "neutral"
      : "bullish";

  const lngTone =
    lngExports === null
      ? "neutral"
      : lngExports >= 15
      ? "bullish"
      : lngExports >= 8
      ? "neutral"
      : "bearish";

  const consumptionTone =
    totalConsumption === null
      ? "neutral"
      : totalConsumption >= 3000
      ? "bullish"
      : totalConsumption >= 2200
      ? "neutral"
      : "bearish";

  if (loading) {
    return (
      <section className="gas-overview-page">
        <div className="gas-overview-loading">Loading natural gas overview...</div>
      </section>
    );
  }

  if (error) {
    return (
      <section className="gas-overview-page">
        <div className="gas-overview-error">{error}</div>
      </section>
    );
  }

  return (
    <section className="gas-overview-page">
      <div className="gas-overview-hero">
        <div>
          <div className="gas-overview-eyebrow">Aurion Gas Intelligence</div>
          <h2>Market Command Overview</h2>
          <p>
            Combines storage, price, production, consumption and LNG pressure into
            one high-level view of the U.S. natural gas market.
          </p>
        </div>

        <div className="gas-overview-signal">
          <span>Current Signal</span>
          <strong>{latestSignal?.direction ?? "Neutral"}</strong>
          <small>{latestSignal?.confidence ?? "low"} confidence</small>
        </div>
      </div>

      <div className="gas-overview-kpi-grid">
        <article className="gas-overview-kpi">
          <span>Henry Hub</span>
          <strong>${formatNumber(price, 2)}</strong>
          <small>{formatDate(latestPrice?.price_date)}</small>
        </article>

        <article className={`gas-overview-kpi gas-pressure-${storageTone}`}>
          <span>Storage vs 5Y</span>
          <strong>
            {storageSurplus !== null && storageSurplus > 0 ? "+" : ""}
            {formatNumber(storageSurplus)} Bcf
          </strong>
          <small>
            {storageTone === "bearish"
              ? "storage surplus"
              : storageTone === "bullish"
              ? "storage deficit"
              : "near average"}
          </small>
        </article>

        <article className="gas-overview-kpi">
          <span>Weekly Storage Change</span>
          <strong>
            {weeklyChange !== null && weeklyChange > 0 ? "+" : ""}
            {formatNumber(weeklyChange)} Bcf
          </strong>
          <small>{latestStorage?.storage_season ?? "season unknown"}</small>
        </article>

        <article className={`gas-overview-kpi gas-pressure-${productionTone}`}>
          <span>Dry Production</span>
          <strong>{formatNumber(dryProduction)} Bcf/d</strong>
          <small>{formatMonth(latestProduction?.month)}</small>
        </article>

        <article className={`gas-overview-kpi gas-pressure-${consumptionTone}`}>
          <span>Total Consumption</span>
          <strong>{formatNumber(totalConsumption)} Bcf</strong>
          <small>
            {formatMonth(latestConsumption?.month ?? latestConsumption?.report_month)}
          </small>
        </article>

        <article className={`gas-overview-kpi gas-pressure-${lngTone}`}>
          <span>Net LNG Exports</span>
          <strong>{formatNumber(lngExports)} Bcf/d</strong>
          <small>{formatMonth(latestLng?.month)}</small>
        </article>
      </div>

      <div className="gas-overview-main-grid">
        <article className="gas-overview-chart-card">
          <div className="gas-overview-card-header">
            <div>
              <h3>Storage vs Henry Hub Price</h3>
              <p>
                Storage and five-year average are shown against Henry Hub price
                to expose price reaction to supply tightness.
              </p>
            </div>

            <span>{chartRows.length} points</span>
          </div>

          <div className="gas-overview-chart-shell">
            <ResponsiveContainer width="100%" height={390}>
              <LineChart data={chartRows}>
                <CartesianGrid strokeDasharray="3 3" opacity={0.16} />
                <XAxis
                  dataKey="label"
                  tick={{ fontSize: 11 }}
                  minTickGap={34}
                />
                <YAxis
                  yAxisId="storage"
                  tick={{ fontSize: 11 }}
                  width={52}
                />
                <YAxis
                  yAxisId="price"
                  orientation="right"
                  tick={{ fontSize: 11 }}
                  width={52}
                />
                <Tooltip content={<CustomTooltip />} />
                <Legend />

                <Line
                  yAxisId="storage"
                  type="monotone"
                  dataKey="storage"
                  name="Storage"
                  stroke="#22d3ee"
                  strokeWidth={2}
                  dot={false}
                />

                <Line
                  yAxisId="storage"
                  type="monotone"
                  dataKey="fiveYearAvg"
                  name="5Y Avg"
                  stroke="#f59e0b"
                  strokeWidth={2}
                  dot={false}
                />

                <Line
                  yAxisId="price"
                  type="monotone"
                  dataKey="price"
                  name="Henry Hub Price"
                  stroke="#a78bfa"
                  strokeWidth={2}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </article>

        <aside className="gas-overview-pressure-card">
          <div className="gas-overview-card-header">
            <div>
              <h3>Pressure Stack</h3>
              <p>How each major factor currently leans.</p>
            </div>
          </div>

          <div className="gas-pressure-list">
            <PressureItem
              label="Storage"
              tone={storageTone}
              value={
                storageSurplus !== null
                  ? `${storageSurplus > 0 ? "+" : ""}${formatNumber(
                      storageSurplus
                    )} Bcf vs 5Y`
                  : "No data"
              }
              bearishText="Surplus storage weighs on prices"
              bullishText="Deficit storage supports prices"
              neutralText="Storage is close to normal"
            />

            <PressureItem
              label="Production"
              tone={productionTone}
              value={
                dryProduction !== null
                  ? `${formatNumber(dryProduction)} Bcf/d`
                  : "No data"
              }
              bearishText="High supply flow"
              bullishText="Lower supply flow"
              neutralText="Balanced supply flow"
            />

            <PressureItem
              label="Consumption"
              tone={consumptionTone}
              value={
                totalConsumption !== null
                  ? `${formatNumber(totalConsumption)} Bcf/month`
                  : "No data"
              }
              bearishText="Weak demand"
              bullishText="Strong demand"
              neutralText="Normal demand"
            />

            <PressureItem
              label="LNG"
              tone={lngTone}
              value={
                lngExports !== null
                  ? `${formatNumber(lngExports)} Bcf/d`
                  : "No data"
              }
              bearishText="Weak export pull"
              bullishText="Strong export pull"
              neutralText="Moderate export pull"
            />
          </div>

          <div className="gas-overview-explanation">
            <span>Signal explanation</span>
            <p>{latestSignal?.explanation ?? "No signal explanation available yet."}</p>
          </div>
        </aside>
      </div>
    </section>
  );
}

function PressureItem({
  label,
  tone,
  value,
  bearishText,
  bullishText,
  neutralText,
}: {
  label: string;
  tone: string;
  value: string;
  bearishText: string;
  bullishText: string;
  neutralText: string;
}) {
  const text =
    tone === "bullish"
      ? bullishText
      : tone === "bearish"
      ? bearishText
      : neutralText;

  return (
    <div className={`gas-pressure-item gas-pressure-${tone}`}>
      <div>
        <span>{label}</span>
        <strong>{value}</strong>
      </div>

      <p>{text}</p>
    </div>
  );
}