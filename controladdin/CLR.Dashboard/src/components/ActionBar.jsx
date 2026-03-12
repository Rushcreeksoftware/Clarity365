import React, { useEffect, useState } from 'react';
import BC from '../bridge';

export default function ActionBar({ mode }) {
  const [range, setRange] = useState('year-to-date');
  const [asOfDate, setAsOfDate] = useState('');
  const [glFilter, setGlFilter] = useState('');
  const [dimensionCode, setDimensionCode] = useState('');
  const [viewCode, setViewCode] = useState('DEFAULT');
  const [currentMode, setCurrentMode] = useState((mode || 'bi').toLowerCase());

  useEffect(() => {
    setCurrentMode((mode || 'bi').toLowerCase());
  }, [mode]);

  const applyFilters = () => {
    BC.sendToBC('FilterChanged', {
      range,
      asOfDate,
      glFilter,
      dimensionCode
    });
  };

  return (
    <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 12 }}>
      <select value={range} onChange={(e) => setRange(e.target.value)}>
        <option value="last-30-days">Last 30 Days</option>
        <option value="year-to-date">Year To Date</option>
        <option value="last-12-months">Last 12 Months</option>
      </select>
      <input type="date" value={asOfDate} onChange={(e) => setAsOfDate(e.target.value)} />
      <input placeholder="GL Filter (e.g. 4*)" value={glFilter} onChange={(e) => setGlFilter(e.target.value)} />
      <input placeholder="Dimension Code" value={dimensionCode} onChange={(e) => setDimensionCode(e.target.value)} />
      <button onClick={applyFilters}>Apply Filters</button>
      <button onClick={() => { setCurrentMode('bi'); BC.sendToBC('ModeChanged', 'bi'); }}>BI Mode</button>
      <button onClick={() => { setCurrentMode('cashflow'); BC.sendToBC('ModeChanged', 'cashflow'); }}>Cash Flow Mode</button>
      <button onClick={() => BC.sendToBC('ScenarioRequested', 'BASE')}>Base Scenario</button>
      <button onClick={() => BC.sendToBC('ScenarioRequested', 'UPSIDE')}>Upside Scenario</button>
      <button onClick={() => BC.sendToBC('ScenarioRequested', 'DOWNSIDE')}>Downside Scenario</button>
      <button onClick={() => BC.sendToBC('SaveViewRequested', { code: 'DEFAULT', description: 'Default View', mode: currentMode })}>Save View</button>
      <input placeholder="View Code" value={viewCode} onChange={(e) => setViewCode(e.target.value)} />
      <button onClick={() => BC.sendToBC('LoadViewRequested', viewCode || 'DEFAULT')}>Load View</button>
      <button onClick={() => BC.sendToBC('ExportRequested', 'excel')}>Export Excel</button>
      <button onClick={() => BC.sendToBC('ExportRequested', 'pdf')}>Export PDF</button>
      <button onClick={() => BC.sendToBC('SetupRequested', '')}>Setup Wizard</button>
    </div>
  );
}
