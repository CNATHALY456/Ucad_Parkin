import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Para seleccionar la foto
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
  Map<String, dynamic>? datosUsuario;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _obtenerDatosPerfil();
  }

  Future<void> _obtenerDatosPerfil() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('usuarios')
            .select()
            .eq('id_usuario', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            datosUsuario = data;
            cargando = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => cargando = false);
    }
  }

  // FUNCIÓN PARA SELECCIONAR Y SUBIR LA FOTO
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

      // 1. Subir imagen al Bucket 'perfiles' de Supabase Storage
      await supabase.storage.from('perfiles').upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Obtener la URL pública
      final String publicUrl =
          supabase.storage.from('perfiles').getPublicUrl(filePath);

      // 3. Actualizar la URL en la tabla 'usuarios'
      await supabase.from('usuarios').update({
        'url_avatar': publicUrl,
      }).eq('id_usuario', user.id);

      _obtenerDatosPerfil(); // Recargar datos
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al subir imagen: $e")),
      );
      setState(() => cargando = false);
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
    final nombre = datosUsuario?['nombres'] ?? "Cargando...";
    final apellido = datosUsuario?['apellidos'] ?? "";
    final fotoUrl = datosUsuario?['url_avatar'] ?? 'assets/avatar1.png';

    return Scaffold(
      backgroundColor: AppColors.azul,
      body: SafeArea(
        child: cargando
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  const SizedBox(height: 10),
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

                  // FOTO CON BOTÓN DE EDICIÓN
                  Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: fotoUrl.startsWith('http')
                              ? NetworkImage(fotoUrl) as ImageProvider
                              : AssetImage(fotoUrl),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: GestureDetector(
                          onTap: _cambiarFoto, // Acción de editar
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.amarillo,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: AppColors.azul, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "$nombre $apellido",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TARJETA DE OPCIONES (Mantiene tu diseño original)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ItemPerfil(
                              texto: "Mi perfil",
                              icono: Icons.person,
                              color: AppColors.azul,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  EditarPerfil()),
                              ),
                            ),
                            ItemPerfil(
                              texto: "Configuración",
                              icono: Icons.settings,
                              color: AppColors.azul,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  ConfiguracionPage()),
                              ),
                            ),
                            ItemPerfil(
                              texto: "Notificaciones",
                              icono: Icons.notifications,
                              color: AppColors.azul,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  NotificacionesPage()),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            ItemPerfil(
                              texto: "Cerrar sesión",
                              icono: Icons.logout,
                              color: Colors.red,
                              onTap: _cerrarSesion,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}