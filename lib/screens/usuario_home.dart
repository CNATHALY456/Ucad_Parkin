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

  final List<Widget> paginas = [
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

    return Scaffold(
      backgroundColor: isDark ? theme.surface : AppColors.azul,

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
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Vehículo",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Parqueo"),

          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historial",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // LOGO
            Center(
              child: Image.asset(
                isDark ? 'assets/parky2.jpeg' : 'assets/parky.png',
                height: 170,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
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
