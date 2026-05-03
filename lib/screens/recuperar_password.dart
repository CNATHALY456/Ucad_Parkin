import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/widgets/input_ucad.dart';
import 'package:ucad_parki/widgets/boton_ucad.dart';
import 'package:ucad_parki/widgets/label_ucad.dart';

class RecuperarPassword extends StatefulWidget {
  @override
  _RecuperarPasswordState createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<RecuperarPassword> {
  final correoCtrl = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> enviarRecuperacion() async {
    final correo = correoCtrl.text.trim();

    if (!correo.endsWith("@ucad.edu.sv")) {
      mostrar("Correo debe ser institucional");
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(
        correo,
        redirectTo: 'com.ucad.parki://reset-password',
      );

      mostrar("Revisa tu correo 📩");
    } catch (e) {
      mostrar("Error al enviar correo");
    }
  }

  void mostrar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(
        title: Text("Recuperar contraseña"),
        backgroundColor: AppColors.azul,
      ),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelUcad(texto: "Correo institucional"),
            SizedBox(height: 10),

            InputUcad(hint: "correo@ucad.edu.sv", controller: correoCtrl),

            SizedBox(height: 25),

            BotonUcad(
              texto: "Enviar enlace",
              color: AppColors.amarillo,
              onPressed: enviarRecuperacion,
            ),

            SizedBox(height: 20),

            Text(
              "Te enviaremos un enlace para restablecer tu contraseña.",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
