import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
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
    final XFile? imagenSeleccionada = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
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
        fileOptions: const FileOptions(upsert: true)
      );
      
      final String publicUrl = supabase.storage.from('perfiles').getPublicUrl(filePath);
      await supabase.auth.updateUser(UserAttributes(data: {'url_avatar': publicUrl}));
      
      _cargarDatosDesdeAuth();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos si el modo oscuro está activo mediante el Provider
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    
    // Definimos el color que usarán los textos e iconos de las opciones
    final Color colorOpciones = isDark ? Colors.white : AppColors.azul;

    return Scaffold(
      // Fondo adaptativo para la parte superior (detrás de la foto)
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.azul,
      body: SafeArea(
        child: cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.amarillo))
            : Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Foto de Perfil
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 140, 
                        height: 140,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white, 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: fotoUrl != null 
                            ? Image.network(fotoUrl!, fit: BoxFit.cover)
                            : Image.asset('assets/parky.png', fit: BoxFit.cover),
                        ),
                      ),
                      GestureDetector(
                        onTap: _cambiarFoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.amarillo, 
                            shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Nombre y Rol siempre en blanco para contrastar con el fondo superior oscuro/azul
                  Text(
                    nombreMostrar, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  Text(
                    rolMostrar, 
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15)
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Contenedor de Opciones
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                      decoration: BoxDecoration(
                        // Color de fondo del panel inferior adaptativo
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ItemPerfil(
                              texto: "Mi perfil",
                              icono: Icons.person_outline,
                              color: colorOpciones, // Cambia a blanco en dark mode
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditarPerfil())),
                            ),
                            ItemPerfil(
                              texto: "Configuración",
                              icono: Icons.settings_outlined,
                              color: colorOpciones, // Cambia a blanco en dark mode
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionPage())),
                            ),
                            ItemPerfil(
                              texto: "Notificaciones",
                              icono: Icons.notifications_none,
                              color: colorOpciones, // Cambia a blanco en dark mode
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificacionesPage())),
                            ),
                            
                            const Divider(height: 50, thickness: 1),
                            
                            ItemPerfil(
                              texto: "Cerrar sesión",
                              icono: Icons.logout,
                              color: Colors.redAccent,
                              onTap: _cerrarSesion,
                            ),
                            const SizedBox(height: 20),
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