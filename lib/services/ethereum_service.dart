import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class EthereumService {
  //final String rpcUrl = "http://172.168.11.183:7545"; // Ganache RPC URL
  final String rpcUrl = "http://172.17.17.210:7545"; // For Android Emulator
  //final String rpcUrl = "http://127.0.0.1:7545"; // For Android Emulator

  //final String privateKey =
  //  "0x1a7013d295cea4985e88dc4f5891351fbcb02fb95524a939664726c4e7b86485"; //account 1

  final String privateKey =
      "0xfdcd05de0be19a735c3669a3815d0ea240efc99b3e93f9b6bf35c8c4b90bfa1e";

  final String contractAddress = "0x1dfcde8331779a3ca41e789620ce5afaa5871f86";
  //final String contractAddress = "0x43b7385A6d048dE2f1727E688A6Cdd9638B48905";
  //   "0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8"; // Contract Address

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
