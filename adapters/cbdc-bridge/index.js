const CBDCBridge = require('./CBDCBridge');
const bridge = new CBDCBridge({
  network: 'demo-cbdc',
  apiUrl: 'https://cbdc.example.net'
});
bridge.connect();
