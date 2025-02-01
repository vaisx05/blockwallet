import 'dart:async';
import 'package:blockwallet/presentation/pages/Transcation%20Page/ReceivePage.dart';
import 'package:blockwallet/presentation/pages/Transcation%20Page/sendPage.dart';
import 'package:blockwallet/services/ethereum_service.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final EthereumService ethService = EthereumService();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String txHash = "";
  String fullBalance = "0";
  String decimalBalance = "000"; // 3 decimal places
  Timer? balanceUpdateTimer;

  @override
  void initState() {
    super.initState();
    fetchBalance(); // Initial fetch
    // Auto-refresh balance every 5 seconds
  }

  @override
  void dispose() {
    balanceUpdateTimer?.cancel();
    addressController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void fetchBalance() async {
    final balance = await ethService.getBalance(ethService.senderAddress);
    final ethBalance = balance / BigInt.from(1e18); // Convert Wei to ETH

    setState(() {
      fullBalance = ethBalance.toInt().toString(); // Full ETH value
      decimalBalance = (ethBalance - ethBalance.toInt())
          .toStringAsFixed(3)
          .split('.')[1]; // Decimal part (3 digits)
    });
  }

  /// Function to send Ether
  void sendEther() async {
    final receiverAddress = EthereumAddress.fromHex(addressController.text);
    final amountInWei = BigInt.from(
        double.parse(amountController.text) * 1e18); // Convert Ether to Wei

    final result = await ethService.sendEther(receiverAddress, amountInWei);
    setState(() {
      txHash = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // Set custom height
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Image.asset('assets/icons/icons8-menu-squared-50.png'),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                children: [
                  Image.asset('assets/icons/icons8-add-50.png',
                      width: 60, height: 80),
                  Image.asset('assets/icons/icons8-visa-50.png',
                      width: 60, height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current value",
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 35,
                          color: Color(0xFFAEAEAE)),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$fullBalance.", // Main amount
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 50,
                              color: Color(0xFF1C1717),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: "$decimalBalance ETH", // Decimal part
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 50, // Slightly smaller size (optional)
                              color:
                                  Color(0xFFAEAEAE), // Change this to any color
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      fetchBalance();
                      print("refreshed");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.refresh,
                        size: 40,
                      ),
                    ))
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Sendpage()), // Create instance here
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 70,
                    width: 180,
                    color: Color(0xFFF2F2F4),
                    child: Row(
                      children: [
                        // Add Circle inside Row
                        SizedBox(
                          width: 2,
                        ),
                        CircleAvatar(
                          radius: 22, // Set the size of the circle
                          backgroundColor: Color(0xFFAB9DFE), // Circle color
                          child: Icon(
                            Icons.arrow_forward, // Icon inside circle
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                            width: 10), // Space between the circle and the text
                        Text(
                          "Send",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ReceivePage()), // Create instance here
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 70,
                    width: 180,
                    color: Color(0xFFF2F2F4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 2,
                        ),
                        CircleAvatar(
                          radius: 22, // Set the size of the circle
                          backgroundColor: Color(0xFFAB9DFE), // Circle color
                          child: Icon(
                            Icons.arrow_downward, // Icon inside circle
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                            width: 10), // Space between the circle and the text
                        Text(
                          "Receive",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
