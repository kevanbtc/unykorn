const Treasury = require('../services/TreasuryService');

class FedwireAdapter {
  constructor(config) {
    this.config = config;
  }
  connect() {
    console.log(`Connecting to Fedwire endpoint ${this.config.endpoint}`);
  }

  async handleIncomingPayment(message) {
    const mintRequest = {
      amount: message.amount,
      beneficiary: message.beneficiaryAccount,
      reference: message.reference,
      bankDetails: { senderABA: message.originatorABA }
    };
    return Treasury.mintFromSettlement(mintRequest);
  }
}
module.exports = FedwireAdapter;
