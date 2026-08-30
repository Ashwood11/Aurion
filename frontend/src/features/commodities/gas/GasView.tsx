import { useState } from "react";
import NaturalGasPage from "./NaturalGasPage";
import StoragePage from "./StoragePage";
import SignalsPage from "./SignalsPage";
import GasInfluenceMap from "./GasInfluenceMap";
import GasConsumption from "./GasConsumption";
import PricePage from "./GasPricing";
import GasLng from "./GasLNG";
import GasProduction from "./GasProduction";

type GasTab =
  | "overview"
  | "price"
  | "storage"
  | "signals"
  | "production"
  | "consumption"
  | "lng"
  | "influence";

const tabs: { id: GasTab; label: string }[] = [
  { id: "overview", label: "Overview" },
  { id: "price", label: "Price" },
  { id: "storage", label: "Storage" },
  { id: "signals", label: "Signals" },
  { id: "production", label: "Production" },
  { id: "consumption", label: "Consumption" },
  { id: "lng", label: "LNG" },
  { id: "influence", label: "Influence Map" },
];

export default function GasView() {
  const [activeTab, setActiveTab] = useState<GasTab>("overview");

  return (
    <div className="gas-page">
      <header className="gas-header">
        <div>
          <p className="gas-kicker">Natural Gas Module</p>
          <h1>Natural Gas Intelligence</h1>
          <p>
            Storage, demand, LNG movement and price-pressure signals for the gas
            market.
          </p>
        </div>

        <div className="gas-tabs">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              type="button"
              onClick={() => setActiveTab(tab.id)}
              className={`gas-tab ${activeTab === tab.id ? "is-active" : ""}`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </header>

      <main className="gas-tab-content">
        {activeTab === "overview" && <NaturalGasPage />}
        {activeTab === "price" && <PricePage />}
        {activeTab === "storage" && <StoragePage />}
        {activeTab === "signals" && <SignalsPage />}
        {activeTab === "consumption" && <GasConsumption />}
        {activeTab === "lng" && <GasLng />}
        {activeTab === "influence" && <GasInfluenceMap />}
        {activeTab === "production" && <GasProduction />}
      </main>
    </div>
  );
}

function Placeholder({ title }: { title: string }) {
  return (
    <section className="gas-card">
      <div className="gas-card-header">
        <div>
          <h2>{title}</h2>
          <p>This section is ready to connect once the data/API is added.</p>
        </div>
      </div>
    </section>
  );
}