require("@nomicfoundation/hardhat-toolbox");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "sepolia",
  solidity: "0.8.28",

  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/dcRZuzms0ttyvNGeEN1UE",
      accounts: ["0x6e4a6fcf316d086d48e4cdc1e034d3bbecf13459cdfc31dd6391660541beac59","0x8bb2e366f56e5b867099e525443430c4b1f146c59df223fa4e04fb1194f6271b"],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: "dcRZuzms0ttyvNGeEN1UE",
    }
  },
};
