const SWIFTAdapter = require('./SWIFTAdapter');
const adapter = new SWIFTAdapter({
  bic: 'UNYKUS33XXX',
  participantId: 'UNYK-123',
  networkAddress: 'swift.example.net',
  certificatePath: './certs/swift.crt'
});
adapter.connect();
