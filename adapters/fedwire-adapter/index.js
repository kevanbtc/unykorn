const FedwireAdapter = require('./FedwireAdapter');
const adapter = new FedwireAdapter({
  participantId: 'UNYK-456',
  endpoint: 'https://fedwire.example.net'
});
adapter.connect();
