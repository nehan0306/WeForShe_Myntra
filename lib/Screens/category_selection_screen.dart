import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/category_loader.dart';
import 'question_screen.dart';

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
      appBar: AppBar(
        title: Text('Select Category'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              hint: Text("Select main category"),
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
            if (_subCategories.isNotEmpty)
              DropdownButton<String>(
                hint: Text("Select subcategory"),
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
            ElevatedButton(
              onPressed: () {
                if (_selectedMainCategory != null && _selectedSubCategory != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionScreen(
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
              child: Text('Order'),
            ),
          ],
        ),
      ),
    );
  }
}
