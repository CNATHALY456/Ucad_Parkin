import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/providers/config_provider.dart';
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
    final config = Provider.of<ConfigProvider>(context, listen: false);
    final isSpanish = config.locale.languageCode == 'es';

    if (passCtrl.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpanish 
            ? "La contraseña debe tener al menos 6 caracteres" 
            : "Password must be at least 6 characters"),
        )
      );
      return;
    }

    setState(() => cargando = true);
    
    try {
      // 1. Intentar actualizar la contraseña
      await supabase.auth.updateUser(
        UserAttributes(password: passCtrl.text.trim()),
      );
      
      // 2. Cerrar sesión explícitamente para forzar re-login con la nueva clave
      await supabase.auth.signOut();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpanish 
            ? "Contraseña actualizada. Inicia sesión de nuevo." 
            : "Password updated. Please log in again."), 
          backgroundColor: Colors.green
        )
      );

      // 3. Redirigir al login y limpiar todo el stack de navegación
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red)
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpanish ? "Error inesperado" : "Unexpected error"), 
          backgroundColor: Colors.red
        )
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
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final isSpanish = config.locale.languageCode == 'es';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.azul,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_reset_rounded,
                size: 80,
                color: isDark ? AppColors.amarillo : Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                isSpanish ? "Nueva Contraseña" : "New Password", 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 26, 
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 10),
              Text(
                isSpanish 
                  ? "Por favor, ingresa tu nueva clave de acceso."
                  : "Please enter your new access key.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 40),

              InputUcad(
                hint: isSpanish ? "Escribe tu nueva clave" : "Type your new password", 
                controller: passCtrl, 
                isPassword: true,
              ),

              const SizedBox(height: 30),

              cargando 
                ? const CircularProgressIndicator(color: AppColors.amarillo)
                : BotonUcad(
                    texto: isSpanish ? "ACTUALIZAR" : "UPDATE PASSWORD", 
                    color: AppColors.amarillo, 
                    onPressed: _actualizar
                  ),
            ],
          ),
        ),
      ),
    );
  }
}