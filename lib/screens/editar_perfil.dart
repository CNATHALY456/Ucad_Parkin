import 'package:flutter/material.dart';
import 'package:ucad_parki/widgets/input_field.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class EditarPerfil extends StatefulWidget {
  @override
  _EditarPerfilState createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  int avatarSeleccionado = 0;
  bool mostrarAvatares = false;
  bool cambiarPassword = false;

  List<String> avatars = [
    "assets/avatar1.png",
    "assets/avatar2.png",
    "assets/avatar3.png",
    "assets/avatar4.png",
  ];

  final nombre = TextEditingController();
  final apellido = TextEditingController();
  final correo = TextEditingController();
  final password = TextEditingController();
  final confirmarPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            //  VOLVER
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 10),

            //  AVATAR
            Stack(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(avatars[avatarSeleccionado]),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        mostrarAvatares = !mostrarAvatares;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.amarillo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            //  AVATARES
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: mostrarAvatares ? 80 : 0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        avatarSeleccionado = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: avatarSeleccionado == index
                              ? AppColors.amarillo
                              : Colors.transparent,
                          width: 3,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(avatars[index]),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            //  FORMULARIO
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InputField(
                        label: "Nombre",
                        icono: Icons.person,
                        controller: nombre,
                      ),

                      InputField(
                        label: "Apellidos",
                        icono: Icons.badge,
                        controller: apellido,
                      ),

                      InputField(
                        label: "Correo",
                        icono: Icons.email,
                        controller: correo,
                      ),

                      const SizedBox(height: 10),

                      //  SWITCH
                      SwitchListTile(
                        value: cambiarPassword,
                        activeColor: AppColors.amarillo,
                        title: const Text("Cambiar contraseña"),
                        onChanged: (value) {
                          setState(() {
                            cambiarPassword = value;
                          });
                        },
                      ),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: cambiarPassword ? 160 : 0,
                        child: Column(
                          children: [
                            InputField(
                              label: "Nueva contraseña",
                              icono: Icons.lock,
                              controller: password,
                              esPassword: true,
                            ),
                            InputField(
                              label: "Confirmar contraseña",
                              icono: Icons.lock_outline,
                              controller: confirmarPassword,
                              esPassword: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amarillo,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            print("Guardado");
                          },
                          child: Text(
                            "Guardar Cambios",
                            style: TextStyle(
                              color: AppColors.azul,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
}
