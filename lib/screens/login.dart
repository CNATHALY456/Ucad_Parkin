import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucad_parki/screens/vigilante_home.dart';
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
    if (correoCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      mostrarMensaje("Por favor, ingresa tus credenciales");
      return;
    }

    setState(() => cargando = true);

    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: correoCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      await _gestionarRecordatorio();

      final user = res.user;
      if (user != null) {
        final String? rol = user.userMetadata?['tipo_usuario'];

        if (!mounted) return;

        if (rol == 'Vigilante' || rol == 'Empleado') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VigilanteHome()),
          );
        }
      }
    } on AuthException catch (e) {
      mostrarMensaje("Acceso denegado: ${e.message}");
    } catch (e) {
      mostrarMensaje("Error de conexión");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.black87),
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
      // FORZADO: Siempre azul, ignorando el ConfigProvider
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
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.directions_car, size: 100, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              
              const LabelUcad(texto: "Correo"),
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
                  const Text("Recordar", style: TextStyle(color: Colors.white70)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const RecuperarPassword())
                    ),
                    child: const Text(
                      "¿Olvidaste tu contraseña?", 
                      style: TextStyle(color: AppColors.amarillo, fontWeight: FontWeight.bold, fontSize: 13)
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
                  child: const Text("¿No tienes cuenta? Regístrate", style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}