// ethers plugin required to interact with the contract
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const BSC_SCAN_KEY = process.env.BSC_SCAN_KEY;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.2",
      }
    ],
  },
  networks: {
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [PRIVATE_KEY]
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org",
      chainId: 56,
      gasPrice: 20000000000,
      accounts: [PRIVATE_KEY]
    },
  },
  etherscan: {
    apiKey: BSC_SCAN_KEY,
  },
};
