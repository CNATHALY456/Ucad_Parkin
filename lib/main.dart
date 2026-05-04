import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/screens/login.dart';
import 'package:ucad_parki/providers/config_provider.dart'; 
import 'package:ucad_parki/utils/app_colors.dart';

void main() async {
  // 1. Asegurar inicialización de widgets
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar Supabase con tus credenciales reales
  await Supabase.initialize(
    url: 'https://gxepethewxyqqqpgvqhb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4ZXBldGhld3h5cXFxcGd2cWhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNzIyNTgsImV4cCI6MjA5MTg0ODI1OH0.5dTq985f0klHI0JcetEskC-_Zr453ylBuONhnwh-sT8',
  );

  // 3. Ejecutar la App envolviéndola en el Provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => ConfigProvider(),
      child: const MyApp(), // Agregado const para rendimiento
    ),
  );
}

class MyApp extends StatelessWidget {
  // Corregido: Se agregó el parámetro 'key' y el constructor const (image_3ca6a1.png)
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios del ConfigProvider (Modo oscuro / Idioma)
    final config = Provider.of<ConfigProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UCAD Parking',
      
      // Configuración de Idioma
      locale: config.locale,
      
      // Configuración de Temas
      themeMode: config.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Tema Claro
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.azul,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.azul,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      
      // Tema Oscuro
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.azul,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.azul,
          brightness: Brightness.dark,
        ),
      ),
      
      // Corregido: Se agregó 'const' para evitar avisos de performance (image_3ca6a1.png)
      home: const LoginPage(), 
    );
  }
}