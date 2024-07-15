import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myntra Recommendation System',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xFF29303E)),
          titleTextStyle: TextStyle(color: Color(0xFF29303E), fontSize: 18),
        ),
      ),
      home: RecommendationPage(),
    );
  }
}

class RecommendationPage extends StatefulWidget {
  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  String selectedGender = 'Male';
  // List<String> recommendations = [];
  // final TextEditingController _userIdController = TextEditingController();
  bool _showRecommendations = false;
  //
  // void getRecommendations() {
  //   setState(() {
  //     recommendations = ['Product 1', 'Product 2']; // Simulate fetching data
  //     _showRecommendations = true;
  //   });
  final _userIdController = TextEditingController();
  final _genderController = TextEditingController();
  List<String> recommendations = [];

  Future<void> _getRecommendations() async {
    final userId = _userIdController.text;
    final gender = selectedGender;

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
        recommendations = List<String>.from(jsonDecode(response.body));
        _showRecommendations = true;
      });
    } else {
      setState(() {
        recommendations = ['Failed to get recommendations'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            SvgPicture.asset('assets/myntra.svg', height: 30),
            SizedBox(width: 10),
            Text('Myntra', style: TextStyle(color: Color(0xFF29303E))),
            Spacer(),
            ...['MEN', 'WOMEN', 'KIDS', 'HOME & LIVING', 'BEAUTY', 'STUDIO', 'RECOMMENDATION']
                .map((text) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(onPressed: () {}, child: Text(text, style: TextStyle(color: Color(0xFF29303E))))))
                .toList(),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for products, brands and more',
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: Icon(Icons.shopping_bag_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue!;
                  });
                },
                items: <String>['Male', 'Female']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getRecommendations,
                child: Text('Get Recommendations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF406C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              SizedBox(height: 20),
              if (_showRecommendations) // Only show if recommendations are fetched
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 4.5,
                    enlargeCenterPage: true,
                    viewportFraction: 0.4,
                  ),
                  items: recommendations.map((item) => Container(
                    child: Center(
                      child: Text(item, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(
                          0xFF313030),)),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // White background with a shadow
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.5),
                          spreadRadius: 4,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )).toList(),
                ),
              if (_showRecommendations)
                ...recommendations.map((product) => ListTile(
                  title: Text(product),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: Text('Order Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE72744),
                      foregroundColor: Colors.white,
                    ),
                  ),
                )).toList(),
              Container(
                color: Colors.blue[100],
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Image.asset("assets/banner.jpg") 
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.grey[200],
                padding: EdgeInsets.all(16),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text("Customer Policies", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Contact Us\nFAQ\nTerms Of Use\nTrack Orders\nShipping\nCancellation\nReturns\nPrivacy policy"),
                SizedBox(height: 20),
                Text("Useful Links", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Blog\nCareers\nSite Map\nCorporate Information\nWhitehat\nCleartrip"),
                SizedBox(height: 20),
                Text("Popular Searches", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Makeup | Dresses For Girls | T-Shirts | Sandals | Headphones | Babydolls | Blazers For Men | Handbags | Ladies Watches | Bags | Sport Shoes | Reebok Shoes | Puma Shoes"),
                ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
