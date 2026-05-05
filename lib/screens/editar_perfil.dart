import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool cambiarPass = false; // Controla si se muestra el campo de contraseña

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre no puede estar vacío")),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado correctamente")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio
      appBar: AppBar(
        title: const Text("Editar Perfil", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: AppColors.azul,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // CAMPO NOMBRE
            _buildInput(
              label: "Nombre",
              icon: Icons.person_outline,
              controller: nombreCtrl,
            ),
            const SizedBox(height: 20),
            // CAMPO APELLIDOS
            _buildInput(
              label: "Apellidos",
              icon: Icons.badge_outlined,
              controller: apellidoCtrl,
            ),
            const SizedBox(height: 20),
            // CAMPO CORREO (Solo lectura para estética)
            _buildInput(
              label: "Correo",
              icon: Icons.email_outlined,
              controller: TextEditingController(text: supabase.auth.currentUser?.email),
              enabled: false,
            ),
            const SizedBox(height: 25),
            
            // SWITCH CAMBIAR CONTRASEÑA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cambiar contraseña", 
                  style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
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
              ),
            ],

            const SizedBox(height: 40),

            // BOTÓN GUARDAR
            cargando
                ? const CircularProgressIndicator(color: AppColors.azul)
                : ElevatedButton(
                    onPressed: _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amarillo,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text("Guardar Cambios", 
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // WIDGET AUXILIAR PARA LOS CAMPOS GRISES
  Widget _buildInput({
    required String label, 
    required IconData icon, 
    required TextEditingController controller, 
    bool enabled = true, 
    bool isPassword = false
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB), // Gris azulado muy claro
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.black54, size: 22),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45),
          border: InputBorder.none, // Quitamos la línea de abajo
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}