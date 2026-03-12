(function () {
  var state = {
    payload: null,
    mode: 'bi'
  };

  function invoke(eventName, payload) {
    try {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(eventName, [typeof payload === 'string' ? payload : JSON.stringify(payload || '')]);
    } catch (e) {
      console.warn('Clarity365 invoke failed', eventName, e.message);
    }
  }

  function ensureRoot() {
    var root = document.getElementById('root');
    if (!root) {
      root = document.createElement('div');
      root.id = 'root';
      document.body.appendChild(root);
    }
    return root;
  }

  function val(v) {
    if (v === null || v === undefined) return '0';
    return String(v);
  }

  function kpiCard(label, value) {
    return '<div class="clr-card"><div class="clr-kpi-label">' + label + '</div><div class="clr-kpi-value">' + val(value) + '</div></div>';
  }

  function table(title, rows, cols) {
    if (!rows || !rows.length) {
      return '<div class="clr-panel"><h3>' + title + '</h3><div>No data</div></div>';
    }

    var head = cols.map(function (c) { return '<th>' + c + '</th>'; }).join('');
    var body = rows.slice(0, 8).map(function (r) {
      var tds = cols.map(function (c) { return '<td>' + val(r[c]) + '</td>'; }).join('');
      return '<tr>' + tds + '</tr>';
    }).join('');

    return '<div class="clr-panel"><h3>' + title + '</h3><table><thead><tr>' + head + '</tr></thead><tbody>' + body + '</tbody></table></div>';
  }

  function render() {
    var root = ensureRoot();
    var p = state.payload || {};
    var k = p.kpis || {};
    var revenue = p.revenue || [];
    var cashFlow = p.cashFlow || [];

    root.innerHTML = '' +
      '<div class="clr-wrap">' +
      '  <h2>Clarity365 Dashboard (' + val(state.mode) + ')</h2>' +
      '  <div class="clr-actions">' +
      '    <select id="clr-range"><option value="last-30-days">Last 30 Days</option><option value="year-to-date" selected>Year To Date</option><option value="last-12-months">Last 12 Months</option></select>' +
      '    <input id="clr-asof" type="date" />' +
      '    <input id="clr-glfilter" placeholder="GL Filter (e.g. 4*)" />' +
      '    <input id="clr-dimcode" placeholder="Dimension Code" />' +
      '    <button id="clr-apply-filter">Apply Filters</button>' +
      '    <button id="clr-base">Base</button>' +
      '    <button id="clr-upside">Upside</button>' +
      '    <button id="clr-downside">Downside</button>' +
      '    <button id="clr-save-view">Save View</button>' +
      '    <button id="clr-export">Export Excel</button>' +
      '    <button id="clr-export-pdf">Export PDF</button>' +
      '    <button id="clr-setup">Setup Wizard</button>' +
      '  </div>' +
      '  <div class="clr-grid">' +
           kpiCard('Revenue MTD', k.revenueMtd) +
           kpiCard('Open AR', k.openAR) +
           kpiCard('Open AP', k.openAP) +
           kpiCard('Cash Balance', k.cashBalance) +
           kpiCard('Gross Margin %', k.grossMarginPct) +
           kpiCard('MRR', k.mrr) +
      '  </div>' +
      '  <div class="clr-panels">' +
           table('Revenue Trend', revenue, ['date', 'revenue', 'cogs', 'grossMargin']) +
           table('Cash Flow', cashFlow, ['date', 'inflows', 'outflows', 'base', 'upside', 'downside']) +
      '  </div>' +
      '</div>';

    document.getElementById('clr-apply-filter').onclick = function () {
      invoke('FilterChanged', {
        range: document.getElementById('clr-range').value || 'year-to-date',
        asOfDate: document.getElementById('clr-asof').value || '',
        glFilter: document.getElementById('clr-glfilter').value || '',
        dimensionCode: document.getElementById('clr-dimcode').value || ''
      });
    };
    document.getElementById('clr-base').onclick = function () { invoke('ScenarioRequested', 'BASE'); };
    document.getElementById('clr-upside').onclick = function () { invoke('ScenarioRequested', 'UPSIDE'); };
    document.getElementById('clr-downside').onclick = function () { invoke('ScenarioRequested', 'DOWNSIDE'); };
    document.getElementById('clr-save-view').onclick = function () { invoke('SaveViewRequested', { code: 'DEFAULT', description: 'Default View' }); };
    document.getElementById('clr-export').onclick = function () { invoke('ExportRequested', 'excel'); };
    document.getElementById('clr-export-pdf').onclick = function () { invoke('ExportRequested', 'pdf'); };
    document.getElementById('clr-setup').onclick = function () { invoke('SetupRequested', ''); };
  }

  window.SendData = function (payloadJson) {
    try {
      state.payload = JSON.parse(payloadJson || '{}');
    } catch (e) {
      state.payload = null;
    }
    render();
  };

  window.SetMode = function (mode) {
    state.mode = mode || 'bi';
    render();
  };

  ensureRoot();
  render();
  invoke('ControlAddInReady', '');
})();
