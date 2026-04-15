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
    url: 'https://gxepethewxyqqqpgvqhb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4ZXBldGhld3h5cXFxcGd2cWhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNzIyNTgsImV4cCI6MjA5MTg0ODI1OH0.5dTq985f0klHI0JcetEskC-_Zr453ylBuONhnwh-sT8',
  );

  runApp(MyApp());
}
