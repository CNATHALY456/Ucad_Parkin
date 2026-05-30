import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> iniciarSesion() async {
    final email = correoCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      mostrarMensaje("Por favor, ingresa tus credenciales");
      return;
    }

    setState(() => cargando = true);

    try {
      final res = await supabase.auth.signInWithPassword(email: email, password: password);
      
      // Guardar email si se seleccionó recordar
      final prefs = await SharedPreferences.getInstance();
      _recordar ? await prefs.setString('email_usuario', email) : await prefs.remove('email_usuario');

      final user = res.user;
      if (user != null) {
        final String? rol = user.userMetadata?['tipo_usuario'];
        if (!mounted) return;

        switch (rol) {
          case 'Vigilante': _irAPantalla(const VigilanteHome()); break;
          case 'Estudiante': case 'Empleado': _irAPantalla(const UsuarioHome()); break;
          case 'Admin': _irAPantalla(const AdminHome()); break;
          default:
            await supabase.auth.signOut();
            mostrarMensaje("Acceso restringido: No tienes un rol válido.");
        }
      }
    } catch (e) {
      mostrarMensaje("Correo o contraseña incorrectos");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _irAPantalla(Widget vista) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => vista), (route) => false);
  }

  void mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? theme.surface : AppColors.azul,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Image.asset(
                isDark ? 'assets/parky2.jpeg' : 'assets/parky.png',
                height: 150,
                errorBuilder: (c, e, s) => Icon(Icons.directions_car, size: 100, color: Colors.white),
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
                    onChanged: (val) => setState(() => _recordar = val!),
                  ),
                  Text("Recordar cuenta", style: TextStyle(color: isDark ? Colors.white70 : Colors.white)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecuperarPassword())),
                    child: const Text("¿Olvidaste tu clave?", style: TextStyle(color: AppColors.amarillo)),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              cargando 
                ? const CircularProgressIndicator(color: AppColors.amarillo)
                : BotonUcad(texto: "INICIAR SESIÓN", color: AppColors.amarillo, onPressed: iniciarSesion),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroPage())),
                child: Text(
                  "¿No tienes cuenta? Regístrate aquí",
                  style: TextStyle(
                    color: isDark ? AppColors.amarillo : Colors.white, 
                    fontWeight: FontWeight.bold
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