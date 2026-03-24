import 'package:flutter/material.dart';
import 'package:ucad_parki/screens/vigilante_home.dart';
import 'package:ucad_parki/widgets/input_ucad.dart';
import 'package:ucad_parki/widgets/boton_ucad.dart';
import 'package:ucad_parki/widgets/label_ucad.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  LOGO
              Center(child: Image.asset('assets/parky.png', height: 220)),

              SizedBox(height: 30),

              //  CORREO
              LabelUcad(texto: "Correo"),
              SizedBox(height: 8),
              InputUcad(hint: "Ingresa tu correo"),

              SizedBox(height: 20),

              //  CONTRASEÑA
              LabelUcad(texto: "Contraseña"),
              SizedBox(height: 8),
              InputUcad(hint: "Ingresa tu contraseña", isPassword: true),

              SizedBox(height: 25),

              //  BOTÓN LOGIN
              BotonUcad(
                texto: "Iniciar sesión",
                color: AppColors.amarillo,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => VigilanteHome()),
                  );
                },
              ),

              SizedBox(height: 15),

              //  OLVIDÓ CONTRASEÑA
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),

              //  REGISTRO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿No tienes cuenta?",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Regístrate",
                      style: TextStyle(
                        color: AppColors.amarillo,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
