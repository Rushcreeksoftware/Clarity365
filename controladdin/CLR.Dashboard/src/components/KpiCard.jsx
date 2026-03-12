import React from 'react';

export default function KpiCard({ label, value }) {
  return (
    <div style={{ background: '#ffffff', border: '1px solid #d9e2ec', borderRadius: 10, padding: 12 }}>
      <div style={{ color: '#51606f', fontSize: 12 }}>{label}</div>
      <div style={{ fontSize: 22, fontWeight: 700, marginTop: 6 }}>{value ?? 0}</div>
    </div>
  );
}
