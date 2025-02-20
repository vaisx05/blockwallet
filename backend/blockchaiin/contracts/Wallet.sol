// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Verifier.sol";
import "./Pairing.sol";

contract Wallet {
    using Pairing for Pairing.G1Point;

    mapping(address => uint256) public balances;

    Verifier public verifier;

    constructor(address verifierAddress) {
        verifier = Verifier(verifierAddress);
    }

    // Deposit Ether into the wallet
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Withdraw Ether with zk-SNARK proof validation
    function withdraw(
        uint256 amount,
        Pairing.G1Point memory a,
        Pairing.G2Point memory b,
        Pairing.G1Point memory c,
        uint[2] memory input
    ) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        Verifier.Proof memory proof = Verifier.Proof(a, b, c);
        require(verifier.verifyTx(proof, input), "ZKP Verification Failed");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Send Crypto with zk-SNARK Proof Verification
    function sendWithZKP(
        address recipient,
        uint256 amount,
        Pairing.G1Point memory a,
        Pairing.G2Point memory b,
        Pairing.G1Point memory c,
        uint[2] memory input
    ) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Verify the zk-SNARK proof before sending crypto
        Verifier.Proof memory proof = Verifier.Proof(a, b, c);
        require(verifier.verifyTx(proof, input), "ZKP Verification Failed");

        // Transfer the amount upon successful verification
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }

    // Get balance
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
