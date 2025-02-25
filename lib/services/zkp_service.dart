import 'dart:convert';
import 'package:http/http.dart' as http;

class ZkpService {
  Future<bool> verifyProof(Map<String, dynamic> proof) async {
    final response = await http.post(
      Uri.parse("http://localhost:3000/verify"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(proof),
    );
    return response.statusCode == 200;
  }
}
