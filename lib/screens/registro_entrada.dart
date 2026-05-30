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
  bool mostrarFormulario = false;
  bool cargando = false;
  dynamic idVehiculoEncontrado; 
  dynamic idUsuarioEncontrado; 

  // --- LÓGICA DE BÚSQUEDA ---
  void verificarPlaca() async {
    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (placaLimpia.isEmpty) return;
    
    setState(() {
      cargando = true;
      mostrarFormulario = false;
    });
    
    try {
      // 1. Buscamos primero el vehículo
      final vehiculoRes = await supabase
          .from('vehiculos')
          .select('id_vehiculo, id_usuario') 
          .eq('placa', placaLimpia)
          .maybeSingle();

      if (vehiculoRes != null) {
        idVehiculoEncontrado = vehiculoRes['id_vehiculo'];
        idUsuarioEncontrado = vehiculoRes['id_usuario'];
        
        // 2. Buscamos el nombre del usuario en la tabla 'perfiles' por separado
        final perfilRes = await supabase
            .from('perfiles')
            .select('nombres')
            .eq('id', idUsuarioEncontrado)
            .maybeSingle();
            
        nombreCtrl.text = perfilRes?['nombres'] ?? "Sin nombre registrado";
      } else {
        nombreCtrl.clear();
        _showSnack("Placa no encontrada", Colors.orange);
      }

      setState(() {
        mostrarFormulario = (vehiculoRes != null);
        cargando = false;
      });
    } catch (e) {
      _showSnack("Error de conexión", Colors.red);
      setState(() => cargando = false);
    }
  }

  // --- REGISTRO DE ENTRADA ---
  void registrarEntrada() async {
    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (nombreCtrl.text.isEmpty) {
      _showSnack("Ingrese nombre del titular", Colors.orange);
      return;
    }

    setState(() => cargando = true);
    try {
      await supabase.from('tickets').insert({
        'id_vehiculo': idVehiculoEncontrado, 
        'id_usuario': idUsuarioEncontrado, 
        'fecha_hora_entrada': DateTime.now().toIso8601String(),
        'estado_ticket': 'activo',
        'metodo_ingreso': 'manual',
        'observaciones': 'PLACA: $placaLimpia | TITULAR: ${nombreCtrl.text} | TIPO: $tipoUsuario',
      });

      setState(() {
        placaCtrl.clear();
        nombreCtrl.clear();
        mostrarFormulario = false;
        cargando = false;
      });
      _showSnack("¡Entrada registrada con éxito!", Colors.green);
    } catch (e) {
      _showSnack("Error al guardar entrada", Colors.red);
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
        title: const Text("Entrada UCAD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputPlaca(isDark),
            const SizedBox(height: 25),
            if (cargando) const CircularProgressIndicator(color: AppColors.amarillo),
            if (mostrarFormulario && !cargando) _buildFormularioEntrada(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPlaca(bool isDark) {
    return Container(
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2C) : Colors.white, borderRadius: BorderRadius.circular(18)),
      child: TextField(
        controller: placaCtrl,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: "BUSCAR PLACA",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: verificarPlaca),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildFormularioEntrada(bool isDark) {
    return Column(
      children: [
        _buildTextField(nombreCtrl, "Nombre del Titular", Icons.person, isDark),
        const SizedBox(height: 12),
        _buildDropdown(["Estudiante", "Empleado", "Visitante"], tipoUsuario, (val) => setState(() => tipoUsuario = val!), isDark),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: registrarEntrada,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text("CONFIRMAR ENTRADA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, bool isDark) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(hintText: hint, filled: true, fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white, prefixIcon: Icon(icon, color: AppColors.amarillo), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged, bool isDark) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(filled: true, fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }
}