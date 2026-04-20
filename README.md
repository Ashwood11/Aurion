# AURION — Analytical Unified Real-time Intelligence Observation Network

A **local-first desktop intelligence platform** that gathers, processes, and fuses real-world data into actionable signals, anomalies, and forecasts.

## Vision
AURION turns massive streams of world data (weather, natural gas, shipping, flights, commodities, stocks, insider activity, crops, macro events, etc.) into **explainable, traceable signals** that help you anticipate price movements, supply disruptions, and global events.

**Core Pipeline**: Raw Data → Clean → Signals → Weighted Signals → Fusion → Insight → Prediction

## Core Design Principles
- Modular & independent specialist modules
- Local-first (runs entirely on your desktop)
- Globe-based main interface (
eact-globe.gl)
- Strong emphasis on baselines, anomalies, timing delays, and signal fusion
- No "AI magic" — everything is transparent and auditable
- Future-ready for hybrid local + cloud

## Project Structure

- `frontend/` — React + TypeScript + Vite + react-globe.gl (UI)
- `backend/` — Python + FastAPI (API + data ingestion)
- `core/` — Shared signal engine, fusion logic, database models
- `modules/` — One folder per domain (weather, etc.)
- `desktop/` — Electron main process + packaging

## Quick Start

1. Clone the repo
2. `cd Aurion`

**Frontend**
```bash
cd frontend
npm install
npm run dev

## Modules Status
- **Weather** — In progress (ingestion + signals)

## Tech Stack
- Desktop: Electron
- Frontend: React + TypeScript + Vite + react-globe.gl
- Backend: Python + FastAPI
- Database: PostgreSQL (local)
- Signals: Standardized model across all modules

---

**Built for serious intelligence work.**
