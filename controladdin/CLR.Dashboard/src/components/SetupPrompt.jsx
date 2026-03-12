import React from 'react';
import BC from '../bridge';

export default function SetupPrompt() {
  return (
    <div style={{ background: '#ffffff', border: '1px solid #d8e2ef', borderRadius: 10, padding: 24, marginTop: 16 }}>
      <h3 style={{ marginTop: 0, marginBottom: 8 }}>Setup Required</h3>
      <p style={{ marginTop: 0, color: '#4b5563' }}>
        Complete the Clarity365 setup wizard to map accounts, dimensions, and forecast defaults before using the dashboard.
      </p>
      <button onClick={() => BC.sendToBC('SetupRequested', '')}>Open Setup Wizard</button>
    </div>
  );
}
