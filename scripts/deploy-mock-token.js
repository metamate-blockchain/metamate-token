const { ethers } = require("hardhat");

// Deploy token script
async function main() {
   // We get the contract to deploy
   const MockToken = await ethers.getContractFactory('MockToken');
   console.log('Deploying MockToken...');

   // Instantiating a new MTMToken smart contract
   const mockToken = await MockToken.deploy("MTM TOKEN", "MTM");

   // Waiting for the deployment to resolve
   await mockToken.deployed();
   console.log('MockToken deployed to:', mockToken.address);
}

main()
   .then(() => process.exit(0))
   .catch((error) => {
      console.error(error);
      process.exit(1);
   });