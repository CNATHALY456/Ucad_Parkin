import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado global del Provider
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final isSpanish = config.locale.languageCode == 'es';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSpanish ? "Configuración" : "Settings",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Ajuste de color dinámico para el AppBar
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.azul,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // SECCIÓN DE TEMA
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isDark ? AppColors.amarillo.withOpacity(0.2) : AppColors.azul.withOpacity(0.1),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode, 
                color: isDark ? AppColors.amarillo : AppColors.azul
              ),
            ),
            title: Text(
              isSpanish ? "Modo Oscuro" : "Dark Mode",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              isSpanish 
                ? "Cambiar la apariencia de la app" 
                : "Change app appearance"
            ),
            trailing: Switch(
              value: config.isDarkMode,
              activeColor: AppColors.amarillo,
              onChanged: (value) => config.toggleTheme(value),
            ),
          ),
          
          const Divider(indent: 70),

          // SECCIÓN DE IDIOMA
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isDark ? AppColors.amarillo.withOpacity(0.2) : AppColors.azul.withOpacity(0.1),
              child: Icon(
                Icons.language, 
                color: isDark ? AppColors.amarillo : AppColors.azul
              ),
            ),
            title: Text(
              isSpanish ? "Idioma" : "Language",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(isSpanish ? "Español" : "English"),
            onTap: () => _mostrarSelectorIdioma(context, config),
          ),
          
          const Divider(indent: 70),
        ],
      ),
    );
  }

  void _mostrarSelectorIdioma(BuildContext context, ConfigProvider config) {
    final isDark = config.isDarkMode;
    final isSpanish = config.locale.languageCode == 'es';

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador visual superior del modal
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSpanish ? "Seleccionar Idioma" : "Select Language",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Text("🇪🇸", style: TextStyle(fontSize: 28)),
              title: const Text("Español", style: TextStyle(fontSize: 16)),
              trailing: config.locale.languageCode == 'es' 
                ? Icon(Icons.check_circle, color: isDark ? AppColors.amarillo : AppColors.azul) 
                : null,
              onTap: () {
                config.changeLanguage('es');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text("🇺🇸", style: TextStyle(fontSize: 28)),
              title: const Text("English", style: TextStyle(fontSize: 16)),
              trailing: config.locale.languageCode == 'en' 
                ? Icon(Icons.check_circle, color: isDark ? AppColors.amarillo : AppColors.azul) 
                : null,
              onTap: () {
                config.changeLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}