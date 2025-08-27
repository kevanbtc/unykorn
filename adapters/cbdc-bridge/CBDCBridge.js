const Treasury = require('../services/TreasuryService');

class CBDCBridge {
  constructor(config) {
    this.config = config;
  }
  connect() {
    console.log(`Connecting to CBDC network ${this.config.network}`);
  }

  async handleIncomingTransfer(transfer) {
    const mintRequest = {
      amount: transfer.amount,
      beneficiary: transfer.beneficiary,
      reference: transfer.reference,
      bankDetails: { chain: this.config.network }
    };
    return Treasury.mintFromSettlement(mintRequest);
  }
}
module.exports = CBDCBridge;
