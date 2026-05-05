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
  bool cargando = false;

  Future<void> enviarRecuperacion() async {
    final correo = correoCtrl.text.trim();

    // Validación local antes de llamar a Supabase
    if (correo.isEmpty) {
      mostrar("Por favor, ingresa tu correo");
      return;
    }

    if (!correo.endsWith("@ucad.edu.sv")) {
      mostrar("El correo debe ser institucional (@ucad.edu.sv)");
      return;
    }

    setState(() => cargando = true);

    try {
      // Interacción con Supabase Auth
      // redirectTo debe coincidir con la configuración en tu Dashboard (image_200687.png)
      await supabase.auth.resetPasswordForEmail(
        correo,
        redirectTo: 'io.supabase.ucadparki://reset-password/',
      );

      // Si llegamos aquí, el envío fue exitoso
      if (mounted) {
        _dialogoEnviado();
      }
    } on AuthException catch (e) {
      // Captura errores específicos de autenticación de Supabase
      mostrar(e.message);
    } catch (e) {
      // Captura errores de red o inesperados
      mostrar("Error de conexión. Inténtalo de nuevo.");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _dialogoEnviado() {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga al usuario a interactuar con el botón
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Correo Enviado", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Revisa tu bandeja de entrada para restablecer tu contraseña."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              Navigator.pop(context); // Regresa al Login
            }, 
            child: const Text("OK", style: TextStyle(color: AppColors.azul, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void mostrar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  void dispose() {
    correoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(
        title: const Text("Recuperar contraseña", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.azul,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LabelUcad(texto: "Correo institucional"),
            const SizedBox(height: 10),
            InputUcad(hint: "correo@ucad.edu.sv", controller: correoCtrl),
            const SizedBox(height: 25),
            
            cargando 
              ? const Center(child: CircularProgressIndicator(color: AppColors.amarillo))
              : BotonUcad(
                  texto: "ENVIAR ENLACE",
                  color: AppColors.amarillo,
                  onPressed: enviarRecuperacion,
                ),

            const SizedBox(height: 20),
            const Text(
              "Recibirás un enlace para generar una nueva contraseña en tu correo institucional.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}