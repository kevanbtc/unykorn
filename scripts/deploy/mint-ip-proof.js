const hre = require("hardhat");

async function main() {
  const Proof = await hre.ethers.getContractFactory("UnykornESGProof");
  const proof = await Proof.deploy();
  await proof.deployed();

  const tx = await proof.mint("ipfs://hash");
  await tx.wait();

  console.log("Minted ESG proof token");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
