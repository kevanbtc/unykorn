const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Compliance modules', function () {
  it('computes Basel III capital ratio', async function () {
    const Basel = await ethers.getContractFactory('BaselIIICompliance');
    const basel = await Basel.deploy();
    await basel.waitForDeployment();
    const ratio = await basel.capitalRatio(ethers.parseUnits('10'), ethers.parseUnits('100'));
    expect(ratio).to.equal(ethers.parseUnits('0.1'));
  });

  it('emits Travel Rule event', async function () {
    const Travel = await ethers.getContractFactory('TravelRuleCompliance');
    const travel = await Travel.deploy();
    await travel.waitForDeployment();
    await expect(
      travel.notifyTransfer(
        '0x0000000000000000000000000000000000000001',
        '0x0000000000000000000000000000000000000002',
        1,
        'info'
      )
    ).to.emit(travel, 'TransferNotified');
  });
});
