import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecommendationScreen extends StatelessWidget {
  final SupabaseClient supabaseClient;

  RecommendationScreen({required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendations'),
      ),
      body: Center(
        child: Text('Recommendation Screen'),
      ),
    );
  }
}
