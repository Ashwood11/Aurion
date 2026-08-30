import { useMemo, useState } from "react";

type InfluenceType = "bullish" | "bearish" | "neutral";
type ViewMode = "cards" | "arrows";

type GasInfluence = {
    id: string;
    label: string;
    type: InfluenceType;
    strength: number;
    x: number;
    y: number;
    icon: string;
    summary: string;
    explanation: string;
};

const influences: GasInfluence[] = [
    {
        id: "low-storage",
        label: "Low Storage",
        type: "bullish",
        strength: 92,
        x: 18,
        y: 18,
        icon: "⬇",
        summary: "Lower inventories tighten supply.",
        explanation: "Storage below normal reduces the market buffer and usually supports higher gas prices.",
    },
    {
        id: "cold-weather",
        label: "Cold Weather",
        type: "bullish",
        strength: 88,
        x: 34,
        y: 10,
        icon: "❄",
        summary: "Heating demand rises.",
        explanation: "Cold weather increases residential and commercial heating demand.",
    },
    {
        id: "lng-exports",
        label: "LNG Exports",
        type: "bullish",
        strength: 82,
        x: 18,
        y: 42,
        icon: "🚢",
        summary: "Exports remove domestic supply.",
        explanation: "Strong LNG exports increase demand for domestic gas.",
    },
    {
        id: "power-burn",
        label: "Power Burn",
        type: "bullish",
        strength: 70,
        x: 28,
        y: 72,
        icon: "⚡",
        summary: "Electricity demand increases gas use.",
        explanation: "Gas-fired power plants burn more fuel when electricity demand is high.",
    },
    {
        id: "production-outage",
        label: "Production Outage",
        type: "bullish",
        strength: 76,
        x: 28,
        y: 34,
        icon: "⚠",
        summary: "Supply disruption supports price.",
        explanation: "Freeze-offs, maintenance and storms can reduce production.",
    },
    {
        id: "high-storage",
        label: "High Storage",
        type: "bearish",
        strength: 94,
        x: 76,
        y: 18,
        icon: "⬆",
        summary: "Surplus inventory weakens prices.",
        explanation: "High storage gives the market a larger supply cushion.",
    },
    {
        id: "warm-winter",
        label: "Warm Winter",
        type: "bearish",
        strength: 86,
        x: 66,
        y: 10,
        icon: "☀",
        summary: "Heating demand falls.",
        explanation: "Warm winter weather reduces heating demand.",
    },
    {
        id: "strong-production",
        label: "Strong Production",
        type: "bearish",
        strength: 84,
        x: 82,
        y: 42,
        icon: "⛽",
        summary: "More supply pressures price.",
        explanation: "High production adds available supply.",
    },
    {
        id: "weak-lng",
        label: "Weak LNG Exports",
        type: "bearish",
        strength: 72,
        x: 66,
        y: 64,
        icon: "↓",
        summary: "Less export demand leaves gas at home.",
        explanation: "Reduced LNG flows keep more supply in the domestic market.",
    },
    {
        id: "weak-industrial",
        label: "Weak Industrial Demand",
        type: "bearish",
        strength: 66,
        x: 82,
        y: 78,
        icon: "🏭",
        summary: "Lower activity reduces gas use.",
        explanation: "Weak industrial activity can reduce natural gas demand.",
    },
];

export default function GasInfluenceMap() {
    const [selected, setSelected] = useState<GasInfluence>(influences[0]);
    const [viewMode, setViewMode] = useState<ViewMode>("arrows");

    const bullish = useMemo(() => influences.filter((i) => i.type === "bullish"), []);
    const bearish = useMemo(() => influences.filter((i) => i.type === "bearish"), []);

    return (
        <div className="gas-influence-page">
            <section className="gas-card gas-influence-hero">
                <div>
                    <p className="gas-kicker">Interactive Market Logic</p>
                    <h2>Natural Gas Influence Map</h2>
                    <p>Democracy-style map of bullish and bearish pressure on natural gas.</p>
                </div>

                <div className="gas-map-toggle">
                    <button className={viewMode === "arrows" ? "is-active" : ""} onClick={() => setViewMode("arrows")}>
                        Arrow Map
                    </button>
                    <button className={viewMode === "cards" ? "is-active" : ""} onClick={() => setViewMode("cards")}>
                        Cards
                    </button>
                </div>
            </section>

            {viewMode === "arrows" ? (
                <section className="gas-arrow-map-wrap">
                    <div className="gas-arrow-map">
                        <div className="gas-map-bg-word gas-map-bg-word--supply">Supply</div>
                        <div className="gas-map-bg-word gas-map-bg-word--demand">Demand</div>
                        <div className="gas-map-bg-word gas-map-bg-word--storage">Storage</div>
                        <div className="gas-map-bg-word gas-map-bg-word--weather">Weather</div>

                        <svg className="gas-arrow-lines" viewBox="0 0 100 100" preserveAspectRatio="none">
                            <defs>
                                <marker id="arrow-bullish" markerWidth="4" markerHeight="4" refX="3" refY="2" orient="auto">
                                    <path d="M0,0 L0,4 L4,2 z" fill="#55c400" />
                                </marker>

                                <marker id="arrow-bearish" markerWidth="4" markerHeight="4" refX="3" refY="2" orient="auto">
                                    <path d="M0,0 L0,4 L4,2 z" fill="#ff3b17" />
                                </marker>
                            </defs>

                            {influences.map((item, index) => {
                                const midX = (item.x + 50) / 2;
                                const midY = (item.y + 50) / 2 + (index % 2 === 0 ? -8 : 8);

                                return (
                                    <path
                                        key={item.id}
                                        d={`M ${item.x} ${item.y} Q ${midX} ${midY} 50 50`}
                                        className={`gas-arrow-line gas-arrow-line--${item.type}`}
                                        markerEnd={`url(#arrow-${item.type})`}
                                        style={{
                                            strokeWidth: 0.3 + item.strength / 140,
                                            opacity: 0.5 + item.strength / 220,
                                        }}
                                    />
                                );
                            })}
                        </svg>

                        <div className="gas-map-core">
                            <span>Natural</span>
                            <strong>GAS</strong>
                            <small>Price Pressure</small>
                        </div>

                        {influences.map((item) => (
                            <button
                                key={item.id}
                                className={`gas-map-icon-node gas-map-icon-node--${item.type} ${selected.id === item.id ? "is-selected" : ""
                                    }`}
                                style={{ left: `${item.x}%`, top: `${item.y}%` }}
                                onClick={() => setSelected(item)}
                                title={`${item.label} — ${item.strength}/100`}
                            >
                                <i>{item.icon}</i>
                            </button>
                        ))}
                    </div>

                    <aside className="gas-card gas-influence-detail">
                        <span className={`gas-signal-pill gas-signal-pill--${selected.type}`}>
                            {selected.type}
                        </span>

                        <h2>{selected.label}</h2>
                        <p>{selected.summary}</p>

                        <div className="gas-strength-meter">
                            <div>
                                <span>Influence Strength</span>
                                <strong>{selected.strength}/100</strong>
                            </div>

                            <div className="gas-strength-track">
                                <div
                                    className={`gas-strength-fill gas-strength-fill--${selected.type}`}
                                    style={{ width: `${selected.strength}%` }}
                                />
                            </div>
                        </div>

                        <div className="gas-explanation">
                            <p>Market Logic</p>
                            <span>{selected.explanation}</span>
                        </div>
                    </aside>
                </section>
            ) : (
                <section className="gas-influence-layout">
                    <div className="gas-influence-column">
                        <h3>Bullish Pressure</h3>
                        {bullish.map((item) => (
                            <InfluenceButton key={item.id} item={item} selected={selected.id === item.id} onClick={() => setSelected(item)} />
                        ))}
                    </div>

                    <div className="gas-influence-center">
                        <div className="gas-core-node">
                            <span>Natural</span>
                            <strong>GAS</strong>
                            <small>Price Pressure</small>
                        </div>
                    </div>

                    <div className="gas-influence-column">
                        <h3>Bearish Pressure</h3>
                        {bearish.map((item) => (
                            <InfluenceButton key={item.id} item={item} selected={selected.id === item.id} onClick={() => setSelected(item)} />
                        ))}
                    </div>

                    <aside className="gas-card gas-influence-detail">
                        <span className={`gas-signal-pill gas-signal-pill--${selected.type}`}>
                            {selected.type}
                        </span>
                        <h2>{selected.label}</h2>
                        <p>{selected.summary}</p>
                    </aside>
                </section>
            )}
        </div>
    );
}

function InfluenceButton({
    item,
    selected,
    onClick,
}: {
    item: GasInfluence;
    selected: boolean;
    onClick: () => void;
}) {
    return (
        <button
            className={`gas-influence-button gas-influence-button--${item.type} ${selected ? "is-selected" : ""}`}
            onClick={onClick}
        >
            <div>
                <strong>{item.label}</strong>
                <span>{item.summary}</span>
            </div>
            <em>{item.strength}</em>
        </button>
    );
}