import 'package:ucad_parki/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UCAD Parking',
      home: LoginPage(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kvbuqprrzageclfinpzt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2YnVxcHJyemFnZWNsZmlucHp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyMTI1ODMsImV4cCI6MjA5MTc4ODU4M30.h24MJX_ZC0qgP929qxO3jIk6FOAeDlkr1ElJIgwQiCA',
  );

  runApp(MyApp());
}
