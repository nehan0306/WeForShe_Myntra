import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'recommendation_screen.dart';
import 'custom_bottom_nav_bar.dart';

class ResultsScreen extends StatefulWidget {
  final SupabaseClient supabaseClient;
  final String mainCategory;
  final String subCategory;

  ResultsScreen({required this.supabaseClient, required this.mainCategory, required this.subCategory});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Map<String, Map<String, double>> _results = {};

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    try {
      final response = await widget.supabaseClient
          .from('insights')
          .select()
          .eq('gender', widget.mainCategory)
          .eq('product', widget.subCategory);

      if (response != null) {
        Map<String, Map<String, double>> results = {};
        for (var record in response) {
          String question = record['question'];
          List<String> selectedOptions = List<String>.from(record['selectedOptions']);
          if (!results.containsKey(question)) {
            results[question] = {};
          }
          for (String option in selectedOptions) {
            if (!results[question]!.containsKey(option)) {
              results[question]![option] = 0;
            }
            results[question]![option] = results[question]![option]! + 1;
          }
        }

        // Calculate percentages
        results.forEach((question, options) {
          double totalVotes = options.values.reduce((a, b) => a + b);
          options.updateAll((key, value) => (value / totalVotes) * 100);
        });

        setState(() {
          _results = results;
        });

        // Save results to new table
        await _saveResultsToNewTable();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load results. Please try again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  Future<void> _saveResultsToNewTable() async {
    List<Map<String, dynamic>> dataToInsert = [];
    _results.forEach((question, options) {
      options.forEach((option, percentage) {
        dataToInsert.add({
          'question': question,
          'option': option,
          'percentage': percentage,
          'gender': widget.mainCategory,
          'product': widget.subCategory,
          'created_at': DateTime.now().toIso8601String(), // Add created_at timestamp
        });
      });
    });

    try {
      for (var data in dataToInsert) {
        // Insert the new record
        final insertResponse = await widget.supabaseClient
            .from('results')
            .insert(data)
            .select();

        if (insertResponse == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to insert results. Please try again.')),
          );
          continue;
        }

        // Delete previous records with the same combination except for percentage
        await widget.supabaseClient
            .from('results')
            .delete()
            .eq('question', data['question'])
            .eq('option', data['option'])
            .eq('gender', data['gender'])
            .eq('product', data['product'])
            .neq('percentage', data['percentage']);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insights for ${widget.mainCategory} - ${widget.subCategory}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _results.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final question = _results.keys.elementAt(index);
                  final options = _results[question]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      ...options.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    value: entry.key,
                                    groupValue: null,
                                    onChanged: null,
                                    activeColor: Color(0xFFFF406C),
                                  ),
                                  Text(
                                    entry.key,
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ],
                              ),
                              Stack(
                                children: [
                                  Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  Container(
                                    height: 10,
                                    width: MediaQuery.of(context).size.width * (entry.value / 100),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFF406C),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${entry.value.toStringAsFixed(2)}%',
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF406C),
                foregroundColor: Color(0xFFF5F5F5),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecommendationScreen(supabaseClient: widget.supabaseClient),
                  ),
                );
              },
              child: Text('Unlock Trends'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(supabaseClient: widget.supabaseClient, currentIndex: 1),
    );
  }
}
