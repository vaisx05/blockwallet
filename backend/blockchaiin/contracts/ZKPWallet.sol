// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Verifier {
    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    struct Proof {
        G1Point a;
        G2Point b;
        G1Point c;
    }

    function verifyTx(Proof memory proof, uint256[2] memory input)
        external
        view
        returns (bool);
}

contract ZKPWallet {
    mapping(address => uint256) public balances; // Map user balances
    Verifier public verifier;

    // Constructor initializes Verifier contract
    constructor(address verifierAddress) {
        verifier = Verifier(verifierAddress);
    }

    // Function to allow deposits
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Function to withdraw funds with a ZKP
    function withdraw(
        uint256 amount,
        Verifier.G1Point memory a,
        Verifier.G2Point memory b,
        Verifier.G1Point memory c,
        uint256[2] memory input
    ) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");


        Verifier.Proof memory proof = Verifier.Proof(a, b, c);


        // Verify the proof
        require(verifier.verifyTx(proof, input), "ZKP Verification Failed");

        // Update balances and transfer funds
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

       
        emit Withdraw(msg.sender, amount);
    }

    // Function to check balance
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    // Events for logging
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
}