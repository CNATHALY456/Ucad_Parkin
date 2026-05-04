import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/screens/vigilante_home.dart';
import 'package:ucad_parki/widgets/input_ucad.dart';
import 'package:ucad_parki/widgets/boton_ucad.dart';
import 'package:ucad_parki/widgets/label_ucad.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/screens/registro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool cargando = false;

  Future<void> iniciarSesion() async {
    // Validación básica de campos vacíos
    if (correoCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      mostrarMensaje("Por favor, ingresa tus credenciales");
      return;
    }

    setState(() => cargando = true);

    try {
      // 1. Autenticación con Supabase Auth
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: correoCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (res.user != null) {
        // 2. Búsqueda del perfil en la tabla 'usuarios' vinculando por el UUID de Auth
        final data = await supabase
            .from('usuarios')
            .select('tipo_usuario, nombres, estado')
            .eq('id_usuario', res.user!.id)
            .maybeSingle();

        // Si el usuario existe en Auth pero no en la tabla pública 'usuarios'
        if (data == null) {
          await supabase.auth.signOut();
          mostrarMensaje("Perfil no encontrado en la base de datos.");
          return;
        }

        // Validación de estado de cuenta
        if (data['estado'] != 'activo') {
          await supabase.auth.signOut();
          mostrarMensaje("Tu cuenta está inactiva.");
          return;
        }

        if (!mounted) return;

        // 3. Redirección basada en el rol (tipo_usuario)
        String rol = data['tipo_usuario'];
        
        if (rol == 'Vigilante' || rol == 'Empleado') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  VigilanteHome()),
          );
        } else {
          // Redirección para Estudiantes o Visitas
          mostrarMensaje("Bienvenido ${data['nombres']}");
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EstudianteHome()));
        }
      }
    } on AuthException catch (e) {
      // Errores específicos de autenticación (credenciales inválidas, etc.)
      mostrarMensaje("Acceso denegado: ${e.message}");
    } catch (e) {
      // Errores de red o de sincronización de tablas
      mostrarMensaje("Error de sincronización con el perfil.");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    // Limpieza de controladores para evitar fugas de memoria
    correoCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/parky.png',
                  height: 220,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.directions_car, size: 100, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              
              const LabelUcad(texto: "Correo"),
              const SizedBox(height: 8),
              InputUcad(hint: "ejemplo@ucad.edu.sv", controller: correoCtrl),
              const SizedBox(height: 20),
              
              const LabelUcad(texto: "Contraseña"),
              const SizedBox(height: 8),
              InputUcad(hint: "Tu contraseña", isPassword: true, controller: passCtrl),
              const SizedBox(height: 25),
              
              cargando
                  ? const Center(child: CircularProgressIndicator(color: AppColors.amarillo))
                  : BotonUcad(
                      texto: "Iniciar sesión",
                      color: AppColors.amarillo,
                      onPressed: iniciarSesion,
                    ),
                    
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistroPage()),
                    );
                  },
                  child: const Text(
                    "¿No tienes cuenta? Regístrate", 
                    style: TextStyle(color: Colors.white70)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}