import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/widgets/input_ucad.dart';
import 'package:ucad_parki/widgets/boton_ucad.dart';
import 'package:ucad_parki/widgets/label_ucad.dart';

class RecuperarPassword extends StatefulWidget {
  const RecuperarPassword({super.key});

  @override
  _RecuperarPasswordState createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<RecuperarPassword> {
  final correoCtrl = TextEditingController();
  final supabase = Supabase.instance.client;
  bool cargando = false;

  Future<void> enviarRecuperacion() async {
    final correo = correoCtrl.text.trim();

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
      await supabase.auth.resetPasswordForEmail(
        correo,
        redirectTo: 'io.supabase.ucadparki://reset-password/',
      );

      if (mounted) {
        _dialogoEnviado();
      }
    } on AuthException catch (e) {
      mostrar(e.message);
    } catch (e) {
      mostrar("Error de conexión. Inténtalo de nuevo.");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _dialogoEnviado() {
    final isDark = Provider.of<ConfigProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Correo Enviado", 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black
          )
        ),
        content: Text(
          "Revisa tu bandeja de entrada para restablecer tu contraseña.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            }, 
            child: Text(
              "OK", 
              style: TextStyle(
                color: isDark ? AppColors.amarillo : AppColors.azul, 
                fontWeight: FontWeight.bold
              )
            )
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
    // Escuchar el estado del tema
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      // Fondo dinámico
      backgroundColor: isDark ? theme.surface : AppColors.azul,
      appBar: AppBar(
        title: const Text("Recuperar contraseña", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
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
            // El widget InputUcad debe gestionar internamente su color según el tema
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
            Text(
              "Recibirás un enlace para generar una nueva contraseña en tu correo institucional.",
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.white70, 
                fontSize: 14
              ),
            ),
          ],
        ),
      ),
    );
  }
}