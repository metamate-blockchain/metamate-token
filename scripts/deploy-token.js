// Deploy token script
async function main() {
    // We get the contract to deploy
    const MTMToken = await ethers.getContractFactory('MTMToken');
    console.log('Deploying MTMToken...');
 
    // Instantiating a new MTMToken smart contract
    const mtmToken = await MTMToken.deploy();
 
    // Waiting for the deployment to resolve
    await mtmToken.deployed();
    console.log('MTMToken deployed to:', mtmToken.address);
 }
 
 main()
    .then(() => process.exit(0))
    .catch((error) => {
       console.error(error);
       process.exit(1);
    });