import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home_screen.dart';
import '../screens/recommendation_screen.dart';
import '../screens/category_selection_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final SupabaseClient supabaseClient;
  final int currentIndex;

  CustomBottomNavBar({required this.supabaseClient, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Prevent reloading the same screen

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RecommendationScreen(supabaseClient: supabaseClient)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(supabaseClient: supabaseClient)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CategorySelectionScreen(supabaseClient: supabaseClient)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Color(0xFFFF406C),
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: currentIndex == 0 ? Color(0x33FF406C) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.trending_up_rounded),
          ),
          label: 'Recommendations',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: currentIndex == 1 ? Color(0x33FF406C) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.home),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: currentIndex == 2 ? Color(0x33FF406C) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.category),
          ),
          label: 'Products',
        ),
      ],
    );
  }
}
