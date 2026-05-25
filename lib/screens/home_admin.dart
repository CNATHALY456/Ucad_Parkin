import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';

import 'dashboard_admin.dart';
import 'usuarios_admin.dart';
import 'vehiculos_admin.dart';
import 'tickets_admin.dart';
import 'perfil_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;

  final List<Widget> paginas = [
    const DashboardAdmin(),
    const UsuariosAdmin(),
    const VehiculosAdmin(),
    const TicketsAdmin(),
    const PerfilPage(), // Tu página de perfil integrada
  ];

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final theme = Theme.of(context).colorScheme;

    // Evaluamos si el usuario está parado en la pestaña de Perfil (Índice 4)
    final bool esPerfil = _index == 4;

    return Scaffold(
      // Si está en perfil, dejamos que la página maneje su fondo azul completo sin cortes
      backgroundColor: esPerfil 
          ? (isDark ? theme.surface : AppColors.azul)
          : (isDark ? theme.surface : AppColors.azul),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        backgroundColor: theme.surface,
        selectedItemColor: AppColors.amarillo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Usuarios"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Vehículos"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
      body: SafeArea(
        // Si es perfil, removemos los márgenes y el logo superior para evitar la duplicación visual
        child: Column(
          children: [
            if (!esPerfil) ...[
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  isDark ? 'assets/parky2.jpeg' : 'assets/parky.png',
                  height: 160,
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            Expanded(
              child: Container(
                width: double.infinity,
                // Si es perfil, eliminamos el padding y el contenedor blanco para que se fusione
                padding: esPerfil ? EdgeInsets.zero : const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: esPerfil ? Colors.transparent : theme.surface,
                  borderRadius: esPerfil 
                      ? BorderRadius.zero 
                      : const BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: paginas[_index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}