import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class EthereumService {
  final String rpcUrl = "http://192.168.0.103:7545"; // Ganache RPC URL
  // final String rpcUrl = "http://10.0.2.2:7545"; // For Android Emulator
  //final String rpcUrl = "http://127.0.0.1:7545"; // For Android Emulator
// Ganache RPC URL
  final String privateKey =
      "0x3bc02863eb7de6921e9ccc46293b50f4e5f992688eae75f4330e05259504031f";
  // "0x3bc02863eb7de6921e9ccc46293b50f4e5f992688eae75f4330e05259504031f"; // Sender's private key
  final String contractAddress =
      "0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8"; // Contract Address

  late Web3Client client;
  late Credentials credentials;
  late EthereumAddress senderAddress;

  EthereumService() {
    client = Web3Client(rpcUrl, Client());
    credentials = EthPrivateKey.fromHex(privateKey);
    senderAddress = credentials.address;
  }

  /// Send Ether
  Future<String> sendEther(
      EthereumAddress receiverAddress, BigInt amountInWei) async {
    try {
      final transaction = Transaction(
        from: senderAddress,
        to: receiverAddress,
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, amountInWei),
        gasPrice: EtherAmount.inWei(
            BigInt.from(1) * BigInt.from(1000000000)), // 1 Gwei
        maxGas: 21000,
      );

      final txHash = await client.sendTransaction(
        credentials,
        transaction,
        chainId: 1337, // Default Ganache chain ID
      );
      return txHash; // Return transaction hash
    } catch (e) {
      print("Error sending Ether: $e");
      return "Error: $e";
    }
  }

  /// Check Balance
  Future<BigInt> getBalance(EthereumAddress address) async {
    final balance = await client.getBalance(address);
    return balance.getInWei;
  }

  Widget generateQRCode(String ethereumAddress) {
    return QrImageView(
      data: ethereumAddress,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
