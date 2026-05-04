import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Locale _locale = const Locale('es');

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;

  ConfigProvider() {
    _cargarPreferencias();
  }

  void toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners(); // Esto actualiza toda la app al instante
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  void changeLanguage(String langCode) async {
    _locale = Locale(langCode);
    notifyListeners(); // Esto traduce toda la app al instante
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', langCode);
  }

  void _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _locale = Locale(prefs.getString('language') ?? 'es');
    notifyListeners();
  }
}