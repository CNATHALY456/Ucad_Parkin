import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String avatarActual = 'assets/parky.png'; // Avatar por defecto
  bool cargando = true;
  bool refrescando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeAuth();
  }

  // --- CARGAR DATOS DESDE METADATOS DE AUTH ---
  void _cargarDatosDesdeAuth() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          nombreMostrar = "${user.userMetadata?['nombres'] ?? ''} ${user.userMetadata?['apellidos'] ?? ''}".trim();
          rolMostrar = user.userMetadata?['tipo_usuario'] ?? "Usuario";
          
          // Ahora usamos 'avatar_path' de los metadatos en lugar de una URL de storage
          avatarActual = user.userMetadata?['avatar_path'] ?? 'assets/parky.png';
          
          if (nombreMostrar.isEmpty) nombreMostrar = "Usuario UCAD";
          cargando = false;
        });
      }
    }
  }

  // --- FUNCIÓN REFRESH PARA SINCRONIZAR CON EL SERVIDOR ---
  Future<void> _refreshPerfil() async {
    setState(() => refrescando = true);
    try {
      // Forzamos la actualización de la sesión para obtener metadatos frescos
      await supabase.auth.refreshSession();
      _cargarDatosDesdeAuth();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado desde la nube")),
        );
      }
    } catch (e) {
      debugPrint("Error al refrescar: $e");
    } finally {
      if (mounted) setState(() => refrescando = false);
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
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final Color colorOpciones = isDark ? Colors.white : AppColors.azul;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.azul,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // BOTÓN REFRESH AGREGADO
          IconButton(
            icon: refrescando 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.refresh, color: Colors.white),
            onPressed: refrescando ? null : _refreshPerfil,
            tooltip: "Actualizar datos",
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.amarillo))
          : Column(
              children: [
                const SizedBox(height: 10),
                
                // Foto de Perfil (Solo muestra el avatar seleccionado)
                Center(
                  child: Container(
                    width: 140, 
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white, 
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        avatarActual, 
                        fit: BoxFit.cover,
                        // Error builder por si la ruta en metadatos está rota
                        errorBuilder: (context, error, stackTrace) => Image.asset('assets/parky.png'),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
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
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ItemPerfil(
                            texto: "Mi perfil",
                            icono: Icons.person_outline,
                            color: colorOpciones,
                            onTap: () async {
                              // Al volver de editar, recargamos la info local
                              await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const EditarPerfil())
                              );
                              _cargarDatosDesdeAuth();
                            },
                          ),
                          ItemPerfil(
                            texto: "Configuración",
                            icono: Icons.settings_outlined,
                            color: colorOpciones,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionPage())),
                          ),
                          ItemPerfil(
                            texto: "Notificaciones",
                            icono: Icons.notifications_none,
                            color: colorOpciones,
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
    );
  }
}