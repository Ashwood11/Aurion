import { useMemo, useState } from 'react';
import './styles.css';

import TopBar from './app/layout/TopBar';
import MainShell from './app/layout/MainShell';
import LeftPanel from './app/layout/LeftPanel';
import RightPanel from './app/layout/RightPanel';
import BottomTimeline from './app/layout/BottomTimeline';
import GlobeView from './components/GlobeView';

import { mockRegions } from './features/weatherGas/data/mockRegions';
import { computeGasSignal } from './features/weatherGas/signalEngine';

export type GridPoint = {
  gridCode: string;
  lat: number;
  lng: number;
};

export type StrategicPoint = {
  name: string;
  type: string;
  subtype?: string | null;
  lat: number;
  lng: number;
  importance?: number | null;
};

export default function App() {
  const [regions] = useState(mockRegions);
  const [selectedRegionId, setSelectedRegionId] = useState(regions[0].id);

  const computedRegions = useMemo(() => {
    return regions.map((region) => {
      const signal = computeGasSignal(region);

      return {
        ...region,
        gasScore: signal.gasScore,
        confidence: signal.confidence,
        explanation: signal.explanation,
        signals: signal.signals,
      };
    });
  }, [regions]);

  const selectedRegion =
    computedRegions.find((r) => r.id === selectedRegionId) ?? computedRegions[0];

  return (
    <div className="app-root">
      <TopBar />

      <MainShell
        left={
          <LeftPanel
            regions={computedRegions}
            selectedRegionId={selectedRegionId}
            onSelectRegion={setSelectedRegionId}
          />
        }
        center={<GlobeView />}
        right={<RightPanel region={selectedRegion} />}
        bottom={<BottomTimeline />}
      />
    </div>
  );
}