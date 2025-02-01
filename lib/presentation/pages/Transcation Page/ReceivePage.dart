import 'package:flutter/material.dart';
import 'package:blockwallet/services/ethereum_service.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  final EthereumService ethService = EthereumService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Receive",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
      ),
      body: ListView(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            Container(
              width: 280,
              height: 40,
              //  color: Color(0xFFAB9DFE),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text("Ethereum Test Network | 🟢",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black54)),
              ),
            ),

            // ✅ Generate and Display QR Code
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey, // Set the border color
                  width: 2.0, // Set the border width
                ),
              ),
              child: QrImageView(
                data:
                    ethService.senderAddress.hex, // Ethereum Address as QR Code
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),

            Text("Account 1",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                )),
            SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: Text(
                ethService.senderAddress.hex, // Display Address Below QR
                // textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.blueGrey),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min, // Ensures minimal spacing
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: ethService.senderAddress.hex));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Address copied to clipboard!')),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, color: Colors.black, size: 20),
                      SizedBox(width: 4), // Adjust spacing
                      Text(
                        "Copy address",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
