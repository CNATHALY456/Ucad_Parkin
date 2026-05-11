import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class MiVehiculo extends StatefulWidget {
  const MiVehiculo({super.key});

  @override
  State<MiVehiculo> createState() => _MiVehiculoState();
}

class _MiVehiculoState extends State<MiVehiculo> {
  // 📝 CONTROLLERS
  final placaCtrl = TextEditingController();
  final marcaCtrl = TextEditingController();
  final modeloCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final anioCtrl = TextEditingController();

  String tipoVehiculo = "Carro";
  bool cargando = false;

  // ➕ GUARDAR VEHÍCULO Y VINCULAR AL PERFIL
  Future<void> guardarEnSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      _mostrarSnack("Sesión no iniciada", Colors.red);
      return;
    }

    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (placaLimpia.isEmpty) {
      _mostrarSnack("La placa es obligatoria", Colors.orange);
      return;
    }

    setState(() => cargando = true);

    try {
      // Mapeo de tipos de vehículo (1: Carro, 2: Moto, 3: Bicicleta)
      int idTipo = 1; 
      if (tipoVehiculo == "Moto") idTipo = 2;
      if (tipoVehiculo == "Bicicleta") idTipo = 3;

      // 1. Insertar en la tabla 'vehiculos'
      await Supabase.instance.client.from('vehiculos').insert({
        'id_usuario': user.id,
        'placa': placaLimpia,
        'marca': marcaCtrl.text.trim(),
        'modelo': modeloCtrl.text.trim(),
        'color': colorCtrl.text.trim(),
        'anio': int.tryParse(anioCtrl.text) ?? 0,
        'id_tipo_vehiculo': idTipo, 
        'estado': 'activo', 
      });

      // 2. Actualizar el perfil del usuario (Vínculo para Mi Parqueo)
      await Supabase.instance.client.from('perfiles').update({
        'placa_principal': placaLimpia,
      }).eq('id', user.id);

      if (mounted) {
        _limpiarFormulario();
        Navigator.pop(context); // Cerrar el modal
        _mostrarSnack("¡Vehículo registrado con éxito!", Colors.green);
      }
    } on PostgrestException catch (e) {
      String mensaje = e.code == '23505' ? "Esta placa ya existe" : "Error de base de datos";
      if (mounted) _mostrarSnack(mensaje, Colors.red);
    } catch (e) {
      if (mounted) _mostrarSnack("Error inesperado al guardar", Colors.red);
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // ❌ ELIMINAR VEHÍCULO Y LIMPIAR PERFIL
  Future<void> eliminarVehiculo(dynamic idVehiculo) async {
    final user = Supabase.instance.client.auth.currentUser;
    try {
      // Borrar el vehículo
      await Supabase.instance.client
          .from('vehiculos')
          .delete()
          .eq('id_vehiculo', idVehiculo);
          
      // Desvincular del perfil para que MiParqueo se resetee
      if (user != null) {
        await Supabase.instance.client.from('perfiles').update({
          'placa_principal': null, 
        }).eq('id', user.id);
      }

      if (mounted) _mostrarSnack("Vehículo eliminado", Colors.black87);
    } catch (e) {
      debugPrint("Error al eliminar: $e");
    }
  }

  void _limpiarFormulario() {
    placaCtrl.clear();
    marcaCtrl.clear();
    modeloCtrl.clear();
    colorCtrl.clear();
    anioCtrl.clear();
  }

  void _mostrarSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color)
    );
  }

  // 🎨 DISEÑO DEL MODAL PARA AGREGAR
  void mostrarFormulario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: EdgeInsets.only(
                left: 25, right: 25, top: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60, height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Nuevo Vehículo",
                      style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.amarillo : AppColors.azul,
                      ),
                    ),
                    const SizedBox(height: 25),
                    campo("Placa (Ej: P123456)", placaCtrl, isDark),
                    campo("Marca", marcaCtrl, isDark),
                    campo("Modelo", modeloCtrl, isDark),
                    campo("Color", colorCtrl, isDark),
                    campo("Año", anioCtrl, isDark),
                    const SizedBox(height: 10),
                    Text("Tipo", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.amarillo : AppColors.azul)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tipoVehiculo,
                      dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                      items: ["Carro", "Moto", "Bicicleta"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) => setModalState(() => tipoVehiculo = value!),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cargando ? null : guardarEnSupabase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azul,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: cargando 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Guardar", style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData iconoVehiculo(int idTipo) {
    if (idTipo == 2) return Icons.two_wheeler;
    if (idTipo == 3) return Icons.pedal_bike;
    return Icons.directions_car;
  }

  Widget campo(String titulo, TextEditingController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(color: isDark ? Colors.white70 : AppColors.azul, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return const Center(child: Text("Sesión no iniciada"));

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('vehiculos')
          .stream(primaryKey: ['id_vehiculo']) // Ajustado a tu base de datos
          .eq('id_usuario', user.id)
          .order('id_vehiculo', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.amarillo));
        }

        final vehiculosDB = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mi Vehículo",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: isDark ? AppColors.amarillo : AppColors.azul),
              ),
              const SizedBox(height: 25),

              if (vehiculosDB.isEmpty)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: Icon(Icons.car_rental, size: 150, color: Colors.grey.shade300)),
                      const SizedBox(height: 20),
                      Text("No tienes ningún vehículo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.azul)),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: mostrarFormulario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.azul,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text("Agregar ahora", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          itemCount: vehiculosDB.length,
                          itemBuilder: (context, index) {
                            final v = vehiculosDB[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [if (!isDark) const BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(iconoVehiculo(v["id_tipo_vehiculo"] ?? 1), size: 100, color: isDark ? AppColors.amarillo : AppColors.azul),
                                  const SizedBox(height: 20),
                                  Text(v["placa"], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                  Text("${v["marca"]} ${v["modelo"]}", style: const TextStyle(fontSize: 18, color: Colors.grey)),
                                  const SizedBox(height: 25),
                                  ElevatedButton.icon(
                                    onPressed: () => eliminarVehiculo(v["id_vehiculo"]),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                    icon: const Icon(Icons.delete),
                                    label: const Text("Eliminar"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: mostrarFormulario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.azul,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text("Agregar otro", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}