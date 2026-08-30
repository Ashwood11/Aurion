import { useState } from "react";
import type { CommodityId } from "../features/commodities/types";
import GasView from "../features/commodities/gas/GasView";

type CommodityStatus = "active" | "planned";

const commodities: {
  id: CommodityId;
  label: string;
  status: CommodityStatus;
  description: string;
  icon: string;
}[] = [
  {
    id: "gas",
    label: "Natural Gas",
    status: "active",
    icon: "🔥",
    description: "Storage, demand, LNG and price pressure.",
  },
  {
    id: "oil",
    label: "Oil",
    status: "planned",
    icon: "🛢️",
    description: "Crude prices, inventories and refinery activity.",
  },
  {
    id: "gold",
    label: "Gold",
    status: "planned",
    icon: "◆",
    description: "Rates, dollar strength and safe-haven demand.",
  },
  {
    id: "silver",
    label: "Silver",
    status: "planned",
    icon: "◇",
    description: "Industrial demand and precious metal flows.",
  },
  {
    id: "wheat",
    label: "Wheat",
    status: "planned",
    icon: "🌾",
    description: "Weather, crop stress, exports and yields.",
  },
  {
    id: "copper",
    label: "Copper",
    status: "planned",
    icon: "◉",
    description: "Mine supply, smelters and industrial demand.",
  },
];

export default function CommoditiesPage() {
  const [selectedCommodity, setSelectedCommodity] =
    useState<CommodityId | null>(null);

  if (selectedCommodity === "gas") {
    return (
      <div className="commodities-page">
        <button
          className="commodities-back-button"
          onClick={() => setSelectedCommodity(null)}
        >
          ← Back to Commodities
        </button>

        <GasView />
      </div>
    );
  }

  return (
    <div className="commodities-page">
      <header className="commodities-header">
        <p className="commodities-kicker">AURION Markets</p>
        <h1>Commodities Overview</h1>
        <p>
          Track commodity modules, market movement, supply pressure and emerging
          intelligence events.
        </p>
      </header>

      <section className="commodities-panel">
        <div className="commodities-section-header">
          <div>
            <h2>Commodity Modules</h2>
            <p>Open a commodity module for deeper analysis.</p>
          </div>
        </div>

        <div className="commodity-grid">
          {commodities.map((commodity) => {
            const active = commodity.status === "active";

            return (
              <button
                key={commodity.id}
                className={`commodity-card ${
                  active ? "commodity-card--active" : "commodity-card--planned"
                }`}
                onClick={() => active && setSelectedCommodity(commodity.id)}
                disabled={!active}
              >
                <div className="commodity-card__top">
                  <div className="commodity-card__icon">{commodity.icon}</div>

                  <span className={`commodity-pill commodity-pill--${commodity.status}`}>
                    {commodity.status}
                  </span>
                </div>

                <h3>{commodity.label}</h3>
                <p>{commodity.description}</p>

                <div className="commodity-card__footer">
                  {active ? "Open module →" : "Planned"}
                </div>
              </button>
            );
          })}
        </div>
      </section>

      <section className="overview-grid">
        <OverviewCard label="Active Modules" value="1" />
        <OverviewCard label="Tracked Markets" value="6" />
        <OverviewCard label="Major Signals" value="1" />
        <OverviewCard label="Latest Alert" value="Gas bearish" />
      </section>

      <section className="commodities-panel">
        <div className="commodities-section-header">
          <div>
            <h2>Market Watch</h2>
            <p>High-level commodity intelligence events.</p>
          </div>

          <span className="live-pill">Live</span>
        </div>

        <div className="market-list">
          <MarketEvent
            title="Natural gas storage above 5-year average"
            meta="Lower 48 · Storage pressure"
            severity="bearish"
          />

          <MarketEvent
            title="Oil module planned"
            meta="Supply, refinery activity, geopolitics"
            severity="planned"
          />

          <MarketEvent
            title="Wheat module planned"
            meta="Weather, yield stress, exports"
            severity="planned"
          />
        </div>
      </section>
    </div>
  );
}

function OverviewCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="overview-card">
      <p>{label}</p>
      <strong>{value}</strong>
    </div>
  );
}

function MarketEvent({
  title,
  meta,
  severity,
}: {
  title: string;
  meta: string;
  severity: "bullish" | "bearish" | "neutral" | "planned";
}) {
  return (
    <div className="market-event">
      <div>
        <h3>{title}</h3>
        <p>{meta}</p>
      </div>

      <span className={`market-severity market-severity--${severity}`}>
        {severity}
      </span>
    </div>
  );
}