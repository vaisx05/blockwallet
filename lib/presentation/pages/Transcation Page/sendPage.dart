import 'package:blockwallet/presentation/pages/Transcation%20History/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:blockwallet/services/ethereum_service.dart';
import 'package:hive/hive.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:blockwallet/model/transaction_model.dart';

import 'package:web3dart/web3dart.dart' hide Transaction;

class Sendpage extends StatefulWidget {
  const Sendpage({super.key});

  @override
  State<Sendpage> createState() => _SendpageState();
}

class _SendpageState extends State<Sendpage> {
  final EthereumService ethService = EthereumService();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;

  String txHash = "";
  String fullBalance = "0";
  String decimalBalance = "000";

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Generates proof by calling the `/generate-proof` endpoint
  Future<Map<String, dynamic>> generateProof(String secretValue) async {
    final url = Uri.parse('http://ip:port/generate-proof');

    final requestBody = {
      'secretValue': secretValue, // Secret value here
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Returns proof and publicInputs
      } else {
        throw Exception("Failed to generate proof: ${response.body}");
      }
    } catch (error) {
      throw Exception("Error during proof generation: $error");
    }
  }

  Future<void> sendTransactionWithProof(String recipient, String amount,
      Map<String, dynamic> proof, List<dynamic> publicInputs) async {
    final url = Uri.parse('http://172.17.17.210:5000/sendWithZKP');

    final requestPayload = {
      'sender':
          '0xfdcd05de0be19a735c3669a3815d0ea240efc99b3e93f9b6bf35c8c4b90bfa1e',
      'recipient': recipient,
      'amount': amount,
      'proof': proof,
      'publicInputs': publicInputs,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestPayload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String txHash = responseData['transactionHash'];

        // Save transaction locally
        final box = Hive.box('transactions');
        final newTransaction = Transaction(
          recipient: recipient,
          amount: amount,
          transactionHash: txHash,
          date: DateTime.now(),
        );
        box.add(newTransaction);

        // Show success dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Transaction Success"),
            content: Text("Transaction Hash: $txHash"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        throw Exception("Failed to send transaction: ${response.body}");
      }
    } catch (error) {
      showErrorDialog("Error sending transaction: $error");
    }
  }

  void onSendTransactionPressed() async {
    final recipient = _recipientController.text;
    final amount = _amountController.text;

    if (recipient.isEmpty || amount.isEmpty) {
      showErrorDialog("Please fill in all fields");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Generate proof using the amount as the secret value
      final proofResponse = await generateProof(amount);

      // Extract proof and publicInputs from response
      final proof = proofResponse['proof'];
      final publicInputs = proofResponse['publicInputs'];

      // Step 2: Send the transaction with the generated proof
      await sendTransactionWithProof(recipient, amount, proof, publicInputs);
    } catch (error) {
      showErrorDialog("Error: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Function to send Ether
  void sendEther() async {
    final address = _recipientController.text;
    if (address.length == 42 && address.startsWith("0x")) {
      final receiverAddress = EthereumAddress.fromHex(address);
      final amountInWei =
          BigInt.from(double.parse(_amountController.text) * 1e18);

      final result = await ethService.sendEther(receiverAddress, amountInWei);
      setState(() {
        txHash = result;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Ethereum address')),
      );
    }
  }

  /// Open QR Scanner to Scan Address
  void openQRScanner() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 300,
          height: 400,
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    _recipientController.text = barcode.rawValue!;
                  });
                  Navigator.pop(context);
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  List<String> _suggestions = [];

  Future<void> _fetchUsernames(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final url = Uri.parse('http://172.17.17.210:3000/searchUsers?query=$query');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _suggestions = data.map((e) => e.toString()).toList();
        });
      }
    } catch (error) {
      print("Error fetching usernames: $error");
    }
  }

  Future<void> _fetchUserAddress(String username) async {
    final url = Uri.parse('http://172.17.17.210:3000/getAddress/$username');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _addressController.text = data['address'] ?? "No address found";
        });
      } else {
        setState(() {
          _addressController.text = "No address found";
        });
      }
    } catch (error) {
      print("Error fetching address: $error");
      setState(() {
        _addressController.text = "Error fetching address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Send",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ethereum Address Field
          // TextField(
          //   controller: _recipientController,
          //   decoration: InputDecoration(
          //     labelText: "Name",
          //     labelStyle: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.w400,
          //       fontFamily: 'Poppins',
          //       color: Colors.grey[600],
          //     ),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: const BorderSide(color: Colors.grey, width: 2),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: const BorderSide(color: Colors.blue, width: 2),
          //     ),
          //   ),
          // ),

          _buildUsernameSearchField(),

          const SizedBox(height: 16),
          TextField(
            controller: _recipientController,
            decoration: InputDecoration(
              labelText: "Enter the address",
              labelStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                onPressed: openQRScanner,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Amount Field
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: "Enter the amount",
              labelStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Colors.grey[600],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Send Button
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAB9DFE),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onSendTransactionPressed,
                  child: const Text("SEND ETHER",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lato',
                        color: Colors.white,
                      )),
                ),

          const SizedBox(height: 20),
          // QR Code for Sender's Address
          const Text(
            'Your Ethereum Address QR Code:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ethService.generateQRCode(ethService.senderAddress.hex),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TransactionHistoryPage()),
              );
            },
            child: const Text("View Transaction History"),
          )
          // Display Sender's QR Code
        ],
      ),
    );
  }

  Widget _buildUsernameSearchField() {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: "Search Username",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: _fetchUsernames,
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_suggestions[index]),
                onTap: () {
                  if (_suggestions.isNotEmpty && index < _suggestions.length) {
                    String selectedUsername = _suggestions[index];
                    _usernameController.text = selectedUsername;
                    _fetchUserAddress(selectedUsername);

                    setState(() {
                      _suggestions = [];
                    });
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
