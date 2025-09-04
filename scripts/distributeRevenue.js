const hre = require("hardhat");

async function main() {
  const [caller] = await hre.ethers.getSigners();
  const routerAddress = process.env.ROUTER;
  const stableAddress = process.env.STABLE;

  const router = await hre.ethers.getContractAt("RevenueRouter", routerAddress);
  const stable = await hre.ethers.getContractAt("MockStablecoin", stableAddress);

  const amount = hre.ethers.utils.parseEther("1000");
  await stable.approve(router.address, amount);
  await router.distribute(amount);
  console.log("Distributed", hre.ethers.utils.formatEther(amount), "stablecoins");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

