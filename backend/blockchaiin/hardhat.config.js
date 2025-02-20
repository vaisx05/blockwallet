require("@nomiclabs/hardhat-ethers");

module.exports = {
    solidity: "0.8.20",
    networks: {
        localhost: {
            url: "http://172.17.17.210:7545",
            accounts: ["0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d"],  // Ensure Ganache/Hardhat node is running
        },
    },
};
