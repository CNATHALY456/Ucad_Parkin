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

  void verificarPlaca() async {
    if (placaCtrl.text.isEmpty) return;
    setState(() => cargando = true);
    
    try {
      final response = await supabase
          .from('tickets')
          .select()
          .eq('estado_ticket', 'activo')
          .ilike('observaciones', '%${placaCtrl.text.trim().toUpperCase()}%')
          .maybeSingle();

      setState(() {
        ticketActivo = response;
        mostrarFormulario = (response == null);
        cargando = false;
      });
    } catch (e) {
      _showSnack("Error al buscar: $e", Colors.red);
    }
  }

  void registrarEntrada() async {
    if (nombreCtrl.text.isEmpty) {
      _showSnack("Por favor ingrese el nombre del dueño", Colors.orange);
      return;
    }

    setState(() => cargando = true);
    try {
      final nuevaEntrada = await supabase.from('tickets').insert({
        'fecha_hora_entrada': DateTime.now().toIso8601String(),
        'estado_ticket': 'activo',
        'metodo_ingreso': 'manual',
        'observaciones': 'PLACA: ${placaCtrl.text.toUpperCase()} | DUEÑO: ${nombreCtrl.text} | TIPO: $tipoUsuario | VEHÍCULO: $tipoVehiculo',
      }).select().single();

      setState(() {
        ticketActivo = nuevaEntrada;
        mostrarFormulario = false;
        cargando = false;
      });
      _showSnack("Entrada registrada con éxito", Colors.green);
    } catch (e) {
      _showSnack("Error al registrar: $e", Colors.red);
    }
  }

  void registrarSalida() async {
    if (ticketActivo == null) return;
    try {
      await supabase.from('tickets').update({
        'estado_ticket': 'finalizado',
        'fecha_hora_salida': DateTime.now().toIso8601String(),
      }).eq('id', ticketActivo!['id']);

      setState(() {
        ticketActivo = null;
        placaCtrl.clear();
        nombreCtrl.clear();
      });
      _showSnack("Salida registrada correctamente", Colors.blue);
    } catch (e) {
      _showSnack("Error al actualizar: $e", Colors.red);
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
      // Fondo dinámico: Azul en light, Gris oscuro en dark
      backgroundColor: isDark ? theme.surface : AppColors.azul, 
      appBar: AppBar(
        title: const Text("Registro de Entrada"),
        backgroundColor: Colors.transparent, // Se adapta al fondo del scaffold
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputPlaca(theme, isDark),
            const SizedBox(height: 20),
            if (cargando) CircularProgressIndicator(color: AppColors.amarillo),
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
        borderRadius: BorderRadius.circular(15)
      ),
      child: TextField(
        controller: placaCtrl,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: "Ingrese Placa",
          hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
          prefixIcon: Icon(Icons.search, color: isDark ? AppColors.amarillo : AppColors.azul),
          suffixIcon: IconButton(
            icon: Icon(Icons.check_circle, color: AppColors.amarillo),
            onPressed: verificarPlaca,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildFormularioNuevo(ColorScheme theme, bool isDark) {
    return Column(
      children: [
        const Text("Vehículo no registrado. Complete los datos:", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 15),
        _buildTextField(nombreCtrl, "Nombre del Dueño", Icons.person, isDark),
        const SizedBox(height: 10),
        _buildDropdown(["Estudiante", "Empleado", "Visitante"], tipoUsuario, (val) => setState(() => tipoUsuario = val!), isDark),
        const SizedBox(height: 10),
        _buildDropdown(["carro", "moto", "bicicleta"], tipoVehiculo, (val) => setState(() => tipoVehiculo = val!), isDark),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: registrarEntrada,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
            child: const Text("REGISTRAR ENTRADA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketActivoCard(ColorScheme theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white, 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
          Icon(Icons.airplane_ticket, size: 50, color: isDark ? AppColors.amarillo : AppColors.azul),
          Text("TICKET ACTIVO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black)),
          const Divider(),
          Text(ticketActivo!['observaciones'], textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          Text("Entrada: ${ticketActivo!['fecha_hora_entrada']}", style: TextStyle(color: isDark ? Colors.white60 : Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: registrarSalida,
            icon: const Icon(Icons.exit_to_app),
            label: const Text("REGISTRAR SALIDA"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.amarillo : AppColors.azul, 
              foregroundColor: isDark ? Colors.black : Colors.white
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
        hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
        filled: true, 
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white, 
        prefixIcon: Icon(icon, color: isDark ? AppColors.amarillo : Colors.grey), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
      ),
    );
  }
}