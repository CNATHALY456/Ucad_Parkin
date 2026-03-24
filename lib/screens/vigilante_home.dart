import 'package:flutter/material.dart';
import 'package:ucad_parki/screens/registro_entrada.dart';
import 'package:ucad_parki/screens/registro_salida.dart';
import 'package:ucad_parki/screens/buscar_placa.dart';
import 'package:ucad_parki/screens/perfil_page.dart';
import 'package:ucad_parki/widgets/boton_home.dart';

class VigilanteHome extends StatefulWidget {
  @override
  _VigilanteHomeState createState() => _VigilanteHomeState();
}

class _VigilanteHomeState extends State<VigilanteHome> {
  final Color azul = Color(0xFF0D2784);
  final Color amarillo = Color(0xFFEBB012);

  int _index = 1;

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BuscarPlaca()),
      );
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PerfilPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azul,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: azul,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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

            // 🔝 LOGO
            Center(child: Image.asset('assets/parky.png', height: 180)),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👋 BIENVENIDO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Bienvenido",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: azul,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: amarillo,
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 🔘 BOTONES PRO
                    BotonHome(
                      titulo: "REGISTRAR ENTRADA",
                      subtitulo: "Automóvil, motos, bicicletas",
                      icono: Icons.login,
                      azul: azul,
                      amarillo: amarillo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistroEntrada(),
                          ),
                        );
                      },
                    ),

                    BotonHome(
                      titulo: "REGISTRAR SALIDA",
                      subtitulo: "Automóvil, motos, bicicletas",
                      icono: Icons.logout,
                      azul: azul,
                      amarillo: amarillo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistroSalida(),
                          ),
                        );
                      },
                    ),

                    BotonHome(
                      titulo: "CONTACTAR",
                      subtitulo: "Paso obstaculizado",
                      icono: Icons.phone,
                      azul: azul,
                      amarillo: amarillo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuscarPlaca(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
