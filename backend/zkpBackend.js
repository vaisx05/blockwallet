const express = require('express');
const { execSync } = require('child_process');
const Web3 = require('web3');
const fs = require('fs');

const app = express();
app.use(express.json()); // Middleware to parse JSON

// Web3 setup (RPC provider for Ganache)
const web3 = new Web3("ip:port"); // Replace with your RPC provider URL

// ZoKrates binary path and workspace directory
const zoKratesPath = "/usr/local/bin/zokrates"; // Adjust this if necessary
const zkkPath = "/home/sha/WinVol3/Projectsha/blockwallet/backend/zkk"; // Working directory for ZoKrates

// Address of your deployed smart contract
const contractAddress = ""; // Replace with the correct deployed smart contract address

// Smart contract ABI (double-check this with your compiled contract)
const contractABI = []

// Create a contract instance
const contract = new web3.eth.Contract(contractABI, contractAddress);

app.post('/generate-proof', async (req, res) => {
    try {
        const { secretValue } = req.body; // Expecting a secret value from the client request

        // Change directory to ZoKrates workspace and compute the witness using the provided secretValue
        execSync(`cd ${zkkPath} && ${zoKratesPath} compute-witness -a ${secretValue}`, { stdio: 'inherit' });

        // Generate the proof
        execSync(`cd ${zkkPath} && ${zoKratesPath} generate-proof`, { stdio: 'inherit' });

        // Read the generated proof from the `proof.json` file
        const proofData = JSON.parse(fs.readFileSync(`${zkkPath}/proof.json`, 'utf8'));

        // Structure the proof for the `/sendWithZKP` endpoint
        const proof = {
            a: proofData.proof.a,
            b: proofData.proof.b,
            c: proofData.proof.c,
        };

        // Prepare public inputs
        // IMPORTANT: Adjust the calculation of public inputs as needed based on your circuit logic
        const publicInputs = proofData.inputs;

        // Respond with the proof and public inputs
        res.json({
            proof,
            publicInputs,
        });
    } catch (err) {
        console.error('Error generating proof:', err);
        res.status(500).json({ error: 'Failed to generate proof' });
    }
});
// Endpoint to send a transaction with a ZKP
app.post('/sendWithZKP', async (req, res) => {
    try {
        const { recipient, amount, proof, publicInputs } = req.body;

        // Get the first account from the provider
        const accounts = await web3.eth.getAccounts();
        const senderAddress = accounts[0]; // Assume the sender is the first account

        // Send the transaction by invoking the `withdraw` function
        const tx = await contract.methods
            .withdraw(amount, proof.a, proof.b, proof.c, publicInputs)
            .send({ from: senderAddress });

        // Respond with the transaction hash
        res.json({ transactionHash: tx.transactionHash });
    } catch (err) {
        console.error('Error processing transaction:', err);
        res.status(500).json({ error: 'Failed to process transaction' });
    }
});

// Endpoint: Fetch account (wallet) balance
app.get('/getBalance', async (req, res) => {
    try {
        const senderAddress = ""; // Replace with the sender's Ethereum address
        const balance = await web3.eth.getBalance(senderAddress); // Balance in wei
        const balanceInEth = web3.utils.fromWei(balance, 'ether'); // Convert wei to ether
        res.json({ balance, balanceInEth });
    } catch (err) {
        console.error('Error fetching wallet balance:', err);
        res.status(500).json({ error: 'Failed to fetch wallet balance' });
    }
});

// Start the Express server
const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Backend running on http://localhost:${PORT}`);
});


