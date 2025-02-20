import 'package:hive/hive.dart';

part 'transaction_model.g.dart'; // This is generated after running build_runner

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String recipient;

  @HiveField(1)
  final String amount;

  @HiveField(2)
  final String transactionHash;

  @HiveField(3)
  final DateTime date;

  Transaction({
    required this.recipient, // Named constructor
    required this.amount,
    required this.transactionHash,
    required this.date,
  });
}
