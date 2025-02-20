import 'dart:convert';
import 'package:blockwallet/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;


class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('transactions');
    final transactions = box.values.toList().cast<Transaction>();

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: transactions.isEmpty
          ? const Center(child: Text("No transactions yet."))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  child: ListTile(
                    title: Text("To: ${transaction.recipient}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Amount: ${transaction.amount} ETH"),
                        Text("Tx Hash: ${transaction.transactionHash}"),
                        Text("Date: ${transaction.date}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => fetchTransactionDetails(transaction.transactionHash, context),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> fetchTransactionDetails(String txHash, BuildContext context) async {
    final url = Uri.parse("http://localhost:7545");
    final requestBody = {
      "jsonrpc": "2.0",
      "method": "eth_getTransactionReceipt",
      "params": [txHash],
      "id": 1
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final receipt = responseData["result"];
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Transaction Details"),
            content: Text("Block Hash: ${receipt['blockHash']}\n"
                          "Gas Used: ${receipt['gasUsed']}\n"
                          "Status: ${receipt['status']}"),
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
        throw Exception("Failed to fetch transaction details: ${response.body}");
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: Text("Error fetching transaction details: $error"),
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
  }
}
