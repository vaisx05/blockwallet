import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class ReceiverViewer extends StatefulWidget {
  @override
  _ReceiverViewerState createState() => _ReceiverViewerState();
}

class _ReceiverViewerState extends State<ReceiverViewer> {
  late Web3Client web3client;
  late DeployedContract contract;
  late EthereumAddress receiverAddress;
  BigInt balance = BigInt.zero;
  String rpcUrl = "http://localhost:7545"; // Ganache RPC

  @override
  void initState() {
    super.initState();
    initializeWeb3();
  }

  Future<void> initializeWeb3() async {
    web3client = Web3Client(rpcUrl, Client());

    // Set the receiver's Ethereum address
    receiverAddress = EthereumAddress.fromHex(
        "0x5b1869d9a4c187f2eaa108f3062412ecf0526b24"); // Change this

    // Load contract
    String abi = await DefaultAssetBundle.of(context)
        .loadString("assets/abi/zkpwallet_abi.json");
    EthereumAddress contractAddress = EthereumAddress.fromHex(
        "0x5b1869D9A4C187F2EAa108f3062412ecf0526b24"); // Change this
    contract = DeployedContract(
        ContractAbi.fromJson(abi, "ZKPWallet"), contractAddress);

    fetchBalance();
    listenToDeposits();
  }

  Future<void> fetchBalance() async {
    final function = contract.function('getBalance');
    final result = await web3client
        .call(contract: contract, function: function, params: []);
    setState(() {
      balance = result.first as BigInt;
    });
  }

  void listenToDeposits() {
    final event = contract.event('Deposit');
    final subscription = web3client
        .events(FilterOptions.events(contract: contract, event: event))
        .listen((log) {
      final decoded = event.decodeResults(log.topics!, log.data!);
      EthereumAddress user = decoded[0] as EthereumAddress;
      BigInt amount = decoded[1] as BigInt;

      if (user == receiverAddress) {
        setState(() {
          balance += amount;
        });
        print("🔔 Received ${amount / BigInt.from(10).pow(18)} ETH from $user");
      }
    });

    // Stop listening when widget is disposed
    @override
    void dispose() {
      subscription.cancel();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receiver Viewer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Received Balance:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "${balance / BigInt.from(10).pow(18)} ETH",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchBalance,
              child: Text("Refresh Balance"),
            ),
          ],
        ),
      ),
    );
  }
}
