import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/widgets/input_ucad.dart';
import 'package:ucad_parki/widgets/boton_ucad.dart';

class ActualizarPasswordPage extends StatefulWidget {
  const ActualizarPasswordPage({super.key});

  @override
  State<ActualizarPasswordPage> createState() => _ActualizarPasswordPageState();
}

class _ActualizarPasswordPageState extends State<ActualizarPasswordPage> {
  final passCtrl = TextEditingController();
  final supabase = Supabase.instance.client;
  bool cargando = false;

  Future<void> _actualizar() async {
    // Validación de longitud mínima para mayor seguridad
    if (passCtrl.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña debe tener al menos 6 caracteres"))
      );
      return;
    }

    setState(() => cargando = true);
    
    try {
      // Actualización de la contraseña en la sesión activa de Supabase
      await supabase.auth.updateUser(
        UserAttributes(password: passCtrl.text.trim()),
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña actualizada correctamente ✅"), backgroundColor: Colors.green)
      );

      // Redirige al Login y limpia el historial de navegación para seguridad
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red)
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error inesperado al actualizar"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Nueva Contraseña", 
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            const Text(
              "Por favor, ingresa tu nueva clave de acceso.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // CORRECCIÓN: Se cambió 'isPass' por 'isPassword' según image_1ffb22.png
            InputUcad(
              hint: "Escribe tu nueva clave", 
              controller: passCtrl, 
              isPassword: true
            ),

            const SizedBox(height: 30),

            cargando 
              ? const CircularProgressIndicator(color: AppColors.amarillo)
              : BotonUcad(
                  texto: "ACTUALIZAR CONTRASEÑA", 
                  color: AppColors.amarillo, 
                  onPressed: _actualizar
                ),
          ],
        ),
      ),
    );
  }
}