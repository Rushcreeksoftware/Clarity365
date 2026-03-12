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
  const breakEvenDate = cashFlow.find((row) => Number(row?.base || 0) < 0)?.date || '';
  const activeModules = (payload?.activeModules || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  const hasRecur365 = payload?.hasRecur365 === true;
  const isCashFlowMode = (mode || 'bi').toLowerCase() === 'cashflow';

  return (
    <div style={{ fontFamily: 'Segoe UI, sans-serif', padding: 16, background: '#f5f8fc', minHeight: '100vh' }}>
      <h2 style={{ marginTop: 0 }}>Clarity365 Dashboard ({mode})</h2>
      {setupCompleted ? (
        <>
          <ActionBar mode={mode} />

          <div style={{ marginBottom: 12, padding: 10, borderRadius: 8, border: '1px solid #d9e2ec', background: '#ffffff' }}>
            <div style={{ fontSize: 12, color: '#51606f', marginBottom: 6 }}>Active Modules</div>
            <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
              {activeModules.map((m) => (
                <span key={m} style={{ background: '#eaf2ff', border: '1px solid #c7dcff', borderRadius: 999, padding: '2px 8px', fontSize: 12 }}>
                  {m}
                </span>
              ))}
              <span style={{ background: hasRecur365 ? '#ecfdf3' : '#f3f4f6', border: '1px solid #d1d5db', borderRadius: 999, padding: '2px 8px', fontSize: 12 }}>
                Recur365: {hasRecur365 ? 'Installed' : 'Not Installed'}
              </span>
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(180px,1fr))', gap: 10, marginBottom: 12 }}>
            {isCashFlowMode ? (
              <>
                <KpiCard label="Cash Balance" value={kpis.cashBalance} />
                <KpiCard label="Open AR" value={kpis.openAR} />
                <KpiCard label="Open AP" value={kpis.openAP} />
              </>
            ) : (
              <>
                <KpiCard label="Revenue MTD" value={kpis.revenueMtd} />
                <KpiCard label="Open AR" value={kpis.openAR} />
                <KpiCard label="Open AP" value={kpis.openAP} />
                <KpiCard label="Cash Balance" value={kpis.cashBalance} />
                <KpiCard label="Gross Margin %" value={kpis.grossMarginPct} />
                <KpiCard label="MRR" value={kpis.mrr} />
              </>
            )}
          </div>

          {isCashFlowMode ? (
            <SimpleSeriesTable title="Cash Flow (Base/Upside/Downside)" rows={cashFlow} columns={['date', 'inflows', 'outflows', 'base', 'upside', 'downside']} />
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <SimpleSeriesTable title="Revenue Trend" rows={revenue} columns={['date', 'revenue', 'cogs', 'grossMargin']} />
              <SimpleSeriesTable title="Cash Flow (Base/Upside/Downside)" rows={cashFlow} columns={['date', 'inflows', 'outflows', 'base', 'upside', 'downside']} />
            </div>
          )}

          {breakEvenDate ? (
            <div style={{ marginTop: 12, padding: 12, borderRadius: 8, background: '#fff7ed', border: '1px solid #fed7aa' }}>
              Break-even alert: base scenario cash turns negative on {breakEvenDate}.
            </div>
          ) : null}
        </>
      ) : (
        <SetupPrompt />
      )}
    </div>
  );
}
