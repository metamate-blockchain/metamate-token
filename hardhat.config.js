// ethers plugin required to interact with the contract
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

const PRIVATE_KEY_BSC = process.env.PRIVATE_KEY_BSC;
const PRIVATE_KEY_OEC = process.env.PRIVATE_KEY_OEC;
const BSC_SCAN_KEY = process.env.BSC_SCAN_KEY;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.2",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      }
    ],
  },
  networks: {
    bsc_testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [PRIVATE_KEY_BSC]
    },
    bsc_mainnet: {
      url: "https://bsc-dataseed.binance.org",
      chainId: 56,
      gasPrice: 20000000000,
      accounts: [PRIVATE_KEY_BSC]
    },
    oec_testnet: {
      url: "https://exchaintestrpc.okex.org",
      chainId: 65,
      gasMultiplier: 2,
      accounts: [PRIVATE_KEY_OEC],
      gasPrice: 20000000000
    },
  },
  etherscan: {
    apiKey: BSC_SCAN_KEY,
  },
};
