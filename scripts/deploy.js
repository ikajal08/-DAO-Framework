const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying DAOFramework with deployer:", deployer.address);

  const DAOFramework = await ethers.getContractFactory("DAOFramework");
  const dao = await DAOFramework.deploy(deployer.address);

  await dao.deployed();
  console.log("DAOFramework deployed at:", dao.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
