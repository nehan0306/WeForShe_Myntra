import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/question.dart';

Future<Map<String, Map<String, List<Question>>>> loadQuestions() async {
  final String response = await rootBundle.loadString('assets/questions.json');
  final data = await json.decode(response);

  return (data as Map<String, dynamic>).map((mainCategory, subCategories) {
    return MapEntry(
      mainCategory,
      (subCategories as Map<String, dynamic>).map((subCategory, questions) {
        return MapEntry(
          subCategory,
          (questions as List<dynamic>).map((question) {
            return Question.fromJson(question);
          }).toList(),
        );
      }),
    );
  });
}
