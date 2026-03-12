import React from 'react';

export default function SimpleSeriesTable({ title, rows, columns }) {
  if (!rows?.length) {
    return (
      <div style={{ background: '#ffffff', border: '1px solid #d9e2ec', borderRadius: 10, padding: 12 }}>
        <h3 style={{ marginTop: 0 }}>{title}</h3>
        <div>No data</div>
      </div>
    );
  }

  return (
    <div style={{ background: '#ffffff', border: '1px solid #d9e2ec', borderRadius: 10, padding: 12 }}>
      <h3 style={{ marginTop: 0 }}>{title}</h3>
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr>
            {columns.map((c) => (
              <th key={c} style={{ textAlign: 'left', borderBottom: '1px solid #e7eef5', padding: '6px 4px' }}>{c}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.slice(0, 8).map((r, idx) => (
            <tr key={idx}>
              {columns.map((c) => (
                <td key={c} style={{ padding: '6px 4px', borderBottom: '1px solid #f1f4f8' }}>{String(r[c] ?? '')}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
