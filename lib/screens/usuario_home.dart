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

  // Lista de páginas
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
    final theme = Theme.of(context).colorScheme;

    // Condición: ¿Estamos en la vista de Perfil? (Índice 3)
    bool esPerfil = _index == 3;

    return Scaffold(
      // Si es perfil, el fondo lo maneja la página, si no, usamos el azul/negro de la app
      backgroundColor: esPerfil 
          ? (isDark ? theme.surface : Colors.white) 
          : (isDark ? theme.surface : AppColors.azul),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        backgroundColor: theme.surface,
        selectedItemColor: isDark ? AppColors.amarillo : AppColors.azul,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Vehículo"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Parqueo"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Historial"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
      
      body: SafeArea(
        // Mantenemos tu lógica: Perfil sube hasta arriba (top: false)
        top: !esPerfil,
        child: Column(
          children: [
            // LOGO ELIMINADO de todas las páginas
            
            // CONTENEDOR DINÁMICO
            Expanded(
              child: Container(
                width: double.infinity,
                // Si es perfil, EdgeInsets.zero y sin redondeo.
                // Si no, aplicamos el estilo de contenedor redondeado.
                padding: esPerfil ? EdgeInsets.zero : const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
                  borderRadius: esPerfil 
                      ? BorderRadius.zero 
                      : const BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: IndexedStack(
                  index: _index,
                  children: _paginas,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}