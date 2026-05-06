import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final supabase = Supabase.instance.client;
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool cargando = false;
  bool cambiarPass = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeAuth();
  }

  void _cargarDatosDesdeAuth() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        nombreCtrl.text = user.userMetadata?['nombres'] ?? "";
        apellidoCtrl.text = user.userMetadata?['apellidos'] ?? "";
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (nombreCtrl.text.trim().isEmpty) {
      _mostrarMensaje("El nombre no puede estar vacío");
      return;
    }

    setState(() => cargando = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          password: (cambiarPass && passCtrl.text.isNotEmpty) ? passCtrl.text.trim() : null,
          data: {
            'nombres': nombreCtrl.text.trim(),
            'apellidos': apellidoCtrl.text.trim(),
          },
        ),
      );

      if (!mounted) return;
      _mostrarMensaje("Perfil actualizado correctamente");
      Navigator.pop(context, true);
    } catch (e) {
      _mostrarMensaje("Error al actualizar", esError: true);
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _mostrarMensaje(String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: esError ? Colors.red : Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado del tema
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? theme.surface : Colors.white,
      appBar: AppBar(
        title: const Text("Editar Perfil", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.azul,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildInput(
              label: "Nombre",
              icon: Icons.person_outline,
              controller: nombreCtrl,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildInput(
              label: "Apellidos",
              icon: Icons.badge_outlined,
              controller: apellidoCtrl,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildInput(
              label: "Correo",
              icon: Icons.email_outlined,
              controller: TextEditingController(text: supabase.auth.currentUser?.email),
              enabled: false,
              isDark: isDark,
            ),
            const SizedBox(height: 25),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cambiar contraseña", 
                  style: TextStyle(
                    fontSize: 16, 
                    color: isDark ? Colors.white : Colors.black87, 
                    fontWeight: FontWeight.w500
                  )
                ),
                Switch(
                  value: cambiarPass,
                  onChanged: (v) => setState(() => cambiarPass = v),
                  activeColor: AppColors.amarillo,
                ),
              ],
            ),
            
            if (cambiarPass) ...[
              const SizedBox(height: 15),
              _buildInput(
                label: "Nueva Contraseña",
                icon: Icons.lock_outline,
                controller: passCtrl,
                isPassword: true,
                isDark: isDark,
              ),
            ],

            const SizedBox(height: 40),

            cargando
                ? const CircularProgressIndicator(color: AppColors.amarillo)
                : ElevatedButton(
                    onPressed: _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amarillo,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Guardar Cambios", 
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label, 
    required IconData icon, 
    required TextEditingController controller, 
    bool enabled = true, 
    bool isPassword = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword,
        style: TextStyle(
          fontSize: 15, 
          color: isDark ? Colors.white : Colors.black87
        ),
        decoration: InputDecoration(
          icon: Icon(
            icon, 
            color: isDark ? Colors.white54 : Colors.black54, 
            size: 22
          ),
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black45),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}