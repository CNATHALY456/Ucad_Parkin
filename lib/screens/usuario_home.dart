import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';

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
  int _index = 1;

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

    final Color topHeaderColor = isDark ? const Color(0xFF121212) : AppColors.azul;
    final Color bodyContainerColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
    final Color navigationBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Lógica para pantalla completa en Perfil
    final bool esPerfil = _index == 3;

    return Scaffold(
      backgroundColor: topHeaderColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 1. CAPA INFERIOR: Logo (Solo se muestra si NO estamos en Perfil)
            if (!esPerfil)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: Image.asset(
                    isDark ? 'assets/parky2.jpeg' : 'assets/parky.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.directions_car, size: 80, color: Colors.white
                    ),
                  ),
                ),
              ),

            // 2. CAPA SUPERIOR: Contenedor de sub-vistas
            Positioned(
              top: esPerfil ? 0 : 180, // Si es perfil, sube hasta arriba
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: bodyContainerColor,
                  // Curva solo si NO es perfil
                  borderRadius: esPerfil 
                      ? BorderRadius.zero 
                      : const BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: ClipRRect(
                  borderRadius: esPerfil 
                      ? BorderRadius.zero 
                      : const BorderRadius.vertical(top: Radius.circular(40)),
                  child: IndexedStack(
                    index: _index,
                    children: _paginas,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (value) => setState(() => _index = value),
            backgroundColor: navigationBarColor,
            selectedItemColor: isDark ? AppColors.amarillo : AppColors.azul,
            unselectedItemColor: Colors.grey.withOpacity(0.5),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 10,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.directions_car_filled_rounded), label: "Vehículo"),
              BottomNavigationBarItem(icon: Icon(Icons.local_parking_rounded), label: "Parqueo"),
              BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "Historial"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Perfil"),
            ],
          ),
        ),
      ),
    );
  }
}