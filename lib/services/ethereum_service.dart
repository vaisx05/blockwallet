import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class EthereumService {
  final String rpcUrl = "http://192.168.0.105:7545"; // Ganache RPC URL
  // final String rpcUrl = "http://10.0.2.2:7545"; // For Android Emulator
  //final String rpcUrl = "http://127.0.0.1:7545"; // For Android Emulator

  //// final String privateKey =
  // "0x1a7013d295cea4985e88dc4f5891351fbcb02fb95524a939664726c4e7b86485"; //account 1

  final String privateKey =
      "0x4f46ab5b9211e59dcbd85f23a76f295a3f80909f3cf23472b1c2318b25e589f5"; //account 2
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
