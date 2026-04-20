import React, { useMemo, useState } from 'react';
import MainShell from './app/layout/MainShell';
import LeftPanel from './app/layout/LeftPanel';
import RightPanel from './app/layout/RightPanel';
import GlobeView from './globe/GlobeView';

function App() {
  const [activeModule, setActiveModule] = useState('map');
  const [selectedCountry, setSelectedCountry] = useState<any>(null);

  // 🔑 REQUIRED: layer state
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

  // 🔑 toggles
  const toggleGroup = (groupId: string) => {
    const group = layerGroups.find(g => g.id === groupId);
    if (!group) return;

    const optionIds = group.options.map(o => o.id);

    setSelectedGroups(prev => {
      const active = prev.includes(groupId);

      if (active) {
        setSelectedOptions(opts => opts.filter(id => !optionIds.includes(id)));
        return prev.filter(id => id !== groupId);
      } else {
        setSelectedOptions(opts => Array.from(new Set([...opts, ...optionIds])));
        return [...prev, groupId];
      }
    });
  };

  const toggleOption = (optionId: string) => {
    setSelectedOptions(prev =>
      prev.includes(optionId)
        ? prev.filter(id => id !== optionId)
        : [...prev, optionId]
    );
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
          // 🔴 THIS LINE IS THE FIX
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