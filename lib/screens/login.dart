import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTACIONES DE DESTINO ---
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
        final String? rol = user.userMetadata?['tipo_usuario'];

        if (!mounted) return;

        switch (rol) {
          case 'Vigilante':
            _irAPantalla(const VigilanteHome());
            break;

          case 'Estudiante':
          case 'Empleado':
            _irAPantalla(const UsuarioHome()); 
            break;

          case 'Admin':
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
    // --- LECTURA DEL ESTADO DESDE EL CONFIG_PROVIDER ---
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      // CORRECCIÓN DEL ERROR: Si está en modo oscuro usa theme.surface (el gris oscuro de tu main.dart), 
      // si no, mantiene el fondo corporativo AppColors.azul original para que el login no cambie.
      backgroundColor: isDark ? theme.surface : AppColors.azul,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  // CAMBIO DE IMAGEN DINÁMICA:
                  isDark ? 'assets/parky2.jpeg' : 'assets/parky.png', 
                  height: 180,
                  // Si no usas assets diferentes y prefieres teñir el logo nativo:
                  // color: isDark ? theme.onSurface : null,
                  // colorBlendMode: isDark ? BlendMode.srcIn : null,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.directions_car, 
                    size: 100, 
                    color: isDark ? theme.primary : Colors.white,
                  ),
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
                    // Borde del checkbox dinámico para que no se pierda en el fondo oscuro
                    side: BorderSide(color: isDark ? theme.onSurfaceVariant : Colors.white70),
                    onChanged: (val) => setState(() => _recordar = val!),
                  ),
                  Text(
                    "Recordar cuenta", 
                    style: TextStyle(color: isDark ? theme.onSurfaceVariant : Colors.white70),
                  ),
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
                  child: Text(
                    "¿No tienes cuenta? Regístrate aquí", 
                    style: TextStyle(color: isDark ? theme.primary : Colors.white70),
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