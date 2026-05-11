import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart'; 
import 'package:ucad_parki/utils/app_colors.dart';

class RegistrarEntrada extends StatefulWidget {
  const RegistrarEntrada({super.key});

  @override
  _RegistrarEntradaState createState() => _RegistrarEntradaState();
}

class _RegistrarEntradaState extends State<RegistrarEntrada> {
  final supabase = Supabase.instance.client;
  TextEditingController placaCtrl = TextEditingController();
  TextEditingController nombreCtrl = TextEditingController();

  String tipoUsuario = "Estudiante";
  String tipoVehiculo = "carro";
  bool mostrarFormulario = false;
  bool cargando = false;
  Map<String, dynamic>? ticketActivo;
  dynamic idVehiculoEncontrado; // Cambiado a dynamic para manejar UUID o Int

  void verificarPlaca() async {
    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (placaLimpia.isEmpty) return;
    
    setState(() {
      cargando = true;
      idVehiculoEncontrado = null;
      ticketActivo = null;
      mostrarFormulario = false;
    });
    
    try {
      // 1. CORRECCIÓN: Buscamos usando 'id_vehiculo' (nombre real en tu DB)
      // También traemos la marca y modelo para mostrar información útil
      final vehiculoRes = await supabase
          .from('vehiculos')
          .select('id_vehiculo, marca, modelo') 
          .eq('placa', placaLimpia)
          .maybeSingle();

      if (vehiculoRes != null) {
        idVehiculoEncontrado = vehiculoRes['id_vehiculo'];
      }

      // 2. Buscamos si ya hay un ticket activo
      // Filtramos por id_vehiculo si lo tenemos, o por placa en observaciones si es manual
      final query = supabase.from('tickets').select().eq('estado_ticket', 'activo');
      
      if (idVehiculoEncontrado != null) {
        query.eq('id_vehiculo', idVehiculoEncontrado);
      } else {
        query.ilike('observaciones', '%$placaLimpia%');
      }

      final ticketRes = await query.maybeSingle();

      setState(() {
        ticketActivo = ticketRes;
        // Si no hay ticket activo, mostramos formulario
        mostrarFormulario = (ticketRes == null);
        
        // Si el vehículo existe, rellenamos con la info de la DB
        if (vehiculoRes != null && mostrarFormulario) {
          nombreCtrl.text = "${vehiculoRes['marca']} ${vehiculoRes['modelo']}";
        } else if (mostrarFormulario) {
          nombreCtrl.clear();
        }
        cargando = false;
      });
    } catch (e) {
      _showSnack("Error al buscar: $e", Colors.red);
      setState(() => cargando = false);
    }
  }

  void registrarEntrada() async {
    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (nombreCtrl.text.isEmpty) {
      _showSnack("Ingrese identificación del vehículo/dueño", Colors.orange);
      return;
    }

    setState(() => cargando = true);
    try {
      // Insertamos el ticket vinculando el ID real del vehículo
      final nuevaEntrada = await supabase.from('tickets').insert({
        'id_vehiculo': idVehiculoEncontrado, 
        'fecha_hora_entrada': DateTime.now().toIso8601String(),
        'estado_ticket': 'activo',
        'metodo_ingreso': 'manual',
        'observaciones': 'PLACA: $placaLimpia | INFO: ${nombreCtrl.text} | TIPO: $tipoUsuario',
      }).select().single();

      setState(() {
        ticketActivo = nuevaEntrada;
        mostrarFormulario = false;
        cargando = false;
      });
      _showSnack("Entrada registrada con éxito", Colors.green);
    } catch (e) {
      _showSnack("Error al registrar: $e", Colors.red);
      setState(() => cargando = false);
    }
  }

  void registrarSalida() async {
    if (ticketActivo == null) return;
    setState(() => cargando = true);
    try {
      // CORRECCIÓN: Aseguramos que use id_ticket como llave primaria
      await supabase.from('tickets').update({
        'estado_ticket': 'finalizado',
        'fecha_hora_salida': DateTime.now().toIso8601String(),
      }).eq('id_ticket', ticketActivo!['id_ticket']); 

      setState(() {
        ticketActivo = null;
        placaCtrl.clear();
        nombreCtrl.clear();
        cargando = false;
      });
      _showSnack("Salida registrada correctamente", Colors.blue);
    } catch (e) {
      _showSnack("Error al actualizar: $e", Colors.red);
      setState(() => cargando = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.azul, 
      appBar: AppBar(
        title: const Text("Vigilancia - UCAD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputPlaca(theme, isDark),
            const SizedBox(height: 25),
            if (cargando) const CircularProgressIndicator(color: AppColors.amarillo),
            if (mostrarFormulario && !cargando) _buildFormularioNuevo(theme, isDark),
            if (ticketActivo != null && !cargando) _buildTicketActivoCard(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPlaca(ColorScheme theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white, 
        borderRadius: BorderRadius.circular(18),
        boxShadow: [if(!isDark) const BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: TextField(
        controller: placaCtrl,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        decoration: InputDecoration(
          hintText: "PLACA DEL VEHÍCULO",
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          prefixIcon: Icon(Icons.search, color: isDark ? AppColors.amarillo : AppColors.azul),
          suffixIcon: IconButton(
            icon: Icon(Icons.check_circle, color: AppColors.amarillo, size: 30),
            onPressed: verificarPlaca,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildFormularioNuevo(ColorScheme theme, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(child: Text("Vehículo detectado. Confirme los datos:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(nombreCtrl, "Dueño o Descripción", Icons.person, isDark),
        const SizedBox(height: 12),
        _buildDropdown(["Estudiante", "Empleado", "Visitante"], tipoUsuario, (val) => setState(() => tipoUsuario = val!), isDark),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: registrarEntrada,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, 
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
            child: const Text("REGISTRAR ENTRADA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketActivoCard(ColorScheme theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.amarillo, width: 2)
      ),
      child: Column(
        children: [
          const Icon(Icons.timer, size: 60, color: Colors.green),
          const SizedBox(height: 10),
          Text("TIEMPO EN CURSO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDark ? Colors.white : Colors.black)),
          const Divider(height: 30),
          Text(ticketActivo!['observaciones'], textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text("Entrada: ${ticketActivo!['fecha_hora_entrada'].toString().substring(11, 16)}", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: registrarSalida,
              icon: const Icon(Icons.logout),
              label: const Text("REGISTRAR SALIDA", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, bool isDark) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint, 
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
        filled: true, 
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white, 
        prefixIcon: Icon(icon, color: AppColors.amarillo), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged, bool isDark) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true, 
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
    );
  }
}