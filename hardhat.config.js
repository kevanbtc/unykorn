require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { PRIVATE_KEY, POLYGON_RPC_URL, ETHEREUM_RPC_URL } = process.env;

module.exports = {
  solidity: "0.8.20",
  networks: {
    polygon: {
      url: POLYGON_RPC_URL || "https://polygon-mainnet.g.alchemy.com/v2/YOUR_KEY",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
    ethereum: {
      url: ETHEREUM_RPC_URL || "https://mainnet.infura.io/v3/YOUR_KEY",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
    hardhat: {},
  },
};
