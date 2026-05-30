import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:ucad_parki/screens/vigilante_home.dart';
import 'package:ucad_parki/screens/usuario_home.dart';
import 'package:ucad_parki/screens/home_admin.dart';
import 'package:ucad_parki/providers/config_provider.dart';
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

  void mostrarMensaje(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: 'TU_ID_CLIENTE_WEB_DE_GOOGLE');
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
    } catch (e) {
      mostrarMensaje("Error al iniciar con Google");
    }
  }

  Future<void> iniciarSesion() async {
    setState(() => cargando = true);
    try {
      final res = await supabase.auth.signInWithPassword(email: correoCtrl.text.trim(), password: passCtrl.text.trim());
      if (res.user != null) {
        final String? rol = res.user!.userMetadata?['tipo_usuario'];
        if (rol == 'Vigilante') _irAPantalla(const VigilanteHome());
        else if (rol == 'Estudiante' || rol == 'Empleado') _irAPantalla(const UsuarioHome());
        else if (rol == 'Admin') _irAPantalla(const AdminHome());
      }
    } catch (_) {
      mostrarMensaje("Credenciales incorrectas");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _irAPantalla(Widget vista) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => vista), (route) => false);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).colorScheme.surface : AppColors.azul,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset(isDark ? 'assets/parky2.jpeg' : 'assets/parky.png', height: 150)),
                const SizedBox(height: 30),
                const LabelUcad(texto: "Correo Institucional"),
                InputUcad(hint: "ejemplo@ucad.edu.sv", controller: correoCtrl),
                const SizedBox(height: 20),
                const LabelUcad(texto: "Contraseña"),
                InputUcad(hint: "Tu contraseña", isPassword: true, controller: passCtrl),
                const SizedBox(height: 20),
                cargando ? const Center(child: CircularProgressIndicator(color: AppColors.amarillo))
                         : BotonUcad(texto: "INICIAR SESIÓN", color: AppColors.amarillo, onPressed: iniciarSesion),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: signInWithGoogle,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google.png', height: 24),
                      const SizedBox(width: 10),
                      const Text("Acceder con Google", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Center(child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroPage())), child: const Text("¿No tienes cuenta? Regístrate aquí", style: TextStyle(color: Colors.white)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}