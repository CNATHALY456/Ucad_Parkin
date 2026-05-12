import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart'; 
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:intl/intl.dart';

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
  bool mostrarFormulario = false;
  bool cargando = false;
  Map<String, dynamic>? ticketActivo;
  dynamic idVehiculoEncontrado; 
  dynamic idUsuarioEncontrado; 

  // --- LÓGICA DE BÚSQUEDA ---
  void verificarPlaca() async {
    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (placaLimpia.isEmpty) return;
    
    setState(() {
      cargando = true;
      idVehiculoEncontrado = null;
      idUsuarioEncontrado = null;
      ticketActivo = null;
      mostrarFormulario = false;
    });
    
    try {
      // Buscamos el vehículo y vinculamos al usuario dueño
      final vehiculoRes = await supabase
          .from('vehiculos')
          .select('id_vehiculo, id_usuario, marca, modelo') 
          .eq('placa', placaLimpia)
          .maybeSingle();

      if (vehiculoRes != null) {
        idVehiculoEncontrado = vehiculoRes['id_vehiculo'];
        idUsuarioEncontrado = vehiculoRes['id_usuario'];
      }

      // Buscamos si ya hay un ticket activo
      final query = supabase.from('tickets').select().eq('estado_ticket', 'activo');
      
      if (idVehiculoEncontrado != null) {
        query.eq('id_vehiculo', idVehiculoEncontrado);
      } else {
        query.ilike('observaciones', '%$placaLimpia%');
      }

      final ticketRes = await query.maybeSingle();

      setState(() {
        ticketActivo = ticketRes;
        mostrarFormulario = (ticketRes == null);
        
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

  // --- REGISTRO DE ENTRADA (LOCAL EL SALVADOR) ---
  void registrarEntrada() async {
    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (nombreCtrl.text.isEmpty) {
      _showSnack("Ingrese identificación del vehículo", Colors.orange);
      return;
    }

    setState(() => cargando = true);
    try {
      // Capturamos la hora exacta del dispositivo en El Salvador
      final DateTime ahoraLocal = DateTime.now();
      
      final nuevaEntrada = await supabase.from('tickets').insert({
        'id_vehiculo': idVehiculoEncontrado, 
        'id_usuario': idUsuarioEncontrado, 
        'fecha_hora_entrada': ahoraLocal.toIso8601String(), // Enviamos ISO local
        'estado_ticket': 'activo',
        'metodo_ingreso': 'manual',
        'observaciones': 'PLACA: $placaLimpia | INFO: ${nombreCtrl.text} | TIPO: $tipoUsuario',
      }).select().single();

      setState(() {
        ticketActivo = nuevaEntrada;
        mostrarFormulario = false;
        cargando = false;
      });
      _showSnack("Entrada registrada: ${DateFormat('hh:mm a').format(ahoraLocal)}", Colors.green);
    } catch (e) {
      _showSnack("Error al registrar: $e", Colors.red);
      setState(() => cargando = false);
    }
  }

  // --- REGISTRO DE SALIDA (LOCAL EL SALVADOR) ---
  void registrarSalida() async {
    if (ticketActivo == null) return;
    setState(() => cargando = true);
    try {
      final DateTime ahoraSalidaLocal = DateTime.now();

      await supabase.from('tickets').update({
        'estado_ticket': 'finalizado',
        'fecha_hora_salida': ahoraSalidaLocal.toIso8601String(),
      }).eq('id_ticket', ticketActivo!['id_ticket']); 

      setState(() {
        ticketActivo = null;
        placaCtrl.clear();
        nombreCtrl.clear();
        cargando = false;
      });
      _showSnack("Salida registrada: ${DateFormat('hh:mm a').format(ahoraSalidaLocal)}", Colors.blue);
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
            _buildInputPlaca(isDark),
            const SizedBox(height: 25),
            if (cargando) const CircularProgressIndicator(color: AppColors.amarillo),
            if (mostrarFormulario && !cargando) _buildFormularioNuevo(isDark),
            if (ticketActivo != null && !cargando) _buildTicketActivoCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPlaca(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white, 
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: placaCtrl,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: "BUSCAR PLACA",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
            onPressed: verificarPlaca,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildFormularioNuevo(bool isDark) {
    return Column(
      children: [
        _buildTextField(nombreCtrl, "Identificación / Descripción", Icons.directions_car, isDark),
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
            child: const Text("CONFIRMAR ENTRADA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketActivoCard(bool isDark) {
    // --- CONVERSIÓN A HORA LOCAL DE EL SALVADOR ---
    final DateTime fechaEntrada = DateTime.parse(ticketActivo!['fecha_hora_entrada']).toLocal();
    final String horaAMPM = DateFormat('hh:mm a').format(fechaEntrada);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green, width: 2)
      ),
      child: Column(
        children: [
          const Icon(Icons.timer_outlined, size: 60, color: Colors.green),
          const SizedBox(height: 10),
          const Text("ESTADO: ADENTRO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 30),
          Text(ticketActivo!['observaciones'], textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Text("Entrada Local: $horaAMPM", 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: registrarSalida,
              icon: const Icon(Icons.logout),
              label: const Text("REGISTRAR SALIDA"),
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