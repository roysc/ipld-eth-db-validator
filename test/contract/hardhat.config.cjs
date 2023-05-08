require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const local_network = {
  url: process.env.ETH_ADDR || "http://127.0.0.1:8545",
  chainId: Number(process.env.ETH_CHAIN_ID) || 99,
};

if (process.env.DEPLOYER_PRIVATE_KEY) {
  // local_network["deployer"] = process.env.DEPLOYER_PRIVATE_KEY;
  local_network["accounts"] = [process.env.DEPLOYER_PRIVATE_KEY];
}

module.exports = {
  solidity: "0.8.0",
  networks: { local: local_network },
  defaultNetwork: "local"
};