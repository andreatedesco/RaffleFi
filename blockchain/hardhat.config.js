require('dotenv').config();
require("@nomiclabs/hardhat-waffle");
require("@nomicfoundation/hardhat-verify");

const { 
  API_URL_AMOY,
  POLYGONSCAN_API_KEY, 
  PRIVATE_KEY_00, 
  PRIVATE_KEY_01, 
  PRIVATE_KEY_02, 
  PRIVATE_KEY_03, 
  PRIVATE_KEY_04, 
  PRIVATE_KEY_05, 
} = process.env;

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      // viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    artifacts: "./src/artifacts",
  },
  networks: {
    hardhat: {
    },
    polygonAmoy: {
      url: API_URL_AMOY,
      accounts: 
      [
        PRIVATE_KEY_00,
        PRIVATE_KEY_01,
        PRIVATE_KEY_02,
        PRIVATE_KEY_03,
        PRIVATE_KEY_04,
        PRIVATE_KEY_05,
      ],
    },
  },
  etherscan: {
    apiKey: {
        polygonAmoy: POLYGONSCAN_API_KEY,
    },
    customChains: [
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com"
        },
      }
    ]
  }
};