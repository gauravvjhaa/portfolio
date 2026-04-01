import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'portfolio_app.dart';

// Declare globals to be initialized later
late final SupabaseClient supabase;
late final String storageUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the environment variables
  await dotenv.load(fileName: ".env");

  // Assign the variables
  storageUrl = dotenv.env['SUPABASE_STORAGE_URL']!;

  // Initialize Supabase using the loaded variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize your global client
  supabase = Supabase.instance.client;

  setPathUrlStrategy();
  runApp(const PortfolioApp());
}
