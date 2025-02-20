require('dotenv').config();
const Web3 = require('web3');
const { Pool } = require('pg');

// Connect to Ganache
const web3 = new Web3(new Web3.providers.HttpProvider('http://172.17.17.210:7545')); // Ganache RPC URL

// PostgreSQL Connection
const pool = new Pool({
    user: 'postgres', // Your PostgreSQL username
    host: 'localhost',
    database: 'crypto_db', // Your database name
    password: '2004', // Your PostgreSQL password
    port: 5432,
});

// Function to fetch and store addresses with usernames
const storeGanacheAddresses = async () => {
    try {
        // Get accounts from Ganache
        const accounts = await web3.eth.getAccounts();
        console.log('Fetched Ganache Addresses:', accounts);

        // Example usernames (replace with actual usernames)
        const usernames = ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7', 'user8', 'user9', 'user10'];

        // Insert each address with a corresponding username
        for (let i = 0; i < accounts.length; i++) {
            const address = accounts[i];
            const username = usernames[i] || `user${i + 1}`; // Assign usernames dynamically if not provided

            await pool.query(
                'INSERT INTO crypto_wallets (address, username) VALUES ($1, $2) ON CONFLICT (address) DO UPDATE SET username = EXCLUDED.username',
                [address, username]
            );
        }
        console.log('Addresses and usernames stored in PostgreSQL');
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        pool.end(); // Close the database connection
    }
};

// Run the function
storeGanacheAddresses();
