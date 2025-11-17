
const { ethers } = require("hardhat");

async function main() {
    const FundMe = await ethers.getContractFactory("FundMe");
    const fundMe = await FundMe.deploy(10);
    await fundMe.waitForDeployment();
    console.log("FundMe deployed to:", fundMe.target);
}

main().catch((error)=>{
    console.error(error);
    process.exitCode=1;
});