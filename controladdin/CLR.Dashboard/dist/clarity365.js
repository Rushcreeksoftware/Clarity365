(function(){
  function ensureRoot() {
    var root = document.getElementById('root');
    if (!root) {
      root = document.createElement('div');
      root.id = 'root';
      document.body.appendChild(root);
    }
    root.innerHTML = '<div style="font-family:Segoe UI,sans-serif;padding:16px;">Clarity365 dashboard bundle placeholder loaded.</div>';
  }

  window.SendData = function(payloadJson) {
    if (window.receiveFromBC) {
      window.receiveFromBC(payloadJson || '{}');
    }
  };

  window.SetMode = function(mode) {
    if (window.setModeFromBC) {
      window.setModeFromBC(mode || 'bi');
    }
  };

  ensureRoot();
  try {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady', ['']);
  } catch (e) {}
})();
