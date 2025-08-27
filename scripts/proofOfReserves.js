const hre = require("hardhat");

async function main() {
  const address = process.env.POR_ADDRESS;
  const Proof = await hre.ethers.getContractAt("ProofOfReserves", address);
  const reserve = await Proof.getLatestReserve();
  console.log(`Latest reported reserve: ${reserve.toString()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
