import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/providers/config_provider.dart';

class UsuariosAdmin extends StatefulWidget {
  const UsuariosAdmin({super.key});

  @override
  State<UsuariosAdmin> createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  final supabase = Supabase.instance.client;
  String filtroBusqueda = "";

  // --- FUNCIÓN PARA ELIMINAR USUARIO ---
  Future<void> eliminarUsuario(String id) async {
    try {
      await supabase.from('perfiles').delete().eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario eliminado correctamente")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FUNCIÓN PARA MOSTRAR MODAL DE EDICIÓN CON RESPALDO DARK ---
  void mostrarModalEditar(Map<String, dynamic> usuario, bool isDark, ColorScheme theme) {
    final nombresCtrl = TextEditingController(text: usuario['nombres']);
    final telefonoCtrl = TextEditingController(text: usuario['telefono'] ?? '');
    final placaCtrl = TextEditingController(text: usuario['placa_principal'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface, // Se adapta al color de fondo del tema actual
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Editar Usuario",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nombresCtrl,
                style: TextStyle(color: theme.onSurface),
                decoration: InputDecoration(
                  labelText: "Nombre Completo", 
                  labelStyle: TextStyle(color: theme.onSurfaceVariant),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telefonoCtrl,
                style: TextStyle(color: theme.onSurface),
                decoration: InputDecoration(
                  labelText: "Teléfono", 
                  labelStyle: TextStyle(color: theme.onSurfaceVariant),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: placaCtrl,
                style: TextStyle(color: theme.onSurface),
                decoration: InputDecoration(
                  labelText: "Placa Principal", 
                  labelStyle: TextStyle(color: theme.onSurfaceVariant),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? theme.primary : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    try {
                      await supabase.from('perfiles').update({
                        'nombres': nombresCtrl.text.trim(),
                        'telefono': telefonoCtrl.text.trim(),
                        'placa_principal': placaCtrl.text.trim().toUpperCase(),
                      }).eq('id', usuario['id']);
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Usuario actualizado con éxito")),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error al actualizar: $e"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: Text(
                    "GUARDAR CAMBIOS", 
                    style: TextStyle(color: theme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- FUNCIÓN PARA CONFIRMAR ELIMINACIÓN ADAPTATIVA ---
  void mostrarDialogoEliminar(String id, String nombre, ColorScheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text("¿Eliminar usuario?", style: TextStyle(color: theme.onSurface)),
        content: Text(
          "Esta acción borrará de forma permanente a $nombre del sistema.",
          style: TextStyle(color: theme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              eliminarUsuario(id);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LECTURA DE CONFIG_PROVIDER Y THEME GENERATOR ---
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Buscador adaptativo
        TextField(
          onChanged: (value) {
            setState(() {
              filtroBusqueda = value.toLowerCase();
            });
          },
          style: TextStyle(color: theme.onSurface),
          decoration: InputDecoration(
            hintText: "Buscar usuario",
            hintStyle: TextStyle(color: theme.onSurfaceVariant),
            prefixIcon: Icon(Icons.search, color: theme.onSurfaceVariant),
            filled: true,
            fillColor: isDark ? theme.surfaceContainerHighest : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('perfiles').stream(primaryKey: ['id']),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: theme.onSurface)));
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(color: isDark ? theme.primary : Colors.blue));
              }

              final listaUsuarios = snapshot.data!.where((u) {
                final nombre = (u['nombres'] ?? '').toString().toLowerCase();
                final placa = (u['placa_principal'] ?? '').toString().toLowerCase();
                return nombre.contains(filtroBusqueda) || placa.contains(filtroBusqueda) || placa.contains(filtroBusqueda);
              }).toList();

              if (listaUsuarios.isEmpty) {
                return const Center(
                  child: Text(
                    "No se encontraron usuarios", 
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: listaUsuarios.length,
                itemBuilder: (context, index) {
                  final usuario = listaUsuarios[index];
                  
                  final String idReal = usuario['id'].toString();
                  final String nombreReal = usuario['nombres'] ?? "Usuario sin nombre";
                  final String placa = usuario['placa_principal'] != null 
                      ? "Placa: ${usuario['placa_principal']}" 
                      : "Sin vehículo asignado";

                  return Card(
                    // Cambia dinámicamente el color del fondo de la tarjeta
                    color: isDark ? theme.surfaceContainer : Colors.white,
                    elevation: isDark ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryContainer,
                        child: Icon(Icons.person, color: theme.onPrimaryContainer),
                      ),
                      title: Text(
                        nombreReal, 
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.onSurface),
                      ),
                      subtitle: Text(
                        placa, 
                        style: TextStyle(color: theme.onSurfaceVariant),
                      ),
                      trailing: PopupMenuButton<int>(
                        color: theme.surface, // Fondo adaptativo para el menú flotante
                        iconColor: theme.onSurfaceVariant,
                        onSelected: (value) {
                          if (value == 1) {
                            mostrarModalEditar(usuario, isDark, theme);
                          } else if (value == 2) {
                            mostrarDialogoEliminar(idReal, nombreReal, theme);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1, 
                            child: Text("Editar", style: TextStyle(color: theme.onSurface)),
                          ),
                          const PopupMenuItem(
                            value: 2, 
                            child: Text("Eliminar", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}