import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class ConfiguracionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(config.locale.languageCode == 'es' ? "Configuración" : "Settings"),
        backgroundColor: AppColors.azul,
      ),
      body: ListView(
        children: [
          // SWITCH MODO OSCURO
          ListTile(
            leading: Icon(Icons.dark_mode, color: AppColors.azul),
            title: Text("Modo Oscuro"),
            trailing: Switch(
              value: config.isDarkMode,
              onChanged: (value) => config.toggleTheme(value),
            ),
          ),
          Divider(),
          // SELECCIÓN DE IDIOMA
          ListTile(
            leading: Icon(Icons.language, color: AppColors.azul),
            title: Text("Idioma"),
            subtitle: Text(config.locale.languageCode == 'es' ? "Español" : "English"),
            onTap: () {
              _mostrarSelectorIdioma(context, config);
            },
          ),
        ],
      ),
    );
  }

  void _mostrarSelectorIdioma(BuildContext context, ConfigProvider config) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Español"),
            onTap: () {
              config.changeLanguage('es');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("English"),
            onTap: () {
              config.changeLanguage('en');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}