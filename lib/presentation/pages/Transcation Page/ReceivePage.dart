import 'package:flutter/material.dart';
import 'package:blockwallet/services/ethereum_service.dart';
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
          "Receive ETH",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Color(0xFFAEAEAE),
          ),
        ),
      ),
      body: ListView(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 250,
                height: 40,
                //  color: Color(0xFFAB9DFE),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text("Ethereum Test Network | 🟢",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFFAB9DFE))),
                ),
              ),
            ),
            Text("Scan this QR to receive ETH",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                )),

            // ✅ Generate and Display QR Code
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFFAB9DFE),
              ),
              child: QrImageView(
                data:
                    ethService.senderAddress.hex, // Ethereum Address as QR Code
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),

            Text("Account Address",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                )),
            Container(
              width: 160,
              child: Text(
                ethService.senderAddress.hex, // Display Address Below QR
                // textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
