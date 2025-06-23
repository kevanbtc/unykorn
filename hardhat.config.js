require('@nomiclabs/hardhat-ethers');

const dotenv = require('dotenv');
dotenv.config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: '0.8.20',
        settings: {},
        path: require.resolve('solc/soljson.js'),
      },
    ],
  },
  networks: {
    polygon: {
      url: process.env.POLYGON_RPC_URL || '',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    },
  }
};
