const KataNFT = artifacts.require("KataNFT");

module.exports = async function (deployer) {
  await deployer.deploy(KataNFT);
};
