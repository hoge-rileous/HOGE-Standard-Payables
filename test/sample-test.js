require('dotenv').config()
const { ethers } = require("hardhat");
const { expect } = require("chai");

const erc20 = require("../contracts/erc20.json");

describe("HSP1", async (accounts) => {

  beforeEach(async () => {
    await hre.network.provider.request({
      method: "hardhat_reset",
      params: [
        {
          forking: {
            jsonRpcUrl: process.env.alchemyAPI,
            blockNumber: 14481733,
          },
        },
      ],
    });

  });

  it("should be able to buy and reflect HOGE.", async function () {
    const hoge = await ethers.getContractAt(erc20, "0xfad45e47083e4607302aa43c65fb3106f1cd7607");

    const accounts = await ethers.getSigners();
    const provider = ethers.provider;

    const HSP1 = await ethers.getContractFactory("HogeStandardPayable1");
    const hsp1 = await HSP1.deploy();
    await hsp1.deployed();

    //Get both price readings current.
    await hsp1.updatePrice();
    await hsp1.updatePrice();

    let hsp_eth_balance = await hsp1.provider.getBalance(hsp1.address);

    expect(hsp_eth_balance).to.equal(0);

    // hsp1 receives some revenue
    await accounts[0].sendTransaction({
      to: hsp1.address,
      value: ethers.utils.parseEther("1.0")
    });
    hsp_eth_balance = await hsp1.provider.getBalance(hsp1.address);

    expect(hsp_eth_balance).to.equal(ethers.utils.parseEther("1.0"));

    let hoge_bal = await hoge.balanceOf(hsp1.address);
    expect(hoge_bal).to.equal("0");

    const buy_txn = await hsp1.buyHoge();
    await buy_txn.wait();

    hoge_bal = await hoge.balanceOf(hsp1.address);
    expect(hoge_bal).to.equal("49551805375613625");

    const reflect_txn = await hsp1.reflectHOGE();
    await reflect_txn.wait();

    hoge_bal = await hoge.balanceOf(hsp1.address);
    expect(hoge_bal).to.equal("0");

  });
});