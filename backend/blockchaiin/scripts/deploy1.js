const { ethers } = require("hardhat");

async function main() {
    // Get the deployer's account (Ganache account)
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy the Verifier contract
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    console.log("Verifier contract deployed to:", verifier.address);

    // Deploy the Wallet contract and pass the verifier address as a constructor parameter
    const Wallet = await ethers.getContractFactory("Wallet");
    const wallet = await Wallet.deploy(verifier.address);
    console.log("Wallet contract deployed to:", wallet.address);
}

// Call the main function and catch errors if any
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
