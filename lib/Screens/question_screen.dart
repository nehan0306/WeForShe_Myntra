import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';
import '../utils/question_loader.dart';
import 'results_screen.dart';
import 'order_confirm_screen.dart';
import 'custom_bottom_nav_bar.dart';

class QuestionScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;
  final String mainCategory; // Gender
  final String subCategory; // Product

  QuestionScreen({required this.supabaseClient, required this.mainCategory, required this.subCategory});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    loadQuestions().then((questions) {
      setState(() {
        _questions = questions[widget.mainCategory]?[widget.subCategory] ?? [];
      });
    });
  }

  void _toggleOption(Question question, String option) {
    setState(() {
      if (question.selectedOptions.contains(option)) {
        question.selectedOptions.remove(option);
      } else {
        question.selectedOptions.add(option);
      }
    });
  }

  bool _validateSelection() {
    for (var question in _questions) {
      if (question.selectedOptions.isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<void> _saveDataAndNavigate() async {
    if (_validateSelection()) {
      // Prepare data for saving
      var data = _questions.map((q) {
        return {
          'question': q.question,
          'selectedOptions': q.selectedOptions,
          'gender': widget.mainCategory, // Add gender
          'product': widget.subCategory // Add product
        };
      }).toList();

      // Save data to Supabase
      try {
        final response = await widget.supabaseClient
            .from('insights')
            .insert(data)
            .select();

        if (response != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                supabaseClient: widget.supabaseClient,
                mainCategory: widget.mainCategory,
                subCategory: widget.subCategory,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save data. Please try again.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one option for each question')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TrendTune Feedback of ${widget.mainCategory} - ${widget.subCategory}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final question = _questions[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                ...question.options.map((option) {
                  return Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF888888)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                  child:  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Color(0xFFFF406C),
                    title: Text(option),
                    value: question.selectedOptions.contains(option),
                    onChanged: (bool? value) {
                      _toggleOption(question, option);
                    },
                  ));
                }).toList(),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF406C),
          foregroundColor: Color(0xFFF5F5F5),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          textStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
        onPressed: _saveDataAndNavigate,
        child: Text('Discover Insights'),
      ),
      bottomNavigationBar: CustomBottomNavBar(supabaseClient: widget.supabaseClient, currentIndex: 1),
    );
  }
}
