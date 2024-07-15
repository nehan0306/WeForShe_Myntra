import 'package:flutter/material.dart';
import 'category_selection_screen.dart';
import 'recommendation_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'custom_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  final SupabaseClient supabaseClient;

  HomeScreen({required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Myntra Logo and Menu Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/myntra_logo.png',
                  height: 40,
                  width: 40,
                ),
                Icon(
                  Icons.menu,
                  size: 40,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          // Banner Image
          Image.asset(
            'assets/banner_app.jpg',
            fit: BoxFit.cover,
          ),
          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF406C),
                      foregroundColor: Color(0xFFF5F5F5),
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      textStyle: TextStyle(fontSize: 18, color: Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategorySelectionScreen(supabaseClient: supabaseClient),
                        ),
                      );
                    },
                    child: Text('Start Shopping'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF406C),
                      foregroundColor: Color(0xFFF5F5F5),
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      textStyle: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendationScreen(supabaseClient: supabaseClient),
                        ),
                      );
                    },
                    child: Text('Unlock Trends'),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(supabaseClient: supabaseClient, currentIndex: 1),
    );
  }
}
