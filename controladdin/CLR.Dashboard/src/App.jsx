import React, { useEffect, useState } from 'react';
import BC from './bridge';

export default function App() {
  const [payload, setPayload] = useState(null);

  useEffect(() => {
    window.receiveFromBC = (raw) => {
      try {
        setPayload(JSON.parse(raw));
      } catch {
        setPayload(null);
      }
    };

    window.setModeFromBC = () => {};
    BC.ready();
  }, []);

  return (
    <div style={{ fontFamily: 'Segoe UI, sans-serif', padding: 16 }}>
      <h2>Clarity365 Dashboard</h2>
      <p>Control add-in bridge connected.</p>
      <pre style={{ background: '#f4f4f4', padding: 12, overflow: 'auto' }}>
        {payload ? JSON.stringify(payload, null, 2) : 'Waiting for Business Central payload...'}
      </pre>
    </div>
  );
}
