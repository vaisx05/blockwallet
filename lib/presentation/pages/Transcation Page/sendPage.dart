import 'package:flutter/material.dart';
import 'package:blockwallet/services/ethereum_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
  String decimalBalance = "000";

  @override
  void dispose() {
    addressController.dispose();
    amountController.dispose();
    super.dispose();
  }

  /// Function to send Ether
  void sendEther() async {
    final address = addressController.text;
    if (address.length == 42 && address.startsWith("0x")) {
      final receiverAddress = EthereumAddress.fromHex(address);
      final amountInWei =
          BigInt.from(double.parse(amountController.text) * 1e18);

      final result = await ethService.sendEther(receiverAddress, amountInWei);
      setState(() {
        txHash = result;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid Ethereum address')),
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
                    addressController.text = barcode.rawValue!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: addressController,
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
                borderSide: BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                onPressed: openQRScanner,
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: amountController,
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
                borderSide: BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFAB9DFE),
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
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }
}
