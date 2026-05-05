import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ucad_parki/screens/vigilante_home.dart';
import 'package:ucad_parki/screens/editar_perfil.dart';
import 'package:ucad_parki/screens/login.dart';
import 'package:ucad_parki/screens/configuracion_page.dart';
import 'package:ucad_parki/screens/notificaciones_page.dart';
import 'package:ucad_parki/widgets/item_perfil.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final supabase = Supabase.instance.client;
  
  String nombreMostrar = "";
  String rolMostrar = "";
  String? fotoUrl;
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeAuth();
  }

  void _cargarDatosDesdeAuth() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        nombreMostrar = "${user.userMetadata?['nombres'] ?? ''} ${user.userMetadata?['apellidos'] ?? ''}".trim();
        rolMostrar = user.userMetadata?['tipo_usuario'] ?? "Usuario";
        fotoUrl = user.userMetadata?['url_avatar'];
        
        if (nombreMostrar.isEmpty) nombreMostrar = "Usuario UCAD";
      });
    }
  }

  Future<void> _cambiarFoto() async {
    final picker = ImagePicker();
    final XFile? imagenSeleccionada = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, 
    );

    if (imagenSeleccionada == null) return;

    setState(() => cargando = true);

    try {
      final user = supabase.auth.currentUser;
      final file = File(imagenSeleccionada.path);
      final fileExtension = imagenSeleccionada.path.split('.').last;
      final fileName = '${user!.id}.$fileExtension';
      final filePath = 'avatars/$fileName';

      await supabase.storage.from('perfiles').upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl = supabase.storage.from('perfiles').getPublicUrl(filePath);

      await supabase.auth.updateUser(
        UserAttributes(data: {'url_avatar': publicUrl}),
      );

      _cargarDatosDesdeAuth();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar foto: $e")),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      body: SafeArea(
        child: cargando
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  // BOTÓN VOLVER
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>  VigilanteHome()),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // SECCIÓN DE FOTO, NOMBRE Y ROL (DISEÑO image_2ae8bd.jpg)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: fotoUrl != null 
                            ? Image.network(fotoUrl!, fit: BoxFit.cover)
                            : Image.asset('assets/parky.png', fit: BoxFit.cover),
                        ),
                      ),
                      // BOTÓN AMARILLO DE EDITAR
                      GestureDetector(
                        onTap: _cambiarFoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.amarillo,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.black, size: 22),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    nombreMostrar,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    rolMostrar,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 35),

                  // CONTENEDOR BLANCO DE OPCIONES
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                      child: Column(
                        children: [
                          ItemPerfil(
                            texto: "Mi perfil",
                            icono: Icons.person_outline,
                            color: AppColors.azul,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  EditarPerfil())),
                          ),
                          ItemPerfil(
                            texto: "Configuración",
                            icono: Icons.settings_outlined,
                            color: AppColors.azul,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  ConfiguracionPage())),
                          ),
                          ItemPerfil(
                            texto: "Notificaciones",
                            icono: Icons.notifications_none,
                            color: AppColors.azul,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  NotificacionesPage())),
                          ),
                          const Spacer(),
                          const Divider(height: 40),
                          ItemPerfil(
                            texto: "Cerrar sesión",
                            icono: Icons.logout,
                            color: Colors.redAccent,
                            onTap: _cerrarSesion,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}