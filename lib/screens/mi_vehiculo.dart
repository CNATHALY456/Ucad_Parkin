import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class MiVehiculo extends StatefulWidget {
  const MiVehiculo({super.key});

  @override
  State<MiVehiculo> createState() => _MiVehiculoState();
}

class _MiVehiculoState extends State<MiVehiculo> {
  final supabase = Supabase.instance.client;

  // 📝 CONTROLLERS
  final placaCtrl = TextEditingController();
  final marcaCtrl = TextEditingController();
  final modeloCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final anioCtrl = TextEditingController();

  String tipoVehiculo = "Carro";
  bool cargando = false;
  dynamic idVehiculoEditando; // Nulo para nuevo, con ID para editar

  // 💾 GUARDAR O ACTUALIZAR
  Future<void> procesarVehiculo() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (placaLimpia.isEmpty) {
      _mostrarSnack("La placa es obligatoria", Colors.orange);
      return;
    }

    setState(() => cargando = true);

    try {
      int idTipo = (tipoVehiculo == "Moto") ? 2 : (tipoVehiculo == "Bicicleta" ? 3 : 1);
      
      final datos = {
        'id_usuario': user.id,
        'placa': placaLimpia,
        'marca': marcaCtrl.text.trim(),
        'modelo': modeloCtrl.text.trim(),
        'color': colorCtrl.text.trim(),
        'anio': int.tryParse(anioCtrl.text) ?? 0,
        'id_tipo_vehiculo': idTipo,
        'estado': 'activo',
      };

      if (idVehiculoEditando == null) {
        await supabase.from('vehiculos').insert(datos);
      } else {
        await supabase.from('vehiculos').update(datos).eq('id_vehiculo', idVehiculoEditando);
      }

      await supabase.from('perfiles').update({'placa_principal': placaLimpia}).eq('id', user.id);

      if (mounted) {
        Navigator.pop(context);
        _mostrarSnack(idVehiculoEditando == null ? "Vehículo Guardado" : "Vehículo Actualizado", Colors.green);
        _limpiarFormulario();
      }
    } catch (e) {
      _mostrarSnack("Error al procesar los datos", Colors.red);
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // 🗑️ ELIMINAR
  Future<void> eliminarVehiculo(dynamic id) async {
    try {
      await supabase.from('vehiculos').delete().eq('id_vehiculo', id);
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('perfiles').update({'placa_principal': null}).eq('id', user.id);
      }
      _mostrarSnack("Vehículo eliminado", Colors.black87);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _limpiarFormulario() {
    placaCtrl.clear(); marcaCtrl.clear(); modeloCtrl.clear(); colorCtrl.clear(); anioCtrl.clear();
    idVehiculoEditando = null;
    tipoVehiculo = "Carro";
  }

  void _mostrarSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // 🎨 FORMULARIO (MODAL)
  void mostrarFormulario({Map<String, dynamic>? v}) {
    if (v != null) {
      idVehiculoEditando = v['id_vehiculo'];
      placaCtrl.text = v['placa'];
      marcaCtrl.text = v['marca'] ?? '';
      modeloCtrl.text = v['modelo'] ?? '';
      colorCtrl.text = v['color'] ?? '';
      anioCtrl.text = v['anio']?.toString() ?? '';
      tipoVehiculo = v['id_tipo_vehiculo'] == 2 ? "Moto" : (v['id_tipo_vehiculo'] == 3 ? "Bicicleta" : "Carro");
    } else {
      _limpiarFormulario();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
          return Container(
            padding: EdgeInsets.fromLTRB(25, 15, 25, MediaQuery.of(context).viewInsets.bottom + 25),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 25),
                  Text(idVehiculoEditando == null ? "NUEVO VEHÍCULO" : "EDITAR VEHÍCULO", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? AppColors.amarillo : AppColors.azul)),
                  const SizedBox(height: 25),
                  _input("Placa", placaCtrl, isDark),
                  Row(
                    children: [
                      Expanded(child: _input("Marca", marcaCtrl, isDark)),
                      const SizedBox(width: 15),
                      Expanded(child: _input("Modelo", modeloCtrl, isDark)),
                    ],
                  ),
                  _input("Color", colorCtrl, isDark),
                  _input("Año", anioCtrl, isDark),
                  
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
                    onChanged: (val) => setModalState(() => tipoVehiculo = val!),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: cargando ? null : procesarVehiculo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.amarillo : AppColors.azul,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: cargando 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("GUARDAR CAMBIOS", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  // --- VISTA PRINCIPAL (CORREGIDA Y ADAPTADA) ---
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final user = supabase.auth.currentUser;

    return Container(
      // Se adapta al fondo general de la app sin barras de color toscas
      color: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FD), 
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('vehiculos').stream(primaryKey: ['id_vehiculo']).eq('id_usuario', user?.id ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final vehiculos = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "MIS VEHÍCULOS", 
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.w900, 
                        color: isDark ? AppColors.amarillo : AppColors.azul
                      )
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle, 
                        color: isDark ? AppColors.amarillo : AppColors.azul, 
                        size: 35
                      ),
                      onPressed: () => mostrarFormulario(),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                
                if (vehiculos.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "No tienes vehículos registrados", 
                        style: TextStyle(color: Colors.grey[400], fontSize: 16)
                      )
                    )
                  )
                else
                  Expanded(
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.95),
                      itemCount: vehiculos.length,
                      itemBuilder: (context, index) => _cardGarage(vehiculos[index], isDark),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cardGarage(Map<String, dynamic> v, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            v['id_tipo_vehiculo'] == 2 
                ? Icons.two_wheeler 
                : (v['id_tipo_vehiculo'] == 3 ? Icons.pedal_bike : Icons.directions_car),
            size: 75, 
            color: isDark ? AppColors.amarillo : AppColors.azul,
          ),
          const SizedBox(height: 15),
          Text(
            v['placa'], 
            style: TextStyle(
              fontSize: 32, 
              fontWeight: FontWeight.w900, 
              color: isDark ? Colors.white : Colors.black
            )
          ),
          const SizedBox(height: 5),
          Text(
            "${v['marca']} ${v['modelo']}".toUpperCase(), 
            style: const TextStyle(
              color: Colors.grey, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.1
            )
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btnAccion(Icons.edit_rounded, "Editar", Colors.blue, () => mostrarFormulario(v: v)),
              _btnAccion(Icons.delete_outline_rounded, "Eliminar", Colors.redAccent, () => eliminarVehiculo(v['id_vehiculo'])),
            ],
          )
        ],
      ),
    );
  }

  Widget _btnAccion(IconData icono, String texto, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icono, color: color, size: 18),
      label: Text(texto, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}