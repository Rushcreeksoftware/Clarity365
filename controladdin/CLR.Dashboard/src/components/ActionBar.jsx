import React from 'react';
import BC from '../bridge';

export default function ActionBar() {
  return (
    <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 12 }}>
      <button onClick={() => BC.sendToBC('FilterChanged', { range: 'last-30-days' })}>Last 30 Days</button>
      <button onClick={() => BC.sendToBC('FilterChanged', { range: 'year-to-date' })}>Year To Date</button>
      <button onClick={() => BC.sendToBC('ScenarioRequested', 'BASE')}>Base Scenario</button>
      <button onClick={() => BC.sendToBC('ScenarioRequested', 'UPSIDE')}>Upside Scenario</button>
      <button onClick={() => BC.sendToBC('ScenarioRequested', 'DOWNSIDE')}>Downside Scenario</button>
      <button onClick={() => BC.sendToBC('SaveViewRequested', { code: 'DEFAULT', description: 'Default View' })}>Save View</button>
      <button onClick={() => BC.sendToBC('ExportRequested', 'excel')}>Export Excel</button>
      <button onClick={() => BC.sendToBC('SetupRequested', '')}>Setup Wizard</button>
    </div>
  );
}
