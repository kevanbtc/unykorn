const Treasury = require('../services/TreasuryService');

class SWIFTAdapter {
  constructor(config) {
    this.config = config;
  }
  connect() {
    console.log(`Connecting to SWIFT network at ${this.config.networkAddress}`);
  }

  async handleIncomingPayment(mt103) {
    const mintRequest = {
      amount: mt103.textBlock.amount,
      beneficiary: mt103.textBlock.beneficiaryCustomer.account,
      reference: mt103.textBlock.transactionReference,
      bankDetails: { senderBIC: mt103.textBlock.orderingInstitution.bic }
    };
    const result = await Treasury.mintFromSettlement(mintRequest);
    await this.sendStatusReport(mt103.textBlock.transactionReference, 'CONFIRMED');
    return result;
  }

  async sendStatusReport(reference, status) {
    console.log(`SWIFT status for ${reference}: ${status}`);
  }
}
module.exports = SWIFTAdapter;
