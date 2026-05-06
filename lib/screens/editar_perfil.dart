import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  _EditarPerfilState createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidosController = TextEditingController();
  TextEditingController correoController = TextEditingController();

  bool cargandoDatos = true;
  bool guardando = false;

  final List<String> listaAvatares = [
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
  ];

  String avatarSeleccionado = 'assets/avatar1.png';

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeAuth();
  }

  // Cargamos los datos directamente del objeto User de Auth
  void _cargarDatosDesdeAuth() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        correoController.text = user.email ?? '';
        
        // Extraemos los metadatos (raw_user_meta_data)
        final metadata = user.userMetadata;
        if (metadata != null) {
          nombreController.text = metadata['nombres'] ?? '';
          apellidosController.text = metadata['apellidos'] ?? '';
          avatarSeleccionado = metadata['avatar_path'] ?? 'assets/avatar1.png';
        }
        cargandoDatos = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => guardando = true);

    try {
      // Actualizamos los metadatos del usuario en la tabla AUTH
      await supabase.auth.updateUser(
        UserAttributes(
          email: correoController.text.trim(),
          data: {
            'nombres': nombreController.text.trim(),
            'apellidos': apellidosController.text.trim(),
            'avatar_path': avatarSeleccionado,
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Perfil actualizado en Auth!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar Auth: $e")),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.azul,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cargandoDatos
          ? const Center(child: CircularProgressIndicator(color: AppColors.amarillo))
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: AssetImage(avatarSeleccionado),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Selección de Avatares
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: listaAvatares.length,
                        itemBuilder: (context, index) {
                          bool seleccionado = avatarSeleccionado == listaAvatares[index];
                          return GestureDetector(
                            onTap: () => setState(() => avatarSeleccionado = listaAvatares[index]),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: seleccionado ? AppColors.amarillo : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(listaAvatares[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                      child: Column(
                        children: [
                          _input(nombreController, "Nombre", Icons.person_outline, isDark),
                          const SizedBox(height: 20),
                          _input(apellidosController, "Apellidos", Icons.badge_outlined, isDark),
                          const SizedBox(height: 20),
                          _input(correoController, "Correo", Icons.email_outlined, isDark),
                          const SizedBox(height: 30),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: guardando ? null : _guardarCambios,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.amarillo,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: guardando 
                                ? const CircularProgressIndicator() 
                                : const Text("Guardar Cambios", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _input(TextEditingController cont, String label, IconData icon, bool isDark) {
    return TextFormField(
      controller: cont,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? AppColors.amarillo : AppColors.azul),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "Este campo es obligatorio" : null,
    );
  }
}