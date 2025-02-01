import 'package:flutter/material.dart';
import 'package:blockwallet/services/ethereum_service.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class Sendpage extends StatefulWidget {
  const Sendpage({super.key});

  @override
  State<Sendpage> createState() => _SendpageState();
}

class _SendpageState extends State<Sendpage> {
  final EthereumService ethService = EthereumService();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String txHash = "";
  String fullBalance = "0";
  String decimalBalance = "000"; // 3 decimal places

  @override
  void initState() {
    super.initState();
    // Initial fetch
    // Auto-refresh balance every 5 seconds
  }

  @override
  void dispose() {
    addressController.dispose();
    amountController.dispose();
    super.dispose();
  }

  /// Function to send Ether
  void sendEther() async {
    final address = addressController.text;

    // Check if the address is valid (starts with "0x" and has 42 characters)
    if (address.length == 42 && address.startsWith("0x")) {
      final receiverAddress = EthereumAddress.fromHex(address);
      final amountInWei = BigInt.from(
          double.parse(amountController.text) * 1e18); // Convert Ether to Wei

      final result = await ethService.sendEther(receiverAddress, amountInWei);
      setState(() {
        txHash = result;
      });
    } else {
      // Address is invalid, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid Ethereum address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Send Money",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Color(0xFFAEAEAE),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16), // Adds padding for better UI
        children: [
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: "Enter the address",
              labelStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
              border: OutlineInputBorder(
                // Adds a default border
                borderRadius: BorderRadius.circular(10), // Rounded corners
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                // Border when focused
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
          SizedBox(height: 16), // Spacing between text fields
          TextField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: "Enter the amount",
              labelStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            keyboardType: TextInputType.number, // Numeric input for amount
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 10),
            child: Text("Currency: ETH",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                )),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFAB9DFE), // Background color
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: sendEther,
            child: Text("SEND ETHER",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                  color: Color.fromRGBO(255, 255, 255, 1),
                )),
          ),
        ],
      ),
    );
  }
}
