require("@nomicfoundation/hardhat-ethers");

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: { enabled: true, runs: 200 },
    },
  },
  networks: {
    vchain: {
      url: process.env.RPC_URL || "http://127.0.0.1:8545",
      accounts: [process.env.DEPLOYER_KEY].filter(Boolean),
      chainId: 888888,
    },
  },
};
