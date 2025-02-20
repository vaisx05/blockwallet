import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Username Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UsernameSearchPage(),
    );
  }
}

class UsernameSearchPage extends StatefulWidget {
  @override
  _UsernameSearchPageState createState() => _UsernameSearchPageState();
}

class _UsernameSearchPageState extends State<UsernameSearchPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  List<String> _suggestions = [];

  Future<void> _fetchUsernames(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final url = Uri.parse('http://172.17.17.210:3000/searchUsers?query=$query');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _suggestions = data.map((e) => e.toString()).toList();
        });
      }
    } catch (error) {
      print("Error fetching usernames: $error");
    }
  }

  Future<void> _fetchUserAddress(String username) async {
    final url = Uri.parse('http://172.17.17.210:3000/getAddress/$username');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _addressController.text = data['address'] ?? "No address found";
        });
      } else {
        setState(() {
          _addressController.text = "No address found";
        });
      }
    } catch (error) {
      print("Error fetching address: $error");
      setState(() {
        _addressController.text = "Error fetching address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Username")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Username Search Field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Search Username",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _fetchUsernames,
            ),
            SizedBox(height: 10),

            // Suggestions List
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () {
                      if (_suggestions.isNotEmpty &&
                          index < _suggestions.length) {
                        String selectedUsername = _suggestions[index];

                        _usernameController.text = selectedUsername;
                        _fetchUserAddress(
                            selectedUsername); // Fetch address first

                        setState(() {
                          _suggestions = []; // Then clear suggestions
                        });
                      }
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 10),

            // Ethereum Address Field
            TextField(
              controller: _addressController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Ethereum Address",
                prefixIcon: Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
