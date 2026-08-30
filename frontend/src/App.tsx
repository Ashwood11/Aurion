import React, { useMemo, useState } from 'react';
import MainShell from './app/layout/MainShell';
import LeftPanel from './app/layout/LeftPanel';
import RightPanel from './app/layout/RightPanel';
import GlobeView from './globe/GlobeView';
import CommoditiesPage from './pages/CommoditiesPage';

function App() {
  const [activeModule, setActiveModule] = useState('map');
  const [selectedCountry, setSelectedCountry] = useState<any>(null);
  const [selectedGroups, setSelectedGroups] = useState<string[]>([]);
  const [selectedOptions, setSelectedOptions] = useState<string[]>([]);

  const modules = useMemo(
    () => [
      { id: 'map', label: 'Globe', icon: '◈', accent: '#6366f1', status: 'LIVE' },
      { id: 'dashboard', label: 'Dashboard', icon: '◌', accent: '#22c55e' },
      { id: 'signals', label: 'Signals', icon: '◍', accent: '#f59e0b' },
      { id: 'commodities', label: 'Commodities', icon: '◒', accent: '#14b8a6' },
      { id: 'assets', label: 'Assets', icon: '✈', accent: '#38bdf8' },
    ],
    []
  );

  const layerGroups = useMemo(
    () => [
      {
        id: 'airports',
        label: 'Airports',
        icon: '✈',
        color: '#38bdf8',
        options: [
          { id: 'airports-large', label: 'Large Airports' },
          { id: 'airports-medium', label: 'Medium Airports' },
          { id: 'airports-small', label: 'Small Airports' },
        ],
      },
      {
        id: 'ports',
        label: 'Ports',
        icon: '⚓',
        color: '#22c55e',
        options: [
          { id: 'ports-all', label: 'All Ports' },
          { id: 'ports-container', label: 'Container-capable' },
          { id: 'ports-oil', label: 'Oil Terminals' },
          { id: 'ports-lng', label: 'LNG Terminals' },
          { id: 'ports-commercial', label: 'Commercial' },
          { id: 'ports-industrial', label: 'Industrial' },
          { id: 'ports-fishing', label: 'Fishing' },
          { id: 'ports-naval', label: 'Military / Naval' },
          { id: 'ports-large', label: 'Large Ports' },
          { id: 'ports-medium', label: 'Medium Ports' },
          { id: 'ports-small', label: 'Small Ports' },
          { id: 'ports-river', label: 'River Ports' },
          { id: 'ports-coastal', label: 'Coastal Natural' },
          { id: 'ports-lake', label: 'Lake / Canal' },
        ],
      },
      {
        id: 'mining',
        label: 'Mining Assets',
        icon: '⛏',
        color: '#facc15',
        options: [
          { id: 'mining-all', label: 'All Mining Assets' },
          { id: 'mining-mines', label: 'Mines' },
          { id: 'mining-smelters', label: 'Smelters' },
          { id: 'mining-refineries', label: 'Refineries' },
          { id: 'mining-plants', label: 'Plants' },
          { id: 'mining-mixed', label: 'Mixed Assets' },
          { id: 'mining-copper', label: 'Copper' },
          { id: 'mining-gold', label: 'Gold' },
          { id: 'mining-iron', label: 'Iron Ore' },
          { id: 'mining-coal', label: 'Coal' },
          { id: 'mining-lithium', label: 'Lithium' },
          { id: 'mining-nickel', label: 'Nickel' },
          { id: 'mining-zinc', label: 'Zinc' },
          { id: 'mining-cobalt', label: 'Cobalt' },
          { id: 'mining-uranium', label: 'Uranium' },
          { id: 'mining-ree', label: 'Rare Earths' },
        ],
      },
      {
        id: 'planes',
        label: 'Planes',
        icon: '🛫',
        color: '#60a5fa',
        options: [
          { id: 'planes-passenger', label: 'Passenger Flights' },
          { id: 'planes-cargo', label: 'Cargo Flights' },
          { id: 'planes-private', label: 'Private Aircraft' },
        ],
      },
    ],
    []
  );

  const toggleGroup = (groupId: string) => {
    const group = layerGroups.find((g) => g.id === groupId);
    if (!group) return;

    const optionIds = group.options.map((o) => o.id);

    setSelectedGroups((prev) => {
      const active = prev.includes(groupId);

      if (active) {
        setSelectedOptions((opts) => opts.filter((id) => !optionIds.includes(id)));
        return prev.filter((id) => id !== groupId);
      }

      if (groupId === 'ports' || groupId === 'mining') {
        setSelectedOptions((opts) => [
          ...opts.filter((id) => !id.startsWith(`${groupId}-`)),
          `${groupId}-all`,
        ]);
      } else {
        setSelectedOptions((opts) => Array.from(new Set([...opts, ...optionIds])));
      }

      return [...prev, groupId];
    });
  };

  const toggleOption = (optionId: string) => {
    setSelectedOptions((prev) => {
      const isActive = prev.includes(optionId);

      if (optionId === 'ports-all' || optionId === 'mining-all') {
        const prefix = optionId.split('-')[0];

        if (isActive) {
          return prev.filter((id) => id !== optionId);
        }

        return [...prev.filter((id) => !id.startsWith(`${prefix}-`)), optionId];
      }

      if (optionId.startsWith('ports-') || optionId.startsWith('mining-')) {
        const prefix = optionId.split('-')[0];

        const next = isActive
          ? prev.filter((id) => id !== optionId)
          : [...prev.filter((id) => id !== `${prefix}-all`), optionId];

        return Array.from(new Set(next));
      }

      return isActive
        ? prev.filter((id) => id !== optionId)
        : [...prev, optionId];
    });
  };

  const clearAllLayers = () => {
    setSelectedGroups([]);
    setSelectedOptions([]);
  };

  return (
    <MainShell
      left={
        <LeftPanel
          modules={modules}
          activeModule={activeModule}
          onSelectModule={setActiveModule}
        />
      }
      center={
        activeModule === 'commodities' ? (
          <div
            style={{
              width: '100%',
              height: '100%',
              paddingLeft: 72,
              boxSizing: 'border-box',
              overflow: 'auto',
              minHeight: 0,
            }}
          >
            <CommoditiesPage />
          </div>
        ) : (
          <GlobeView
            onCountrySelect={setSelectedCountry}
            selectedOptions={selectedOptions}
          />
        )
      }
      right={
        activeModule === 'map' ? (
          <RightPanel
            groups={layerGroups}
            selectedGroups={selectedGroups}
            selectedOptions={selectedOptions}
            onToggleGroup={toggleGroup}
            onToggleOption={toggleOption}
            onClearAll={clearAllLayers}
          />
        ) : null
      }
      bottom={null}
    />
  );
}

export default App;