# BlockWallet

BlockWallet is a decentralized wallet application built with Flutter for the frontend and Node.js (Express) for the backend. It supports secure Ethereum transactions, QR code payments, username-based transfers, and privacy-preserving zero-knowledge proof (ZKP) features.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Flutter Frontend](#flutter-frontend)
  - [Node.js Backend](#nodejs-backend)
- [Configuration](#configuration)
- [Usage](#usage)
- [Terms & Conditions](#terms--conditions)
- [License](#license)

---

## Features

- 🦄 **Modern Flutter UI**: Cross-platform, responsive, and beautiful.
- 🔒 **Ethereum Wallet**: Send/receive ETH, view balances, and transaction history.
- 🧑‍💻 **Username-based Transfers**: Send ETH using usernames instead of addresses.
- 📱 **QR Code Support**: Scan and generate QR codes for wallet addresses.
- 🕵️ **Zero-Knowledge Proofs**: Privacy-preserving transactions using ZKP.
- 🗄️ **Local Storage**: Transaction history stored securely with Hive.
- 🌐 **Backend API**: Node.js server for user management and ZKP proof generation.

---

## Architecture

```
Flutter (Frontend) <----> Node.js/Express (Backend) <----> Ethereum Blockchain
```

- **Flutter**: Handles wallet UI, QR, and user interactions.
- **Node.js/Express**: Provides REST APIs for user lookup, ZKP proof generation, and interacts with Ethereum via Web3.
- **PostgreSQL**: (Optional) Used for storing user <-> address mappings.

---

## Getting Started

### Flutter Frontend

1. **Install Flutter**: [Flutter Install Guide](https://docs.flutter.dev/get-started/install)
2. **Clone the repository**:
    ```sh
    git clone https://github.com/yourusername/blockwallet.git
    cd blockwallet
    ```
3. **Install dependencies**:
    ```sh
    flutter pub get
    ```
4. **Run the app**:
    ```sh
    flutter run
    ```

### Node.js Backend

1. **Install Node.js**: [Node.js Download](https://nodejs.org/)
2. **Install dependencies**:
    ```sh
    cd backend
    npm install
    ```
3. **Configure environment variables** (see `.env.example` or set directly in code).
4. **Start the server**:
    ```sh
    node zkpBackend.js
    ```
   For username/address API:
    ```sh
    node ganache/fetchUsername.js
    ```

---

## Configuration

- **Flutter**: Edit `lib/services/ethereum_service.dart` to set your Ethereum RPC URL, private key, and contract address.
- **Backend**: Set your Ganache/Infura RPC URL, contract ABI/address, and PostgreSQL credentials in the backend files or via environment variables.

---

## Usage

- **Send ETH**: Enter a username or address, specify amount, and send.
- **Receive ETH**: Share your QR code or address.
- **Transaction History**: View all past transactions in the app.
- **Privacy**: ZKP is used for privacy-preserving transactions (backend must be running).

---

## Terms & Conditions

By using BlockWallet, you agree to the following terms:

1. **No Warranty**: BlockWallet is provided "as is" without warranty of any kind. Use at your own risk.
2. **Security**: You are responsible for safeguarding your private keys and credentials. The developers are not liable for any loss of funds.
3. **Open Source**: This project is open source and intended for educational and experimental purposes. Do not use with mainnet funds.
4. **Privacy**: No personal data is collected by the app. All sensitive operations are performed locally or on your chosen backend.
5. **Compliance**: You are responsible for complying with local laws and regulations regarding cryptocurrency usage.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## Contact

For support or questions, open an issue or contact [thangarajk176@example.com](mailto:thangarajk176@example.com).
