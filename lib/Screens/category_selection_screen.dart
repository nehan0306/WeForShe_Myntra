import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/category_loader.dart';
import 'question_screen.dart';
import 'recommendation_screen.dart';
import 'order_confirm_screen.dart';
import 'custom_bottom_nav_bar.dart';

class CategorySelectionScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;

  CategorySelectionScreen({required this.supabaseClient});

  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  String? _selectedMainCategory;
  String? _selectedSubCategory;
  Map<String, List<String>> _categories = {};
  List<String> _subCategories = [];

  @override
  void initState() {
    super.initState();
    loadCategories().then((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Who are you shopping for?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Color(0xFF333333), width: 5),
                        ),
                      ),
                      hint: Text("Choose the gender"),
                      value: _selectedMainCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMainCategory = newValue;
                          _subCategories = _categories[_selectedMainCategory] ?? [];
                          _selectedSubCategory = null; // Reset subcategory selection
                        });
                      },
                      items: _categories.keys.map((String mainCategory) {
                        return DropdownMenuItem<String>(
                          value: mainCategory,
                          child: Text(mainCategory),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'What type of product are you looking for?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Color(0xFF333333), width: 5),
                        ),
                      ),
                      hint: Text("Choose the category"),
                      value: _selectedSubCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSubCategory = newValue;
                        });
                      },
                      items: _subCategories.map((String subCategory) {
                        return DropdownMenuItem<String>(
                          value: subCategory,
                          child: Text(subCategory),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF406C),
                        foregroundColor: Color(0xFFF5F5F5),
                        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        textStyle: TextStyle(fontSize: 18, color: Color(0xFFF5F5F5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      onPressed: () {
                        if (_selectedMainCategory != null && _selectedSubCategory != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderConfirmScreen(
                                supabaseClient: widget.supabaseClient,
                                mainCategory: _selectedMainCategory!,
                                subCategory: _selectedSubCategory!,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a main category and subcategory')),
                          );
                        }
                      },
                      child: Text('Order Now'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecommendationScreen(supabaseClient: widget.supabaseClient),
                          ),
                        );
                      },
                      child: Text(
                        'See Recommendations',
                        style: TextStyle(fontSize: 18, color: Color(0xFFFF406C)),
                      ),
                    ),
                    SizedBox(height: 20), // Add some space before the banner
                    Image.asset(
                      'assets/banner_app.jpg',
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(supabaseClient: widget.supabaseClient, currentIndex: 2),
    );
  }
}
