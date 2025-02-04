import 'package:flutter/material.dart';

import '../../../services/ethereum_service.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final EthereumService ethService = EthereumService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 25.0,
            ),
            child: Container(
              width: 330,
              height: 175,
              decoration: BoxDecoration(
                // shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/icons/profile.jpg'),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  const Text(
                    "Account 2", // Display the dynamically fetched user name
                    style: TextStyle(
                        fontFamily: 'AirbnbCereal',
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    ethService.senderAddress.hex, // Display Address Below QR
                    // textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 25.0,
            ),
            child: Column(children: [
              createInfoTile(
                title: 'Locations',
                img: 'assets/icons/icons8-location-48.png',
              ),
              const SizedBox(
                height: 10,
              ),
              createInfoTile(
                title: 'Current Location',
                img: 'assets/icons/icons8-location-48.png',
              ),
            ]),
          )
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

Widget createInfoTile({required String title, required String img}) {
  return Container(
    width: 380,
    height: 60,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 8),
          child: SizedBox(
            height: 35,
            child: Image(
              image: AssetImage(img),
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
