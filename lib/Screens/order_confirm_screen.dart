import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'question_screen.dart';
import 'custom_bottom_nav_bar.dart';

class OrderConfirmScreen extends StatelessWidget {
  final SupabaseClient supabaseClient;
  final String mainCategory;
  final String subCategory;

  OrderConfirmScreen({
    required this.supabaseClient,
    required this.mainCategory,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ORDER CONFIRMED', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10),
            Icon(
              Icons.check_circle,
              color: Color(0xFF03A785),
              size: 100,
            ),
            SizedBox(height: 10),
            Text(
              'Order Confirmed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF888888)),
                      SizedBox(width: 10),
                      Text('Arriving By', style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('by 15 Jul - 17 Jul', style: TextStyle(color: Color(0xFF888888)),),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF888888)),
                      SizedBox(width: 10),
                      Text('Packed', style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text('by 13 Jul', style: TextStyle(color: Color(0xFF888888)),),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF03A785),),
                      SizedBox(width: 10),
                      Text('Order placed', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF03A785))),
                      Spacer(),
                      Text('on 10 Jul', style: TextStyle(color: Color(0xFF888888)),),
                    ],
                  ),
                ],
              ),
            ),

            Spacer(),
            //SizedBox(height: 180),
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Share the TrendTuner Feedback',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Shape Trends & Discover What\'s In to earn Myntra Credits!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF333333)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF406C),
                      foregroundColor: Color(0xFFF5F5F5),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionScreen(
                            supabaseClient: supabaseClient,
                            mainCategory: mainCategory,
                            subCategory: subCategory,
                          ),
                        ),
                      );
                    },
                    child: Text('Share Insights'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(supabaseClient: supabaseClient, currentIndex: 1),
    );
  }
}