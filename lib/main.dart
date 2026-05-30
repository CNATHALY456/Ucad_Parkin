import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/screens/login.dart';
import 'package:ucad_parki/screens/actualizar_password.dart';
import 'package:ucad_parki/screens/usuario_home.dart'; // Asegúrate de tener esta ruta
import 'package:ucad_parki/providers/config_provider.dart'; 
import 'package:ucad_parki/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gxepethewxyqqqpgvqhb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4ZXBldGhld3h5cXFxcGd2cWhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNzIyNTgsImV4cCI6MjA5MTg0ODI1OH0.5dTq985f0klHI0JcetEskC-_Zr453ylBuONhnwh-sT8',
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
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _configurarEscuchaAutenticacion();
  }

  void _configurarEscuchaAutenticacion() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        // Redirigir a la pantalla de actualización de contraseña
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/actualizar_pass', 
          (route) => false
        );
      } else if (event == AuthChangeEvent.signedOut) {
        // Si cierra sesión, regresar al login
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login', 
          (route) => false
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigProvider>(context);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'UCAD Parking',
      locale: config.locale,
      
      // 🚀 RUTAS DEFINIDAS PARA LA NAVEGACIÓN
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const UsuarioHome(),
        '/actualizar_pass': (context) => const ActualizarPasswordPage(),
      },
      
      themeMode: config.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppColors.azul,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.azul,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.azul,
          onPrimary: Colors.white,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
          background: Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const LoginPage(), 
    );
  }
}