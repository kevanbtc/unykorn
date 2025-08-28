const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('USDxEnterprise and Treasury', function () {
  it('mints via treasury settlement', async function () {
    const [admin, user] = await ethers.getSigners();

    const USDx = await ethers.getContractFactory('USDxEnterprise');
    const usdx = await USDx.deploy(admin.address);
    await usdx.waitForDeployment();

    const Treasury = await ethers.getContractFactory('EnterpriseTreasury');
    const treasury = await Treasury.deploy(await usdx.getAddress(), admin.address);
    await treasury.waitForDeployment();

    // grant treasury role to treasury contract
    await usdx.connect(admin).grantRole(await usdx.TREASURY_ROLE(), await treasury.getAddress());

    const req = { amount: ethers.parseUnits('100'), beneficiary: user.address, reference: 'SWIFT123', sender: admin.address };
    await expect(treasury.connect(admin).mintFromSettlement(req))
      .to.emit(usdx, 'Minted')
      .withArgs(user.address, ethers.parseUnits('100'), 'SWIFT123');

    expect(await usdx.balanceOf(user.address)).to.equal(ethers.parseUnits('100'));
  });
});
