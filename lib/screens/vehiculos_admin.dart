import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/providers/config_provider.dart';

class VehiculosAdmin extends StatefulWidget {
  const VehiculosAdmin({super.key});

  @override
  State<VehiculosAdmin> createState() => _VehiculosAdminState();
}

class _VehiculosAdminState extends State<VehiculosAdmin> {
  final supabase = Supabase.instance.client;

  // --- FUNCIÓN REAL PARA ELIMINAR EL VEHÍCULO DE LA TABLA ---
  Future<void> eliminarVehiculo(int idVehiculo, String placa) async {
    try {
      await supabase.from('vehiculos').delete().eq('id_vehiculo', idVehiculo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vehículo con placa $placa eliminado con éxito")),
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

  // --- DIÁLOGO DE CONFIRMACIÓN ADAPTATIVO ---
  void mostrarDialogoConfirmacion(int idVehiculo, String placa, ColorScheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface, // Se adapta al fondo oscuro o claro
        title: Text(
          "¿Eliminar vehículo?", 
          style: TextStyle(color: theme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Esta acción eliminará la placa $placa de forma permanente de la base de datos.",
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
              eliminarVehiculo(idVehiculo, placa);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- ACCESO AL PROV_CONFIG Y COLOR SCHEME ---
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('vehiculos').stream(primaryKey: ['id_vehiculo']),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}", 
              style: TextStyle(color: theme.onSurface),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? theme.primary : Colors.blue,
            ),
          );
        }

        final listaVehiculos = snapshot.data!;

        if (listaVehiculos.isEmpty) {
          return const Center(
            child: Text(
              "No hay vehículos registrados en el sistema",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: listaVehiculos.length,
          itemBuilder: (context, index) {
            final vehiculo = listaVehiculos[index];
            
            final int idVehiculo = int.parse(vehiculo['id_vehiculo'].toString());
            final String placaReal = vehiculo['placa'] ?? "Sin Placa";
            final String marca = vehiculo['marca'] ?? "";
            final String modelo = vehiculo['modelo'] ?? "";
            
            final String descripcionVehiculo = "$marca $modelo".trim().isNotEmpty 
                ? "$marca $modelo" 
                : "Vehículo no especificado";

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                // Cambia dinámicamente de blanco a fondo de contenedor oscuro
                color: isDark ? theme.surfaceContainer : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black : Colors.black12, 
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  Icons.directions_car, 
                  size: 35, 
                  color: isDark ? theme.primary : Colors.blue, // Icono adaptativo
                ),
                title: Text(
                  placaReal,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface, // Texto principal responsivo
                  ),
                ),
                subtitle: Text(
                  descripcionVehiculo,
                  style: TextStyle(color: theme.onSurfaceVariant), // Subtítulo responsivo
                ), 
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    mostrarDialogoConfirmacion(idVehiculo, placaReal, theme);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
