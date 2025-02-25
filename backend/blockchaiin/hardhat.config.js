require("@nomiclabs/hardhat-ethers");

module.exports = {
    solidity: "0.8.20",
    networks: {
        localhost: {
            url: "ip:port",
            accounts: ["address"],  // Ensure Ganache/Hardhat node is running
        },
    },
};
