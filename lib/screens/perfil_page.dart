import 'package:flutter/material.dart';
import 'package:ucad_parki/screens/vigilante_home.dart';
import 'package:ucad_parki/screens/editar_perfil.dart';
import 'package:ucad_parki/screens/login.dart';
import 'package:ucad_parki/screens/configuracion_page.dart';
import 'package:ucad_parki/screens/notificaciones_page.dart';
import 'package:ucad_parki/widgets/item_perfil.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/models/usuario.dart';

class PerfilPage extends StatelessWidget {
  //  USUARIO (SIMULADO)
  final Usuario usuario = Usuario(
    nombre: "Juan",
    apellido: "Pérez",
    correo: "juan@gmail.com",
    avatar: "assets/avatar1.png",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),

            //  BOTÓN ATRÁS
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => VigilanteHome()),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            //  FOTO + NOMBRE
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 75,
                    backgroundImage: AssetImage(usuario.avatar),
                  ),
                ),

                SizedBox(height: 15),

                Text(
                  "${usuario.nombre} ${usuario.apellido}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            //  TARJETA
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: Column(
                  children: [
                    //  MI PERFIL
                    ItemPerfil(
                      texto: "Mi perfil",
                      icono: Icons.person,
                      color: AppColors.azul,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditarPerfil(),
                          ),
                        );
                      },
                    ),

                    //  CONFIGURACIÓN
                    ItemPerfil(
                      texto: "Configuración",
                      icono: Icons.settings,
                      color: AppColors.azul,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfiguracionPage(),
                          ),
                        );
                      },
                    ),

                    //  NOTIFICACIONES
                    ItemPerfil(
                      texto: "Notificaciones",
                      icono: Icons.notifications,
                      color: AppColors.azul,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificacionesPage(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 10),
                    Divider(),

                    //  CERRAR SESIÓN
                    ItemPerfil(
                      texto: "Cerrar sesión",
                      icono: Icons.logout,
                      color: Colors.red,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
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
