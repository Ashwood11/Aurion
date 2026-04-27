import React, { useMemo, useState } from 'react';
import MainShell from './app/layout/MainShell';
import LeftPanel from './app/layout/LeftPanel';
import RightPanel from './app/layout/RightPanel';
import GlobeView from './globe/GlobeView';

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
        id: 'planes',
        label: 'Planes',
        icon: '🛫',
        color: '#60a5fa',
        options: [
          { id: 'planes-passenger', label: 'Passenger Flights' },
          { id: 'planes-cargo', label: 'Cargo Flights' },
          { id: 'planes-private', label: 'Private Aircraft', description: 'Business and private aviation' },
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

      if (groupId === 'ports') {
        setSelectedOptions((opts) =>
          Array.from(new Set([...opts.filter((id) => !id.startsWith('ports-')), 'ports-all']))
        );
      } else {
        setSelectedOptions((opts) => Array.from(new Set([...opts, ...optionIds])));
      }

      return [...prev, groupId];
    });
  };

  const toggleOption = (optionId: string) => {
    setSelectedOptions((prev) => {
      const isActive = prev.includes(optionId);

      if (optionId === 'ports-all') {
        if (isActive) {
          return prev.filter((id) => id !== 'ports-all');
        }
        return [...prev.filter((id) => !id.startsWith('ports-')), 'ports-all'];
      }

      if (optionId.startsWith('ports-')) {
        const next = isActive
          ? prev.filter((id) => id !== optionId)
          : [...prev.filter((id) => id !== 'ports-all'), optionId];

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
        <GlobeView
          onCountrySelect={setSelectedCountry}
          selectedOptions={selectedOptions}
        />
      }
      right={
        <RightPanel
          groups={layerGroups}
          selectedGroups={selectedGroups}
          selectedOptions={selectedOptions}
          onToggleGroup={toggleGroup}
          onToggleOption={toggleOption}
          onClearAll={clearAllLayers}
        />
      }
      bottom={null}
    />
  );
}

export default App;