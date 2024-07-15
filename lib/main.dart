import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/recommendation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseClient supabaseClient = SupabaseClient(
    'https://mlqtdjmsspmsinudegsl.supabase.co', // Your Supabase URL
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1scXRkam1zc3Btc2ludWRlZ3NsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjA4MDk2NjksImV4cCI6MjAzNjM4NTY2OX0.CP6Cvi8bCdaGduViiX6mMEhY_GbOSWzcxYAZL6n5rQU', // Your Supabase anonymous key
  );
  runApp(MyApp(supabaseClient: supabaseClient));
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabaseClient;

  MyApp({required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myntra Hackathon',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: HomeScreen(supabaseClient: supabaseClient),
    );
  }
}
