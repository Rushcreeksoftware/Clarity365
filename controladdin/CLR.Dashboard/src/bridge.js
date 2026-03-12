const BC = {
  sendToBC: (eventName, payload) => {
    try {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
        eventName,
        [typeof payload === 'string' ? payload : JSON.stringify(payload)]
      );
    } catch (e) {
      console.warn('Clarity365 BC bridge unavailable (dev mode):', e.message);
    }
  },
  ready: () => BC.sendToBC('ControlAddInReady', '')
};

window.receiveFromBC = null;
window.setModeFromBC = null;

export default BC;
