import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trend-centric recommendation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _userIdController = TextEditingController();
  final _genderController = TextEditingController();
  List<String> _recommendations = [];

  Future<void> _getRecommendations() async {
    final userId = _userIdController.text;
    final gender = _genderController.text;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/recommend'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
        'gender': gender,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _recommendations = List<String>.from(jsonDecode(response.body));
      });
    } else {
      setState(() {
        _recommendations = ['Failed to get recommendations'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendation App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'User ID'),
            ),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getRecommendations,
              child: Text('Get Recommendations'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _recommendations.isNotEmpty
                  ? ListView.builder(
                itemCount: _recommendations.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.circle , color: Colors.pink, size: 15),
                      title: Text(_recommendations[index]),
                    ),
                  );
                },
              )
                  : Center(child: Text('No recommendations yet')),
            ),
          ],
        ),
      ),
    );
  }
}
