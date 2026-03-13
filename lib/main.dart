import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'portfolio_app.dart';

// Global Supabase instance available throughout the app
final supabase = Supabase.instance.client;
const String storageUrl =
    'https://dudwzfefssvxzckffvkx.supabase.co/storage/v1/object/public/portfolio-assets';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dudwzfefssvxzckffvkx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1ZHd6ZmVmc3N2eHpja2Zmdmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg1MzA3NzAsImV4cCI6MjA2NDEwNjc3MH0.27Uxc_yppQrDb-TEueQLDl2oOtSn81IjjzFk50rEljQ',
  );
  setPathUrlStrategy();
  runApp(const PortfolioApp());
}
