import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';

// Importación de las sub-vistas
import 'package:ucad_parki/screens/mi_vehiculo.dart';
import 'package:ucad_parki/screens/mi_parqueo.dart';
import 'package:ucad_parki/screens/historial_page.dart';
import 'package:ucad_parki/screens/perfil_page.dart';

class UsuarioHome extends StatefulWidget {
  const UsuarioHome({super.key});

  @override
  State<UsuarioHome> createState() => _UsuarioHomeState();
}

class _UsuarioHomeState extends State<UsuarioHome> {
  int _index = 1; // Inicia en Parqueo

  final List<Widget> _paginas = [
    const MiVehiculo(),
    const MiParqueo(),
    const HistorialPage(),
    const PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;

    // Definimos el color de fondo base para TODA la app
    // Esto hace que todas las subvistas compartan el mismo lienzo
    final Color backgroundColor = isDark 
        ? const Color(0xFF121212) 
        : const Color(0xFFF8F9FD); // Un blanco azulado muy sutil

    return Scaffold(
      backgroundColor: backgroundColor,
      
      // Extendemos el cuerpo detrás de la barra de navegación para mayor fluidez
      extendBody: true,

      body: IndexedStack(
        index: _index,
        children: _paginas,
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Flotante para estilo moderno
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (value) => setState(() => _index = value),
            
            // Estética
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            selectedItemColor: isDark ? AppColors.amarillo : AppColors.azul,
            unselectedItemColor: Colors.grey.withValues(alpha: 0.5),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 10,
            
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car_filled_rounded), 
                label: "Vehículo"
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_parking_rounded), 
                label: "Parqueo"
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), 
                label: "Historial"
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), 
                label: "Perfil"
              ),
            ],
          ),
        ),
      ),
    );
  }
}