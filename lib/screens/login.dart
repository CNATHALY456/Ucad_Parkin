import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTACIONES DE DESTINO ACTUALIZADAS ---
import 'package:ucad_parki/screens/vigilante_home.dart';
import 'package:ucad_parki/screens/usuario_home.dart'; 
import 'package:ucad_parki/screens/home_admin.dart'; 

import 'package:ucad_parki/widgets/input_ucad.dart';
import 'package:ucad_parki/widgets/boton_ucad.dart';
import 'package:ucad_parki/widgets/label_ucad.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/screens/registro.dart';
import 'package:ucad_parki/screens/recuperar_password.dart';

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
  bool _recordar = false;

  @override
  void initState() {
    super.initState();
    _cargarCredenciales();
  }

  Future<void> _cargarCredenciales() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      correoCtrl.text = prefs.getString('email_usuario') ?? "";
      _recordar = correoCtrl.text.isNotEmpty;
    });
  }

  Future<void> _gestionarRecordatorio() async {
    final prefs = await SharedPreferences.getInstance();
    if (_recordar) {
      await prefs.setString('email_usuario', correoCtrl.text.trim());
    } else {
      await prefs.remove('email_usuario');
    }
  }

  Future<void> iniciarSesion() async {
    final email = correoCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      mostrarMensaje("Por favor, ingresa tus credenciales");
      return;
    }

    setState(() => cargando = true);

    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await _gestionarRecordatorio();

      final user = res.user;
      if (user != null) {
        // Obtenemos el rol de los metadatos de usuario de Supabase
        final String? rol = user.userMetadata?['tipo_usuario'];

        if (!mounted) return;

        // --- ENRUTADOR SEGÚN ROL ACTUALIZADO Y SEGURO ---
        switch (rol) {
          case 'Vigilante':
            _irAPantalla(const VigilanteHome());
            break;

          case 'Estudiante':
          case 'Empleado':
            _irAPantalla(const UsuarioHome()); 
            break;

          case 'Admin':
            // --- CAMBIO: El rol de administrador ahora despliega su vista correspondiente ---
            _irAPantalla(const AdminHome()); 
            break;

          default:
            await supabase.auth.signOut();
            mostrarMensaje("Acceso restringido: No tienes un rol válido asignado.");
            break;
        }
      }
    } on AuthException catch (e) {
      mostrarMensaje("Error: ${e.message}");
    } catch (e) {
      mostrarMensaje("Error de conexión o datos incorrectos");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _irAPantalla(Widget vista) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => vista),
      (route) => false,
    );
  }
  
  void mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
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
                  height: 180,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.directions_car, size: 100, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              
              const LabelUcad(texto: "Correo Institucional"),
              InputUcad(hint: "ejemplo@ucad.edu.sv", controller: correoCtrl),
              
              const SizedBox(height: 20),
              
              const LabelUcad(texto: "Contraseña"),
              InputUcad(hint: "Tu contraseña", isPassword: true, controller: passCtrl),
              
              Row(
                children: [
                  Checkbox(
                    value: _recordar,
                    activeColor: AppColors.amarillo,
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.white70),
                    onChanged: (val) => setState(() => _recordar = val!),
                  ),
                  const Text("Recordar cuenta", style: TextStyle(color: Colors.white70)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const RecuperarPassword())
                    ),
                    child: const Text(
                      "¿Olvidaste tu clave?", 
                      style: TextStyle(color: AppColors.amarillo, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              
              cargando
                  ? const Center(child: CircularProgressIndicator(color: AppColors.amarillo))
                  : BotonUcad(
                      texto: "INICIAR SESIÓN",
                      color: AppColors.amarillo,
                      onPressed: iniciarSesion,
                    ),
              
              const SizedBox(height: 10),
              
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const RegistroPage())
                  ),
                  child: const Text("¿No tienes cuenta? Regístrate aquí", style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}