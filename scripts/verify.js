const hre = require("hardhat");

async function main() {
  const address = process.env.CONTRACT_ADDRESS;
  if (!address) throw new Error("CONTRACT_ADDRESS env var missing");
  await hre.run("verify:verify", { address });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
