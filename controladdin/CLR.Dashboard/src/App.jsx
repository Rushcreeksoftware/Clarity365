import React, { useEffect, useState } from 'react';
import BC from './bridge';
import KpiCard from './components/KpiCard';
import ActionBar from './components/ActionBar';
import SimpleSeriesTable from './components/SimpleSeriesTable';
import SetupPrompt from './components/SetupPrompt';

export default function App() {
  const [payload, setPayload] = useState(null);
  const [mode, setMode] = useState('bi');

  useEffect(() => {
    window.receiveFromBC = (raw) => {
      try {
        setPayload(JSON.parse(raw));
      } catch {
        setPayload(null);
      }
    };

    window.setModeFromBC = (newMode) => setMode(newMode || 'bi');
    BC.ready();
  }, []);

  const kpis = payload?.kpis || {};
  const revenue = payload?.revenue || [];
  const cashFlow = payload?.cashFlow || [];
  const setupCompleted = payload?.setupCompleted !== false;

  return (
    <div style={{ fontFamily: 'Segoe UI, sans-serif', padding: 16, background: '#f5f8fc', minHeight: '100vh' }}>
      <h2 style={{ marginTop: 0 }}>Clarity365 Dashboard ({mode})</h2>
      {setupCompleted ? (
        <>
          <ActionBar />

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(180px,1fr))', gap: 10, marginBottom: 12 }}>
            <KpiCard label="Revenue MTD" value={kpis.revenueMtd} />
            <KpiCard label="Open AR" value={kpis.openAR} />
            <KpiCard label="Open AP" value={kpis.openAP} />
            <KpiCard label="Cash Balance" value={kpis.cashBalance} />
            <KpiCard label="Gross Margin %" value={kpis.grossMarginPct} />
            <KpiCard label="MRR" value={kpis.mrr} />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <SimpleSeriesTable title="Revenue Trend" rows={revenue} columns={['date', 'revenue', 'cogs', 'grossMargin']} />
            <SimpleSeriesTable title="Cash Flow (Base/Upside/Downside)" rows={cashFlow} columns={['date', 'inflows', 'outflows', 'base', 'upside', 'downside']} />
          </div>
        </>
      ) : (
        <SetupPrompt />
      )}
    </div>
  );
}
