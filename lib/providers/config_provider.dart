import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigProvider with ChangeNotifier {
  // Estado del Tema
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Estado del Idioma
  Locale _locale = const Locale('es');
  Locale get locale => _locale;

  ConfigProvider() {
    _cargarPreferencias();
  }

  // Carga los datos guardados al iniciar la app
  Future<void> _cargarPreferencias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      
      String languageCode = prefs.getString('languageCode') ?? 'es';
      _locale = Locale(languageCode);
      
      // Notificamos una sola vez después de cargar todo para evitar lag
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cargar preferencias: $e");
    }
  }

  // Cambiar y guardar el tema con validación de estado
  void toggleTheme(bool value) async {
    // Si el valor es el mismo, no hacemos nada para ahorrar recursos
    if (_isDarkMode == value) return;

    _isDarkMode = value;
    
    // Notificamos primero para que la UI responda instantáneamente
    notifyListeners();
    
    // Guardamos en segundo plano
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Cambiar y guardar el idioma con validación
  void changeLanguage(String code) async {
    if (_locale.languageCode == code) return;

    _locale = Locale(code);
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
  }
}