
const hre = require("hardhat");
const { ethers } = hre;

async function main() {
    const FundMe = await ethers.getContractFactory("FundMe");
    const fundMe = await FundMe.deploy(100);
    await fundMe.waitForDeployment();
    await fundMe.deploymentTransaction().wait(2);
    await verifyFundMe(fundMe.target, [100])
    console.log("FundMe deployed to:", fundMe.target);
    const [a1,a2] = await ethers.getSigners();
    const fundtx = await fundMe.fund({value: ethers.parseEther("0.01")});
    await fundtx.wait();
    let bl=await ethers.provider.getBalance(fundMe.target);
    console.log("Balance of fundMe:", bl);

    const fundtx2 = await fundMe.connect(a2).fund({value: ethers.parseEther("0.02")});
    await fundtx2.wait();
    bl=await ethers.provider.getBalance(fundMe.target);
    console.log("Balance of fundMe:", bl);

    const a1b = await fundMe.fundersToAmount(a1.address);
    const a2b = await fundMe.fundersToAmount(a2.address);
    console.log("Balance of a1:", a1b);
    console.log("Balance of a2:", a2b);
}

async function verifyFundMe(fundMeAddr, args) {
    await hre.run("verify:verify", {
        address: fundMeAddr,
        constructorArguments: args,
      });
}

main().catch((error)=>{
    console.error(error);
    process.exitCode=1;
});