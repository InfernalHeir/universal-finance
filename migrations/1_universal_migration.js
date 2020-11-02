const UniversalFinance = artifacts.require("UniversalFinance");

module.exports = async (deployer, accounts) => {
    const tokenName = "Universal Finance";
    const symbol = "UFC";
    const totalSupply = web3.utils.toWei("10000000");     
    await deployer.deploy(UniversalFinance, tokenName, symbol,totalSupply);
}