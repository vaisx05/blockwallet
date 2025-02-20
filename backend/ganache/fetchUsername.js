
// require('dotenv').config();
// const express = require('express');
// const Web3 = require('web3');
// const { Pool } = require('pg');

// const app = express();
// const port = 3000;

// app.use(express.json()); // Middleware to parse JSON request bodies

// // PostgreSQL Connection
// const pool = new Pool({
//     user: 'postgres',
//     host: 'localhost',
//     database: 'crypto_db',
//     password: '2004',
//     port: 5432,
// });

// // Fetch user's Ethereum address by username
// app.get('/getAddress/:username', async (req, res) => {
//     const username = req.params.username;

//     try {
//         const result = await pool.query(
//             'SELECT address FROM crypto_wallets WHERE username = $1',
//             [username]
//         );

//         if (result.rows.length === 0) {
//             return res.status(404).json({ error: "No address found for this user" });
//         }

//         res.json({ address: result.rows[0].address });
//     } catch (error) {
//         console.error('Error:', error.message);
//         res.status(500).json({ error: "Internal Server Error" });
//     }
// });

// // Start the server
// app.listen(port, () => {
//     console.log(`Server running on http://localhost:${port}`);
// });

require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(express.json()); // Middleware to parse JSON request bodies
app.use(cors()); // Enable CORS for frontend requests

// PostgreSQL Connection
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'crypto_db',
    password: '2004',
    port: 5432,
});

// Fetch user's Ethereum address by username
app.get('/getAddress/:username', async (req, res) => {
    const username = req.params.username;

    try {
        const result = await pool.query(
            'SELECT address FROM crypto_wallets WHERE username = $1',
            [username]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "No address found for this user" });
        }

        res.json({ address: result.rows[0].address });
    } catch (error) {
        console.error('Error:', error.message);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

// 🔎 Search usernames dynamically
// app.get('/searchUsers', async (req, res) => {
//     const query = req.query.query || "";

//     try {
//         const result = await pool.query(
//             "SELECT username FROM crypto_wallets WHERE username ILIKE $1 LIMIT 10",
//             [`%${query}%`]
//         );

//         res.json(result.rows.map(row => row.username));
//     } catch (error) {
//         console.error('Error:', error.message);
//         res.status(500).json({ error: "Internal Server Error" });
//     }
// });

app.get('/searchUsers', async (req, res) => {
    const query = req.query.query || "";

    try {
        const result = await pool.query(
            "SELECT username FROM crypto_wallets WHERE username ILIKE $1 ORDER BY username ASC LIMIT 10",
            [`${query}%`]  // Suggest only usernames starting with the query
        );

        res.json(result.rows.map(row => row.username));
    } catch (error) {
        console.error('Error:', error.message);
        res.status(500).json({ error: "Internal Server Error" });
    }
});


// Start the server
app.listen(port, () => {
    console.log(`🚀 Server running on http://localhost:${port}`);
});
