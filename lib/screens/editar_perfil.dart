import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class EditarPerfil extends StatefulWidget {
  @override
  _EditarPerfilState createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final supabase = Supabase.instance.client;
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosActuales();
  }

  // Carga los datos que ya existen en la base de datos
  Future<void> _cargarDatosActuales() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final data = await supabase
          .from('usuarios')
          .select('nombres, apellidos')
          .eq('id_usuario', user.id)
          .single();
      
      setState(() {
        nombreCtrl.text = data['nombres'];
        apellidoCtrl.text = data['apellidos'];
      });
    }
  }

  Future<void> _guardarCambios() async {
    setState(() => cargando = true);
    try {
      final user = supabase.auth.currentUser;

      // 1. Actualizar Nombres y Apellidos en la tabla pública
      await supabase.from('usuarios').update({
        'nombres': nombreCtrl.text.trim(),
        'apellidos': apellidoCtrl.text.trim(),
      }).eq('id_usuario', user!.id);

      // 2. Si el usuario escribió algo en el campo de contraseña, actualizarla en Auth
      if (passCtrl.text.isNotEmpty) {
        if (passCtrl.text.length < 6) {
          throw "La contraseña debe tener al menos 6 caracteres";
        }
        await supabase.auth.updateUser(
          UserAttributes(password: passCtrl.text.trim()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado correctamente")),
      );
      Navigator.pop(context); // Regresa a la pantalla de perfil
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: AppColors.azul,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombres"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: apellidoCtrl,
                decoration: const InputDecoration(labelText: "Apellidos"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Nueva Contraseña (dejar en blanco para no cambiar)",
                  helperText: "Mínimo 6 caracteres",
                ),
              ),
              const SizedBox(height: 30),
              cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amarillo,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("GUARDAR CAMBIOS", style: TextStyle(color: Colors.black)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}