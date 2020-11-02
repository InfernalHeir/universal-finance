const HDWalletProvider = require('@truffle/hdwallet-provider');
require("dotenv").config();

const infuraKey = process.env.INFURA_URL;
const privateKey = process.env.PRIVATE_KEY;

module.exports = {

  networks: {
    development: {
      host: "127.0.0.1",    
      port: 8545,        
      network_id: "*"
     },
     rinkyby: {
      provider: () => new HDWalletProvider({
        privateKeys: [privateKey],
        providerOrUrl: infuraKey
      }),
      network_id: 4,
      confirmations: 2,
      timoutBlocks: 2,
      gasPrice: 25e9
      },
  },
  mocha: {
   useColors: true
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.6.0",  
      settings: {    
      optimizer: {
          enabled: false,
          runs: 200
      },
      }
    },
  },
};
