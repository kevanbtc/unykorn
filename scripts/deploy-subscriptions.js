const hre = require("hardhat");

async function main() {
  const registryAddr = process.env.COMPLIANCE_REGISTRY;
  const tokenAddr = process.env.VTV_TOKEN;
  if (!registryAddr || !tokenAddr) throw new Error("COMPLIANCE_REGISTRY and VTV_TOKEN required");

  const price = hre.ethers.parseUnits("199", 18);
  const Subs = await hre.ethers.getContractFactory("CompliantSubscription");
  const subs = await Subs.deploy(registryAddr, tokenAddr, price, 1500); // 15% commission
  await subs.deployed();
  console.log("CompliantSubscription deployed:", subs.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
