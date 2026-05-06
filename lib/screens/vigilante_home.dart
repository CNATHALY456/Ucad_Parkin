import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/screens/registro_entrada.dart';
import 'package:ucad_parki/screens/registro_salida.dart';
import 'package:ucad_parki/screens/buscar_placa.dart';
import 'package:ucad_parki/screens/perfil_page.dart'; 
import 'package:ucad_parki/widgets/boton_home.dart';

class VigilanteHome extends StatefulWidget {
  const VigilanteHome({super.key});

  @override
  _VigilanteHomeState createState() => _VigilanteHomeState();
}

class _VigilanteHomeState extends State<VigilanteHome> {
  int _index = 1;

  void _onItemTapped(int index) {
    if (index == _index) return;

    setState(() => _index = index);
    
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BuscarPlaca()));
    }
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilPage())).then((_) {
        setState(() => _index = 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? theme.surface : AppColors.azul,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onItemTapped,
        backgroundColor: theme.surface,
        selectedItemColor: isDark ? AppColors.amarillo : AppColors.azul,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                // LÓGICA DE IMAGEN ADAPTATIVA:
                // Si es modo oscuro, usamos la versión de image_694211.jpg
                // Si es modo claro, se mantiene la versión original
                isDark ? 'assets/parky2.jpeg' : 'assets/parky.png', 
                height: 180, 
                cacheHeight: 400,
              )
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            config.locale.languageCode == 'es' ? "Bienvenido" : "Welcome",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: theme.onSurface,
                            ),
                          ),
                          const CircleAvatar(
                            backgroundColor: AppColors.amarillo,
                            child: Icon(Icons.check, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      _buildBoton(context, "REGISTRAR ENTRADA", Icons.login, () => const RegistrarEntrada(), theme),
                      const SizedBox(height: 15),
                      _buildBoton(context, "REGISTRAR SALIDA", Icons.logout, () => const RegistroSalida(), theme),
                      const SizedBox(height: 15),
                      _buildBoton(context, "CONTACTAR", Icons.phone, () => const BuscarPlaca(), theme),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoton(BuildContext context, String titulo, IconData icono, Widget Function() screen, ColorScheme theme) {
    final isDark = Provider.of<ConfigProvider>(context, listen: false).isDarkMode;

    return BotonHome(
      titulo: titulo,
      subtitulo: "Gestión de vehículos",
      icono: icono,
      // Se mantiene la corrección para que el botón no desentone con image_6a1c8b.jpg
      azul: isDark ? const Color(0xFF2A2A2A) : AppColors.azul, 
      amarillo: AppColors.amarillo,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen())),
    );
  }
}