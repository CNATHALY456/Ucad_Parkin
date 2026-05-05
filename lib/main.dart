import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/screens/login.dart';
import 'package:ucad_parki/screens/actualizar_password.dart'; // Importante importar la nueva pantalla
import 'package:ucad_parki/providers/config_provider.dart'; 
import 'package:ucad_parki/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://gxepethewxyqqqpgvqhb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4ZXBldGhld3h5cXFxcGd2cWhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNzIyNTgsImV4cCI6MjA5MTg0ODI1OH0.5dTq985f0klHI0JcetEskC-_Zr453ylBuONhnwh-sT8',
    // Permite que Supabase maneje los enlaces externos automáticamente
    authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ConfigProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>(); // Llave global para navegar sin contexto directo

  @override
  void initState() {
    super.initState();
    _configurarEscuchaAutenticacion();
  }

  void _configurarEscuchaAutenticacion() {
    // Este listener detecta cuando el usuario viene de un enlace de recuperación (image_200687.png)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        // Redirige a la pantalla de actualización usando la llave global
        _navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const ActualizarPasswordPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigProvider>(context);

    return MaterialApp(
      navigatorKey: _navigatorKey, // Se asigna la llave aquí
      debugShowCheckedModeBanner: false,
      title: 'UCAD Parking',
      locale: config.locale,
      themeMode: config.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.azul,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.azul,
          brightness: Brightness.dark,
        ),
      ),
      // Mantenemos la pantalla de Login como inicio
      home: const LoginPage(), 
    );
  }
}