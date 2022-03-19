// Make sure the DevToken contract is included by requireing it.
const BIGGYTOKEN = artifacts.require("BIGGYTOKEN");

// THis is an async function, it will accept the Deployer account, the network, and eventual accounts.
module.exports = async function (deployer, network, accounts) {
  // await while we deploy the DevToken
  await deployer.deploy(BIGGYTOKEN, "Biggytoken", "BGT", 18, 1000);
  const Biggytoken = await BIGGYTOKEN.deployed()

};