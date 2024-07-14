import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

Future<Map<String, List<String>>> loadCategories() async {
  final String response = await rootBundle.loadString('assets/categories.json');
  final data = await json.decode(response);
  Map<String, List<String>> categories = (data['categories'] as Map<String, dynamic>).map((key, value) {
    return MapEntry(key, List<String>.from(value));
  });
  return categories;
}
