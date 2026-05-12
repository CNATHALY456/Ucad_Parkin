import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RegistroSalida extends StatefulWidget {
  const RegistroSalida({super.key});

  @override
  _RegistroSalidaState createState() => _RegistroSalidaState();
}

class _RegistroSalidaState extends State<RegistroSalida> {
  final supabase = Supabase.instance.client;
  TextEditingController placaCtrl = TextEditingController();
  Map<String, dynamic>? ticketFinalizado;
  bool procesando = false;

  void procesarSalida() async {
    final placaLimpia = placaCtrl.text.trim().toUpperCase();
    if (placaLimpia.isEmpty) {
      _showSnackBar("Por favor, ingrese una placa", Colors.orange);
      return;
    }

    setState(() {
      procesando = true;
      ticketFinalizado = null;
    });

    try {
      // 1. BUSQUEDA: Solo tickets activos que coincidan con la placa en observaciones o ID
      final ticketActivo = await supabase
          .from('tickets')
          .select()
          .eq('estado_ticket', 'activo')
          .ilike('observaciones', '%$placaLimpia%')
          .maybeSingle();

      if (ticketActivo != null) {
        final idTicket = ticketActivo['id_ticket'];
        
        // --- CAPTURA DE HORA LOCAL (EL SALVADOR) ---
        final DateTime ahoraSalida = DateTime.now();

        // 2. ACTUALIZACIÓN: Cambiamos estado y grabamos hora local
        await supabase
            .from('tickets')
            .update({
              'fecha_hora_salida': ahoraSalida.toIso8601String(),
              'estado_ticket': 'finalizado',
              'metodo_salida': 'manual'
            })
            .match({'id_ticket': idTicket});

        // 3. VERIFICACIÓN Y RESUMEN
        setState(() {
          ticketFinalizado = {
            'placa': placaLimpia,
            'entrada': ticketActivo['fecha_hora_entrada'], // Viene de DB (se convertirá en el widget)
            'salida': ahoraSalida.toIso8601String(),
          };
          procesando = false;
        });
        
        placaCtrl.clear();
        _showSnackBar("✅ Salida registrada a las ${DateFormat('hh:mm a').format(ahoraSalida)}", Colors.green);
      } else {
        setState(() => procesando = false);
        _showSnackBar("⚠️ No hay tickets ACTIVOS para: $placaLimpia", Colors.orange);
      }
    } catch (e) {
      setState(() => procesando = false);
      debugPrint("Error crítico en salida: $e");
      _showSnackBar("❌ Error al guardar. Verifica conexión o políticas RLS", Colors.red);
    }
  }

  // --- FORMATEADOR DE FECHA CON CONVERSIÓN LOCAL ---
  String _formatDate(String dateStr) {
    try {
      // DateTime.parse lee el string de Supabase y .toLocal() lo pasa a hora de El Salvador
      final DateTime fecha = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a').format(fecha);
    } catch (e) {
      return dateStr;
    }
  }

  void _showSnackBar(String m, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: const TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: color, 
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.azul,
      appBar: AppBar(
        title: const Text("Registrar Salida", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            _buildBotonSalida(isDark),
            if (ticketFinalizado != null) _buildResumen(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPlaca(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [if(!isDark) const BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: TextField(
        controller: placaCtrl,
        textCapitalization: TextCapitalization.characters,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: "PLACA DEL VEHÍCULO",
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          prefixIcon: Icon(Icons.directions_car, color: isDark ? AppColors.amarillo : Colors.redAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildBotonSalida(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: procesando ? null : procesarSalida,
        icon: procesando ? const SizedBox() : const Icon(Icons.logout),
        label: procesando 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("MARCAR SALIDA AHORA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildResumen(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 15),
          const Text("SALIDA EXITOSA", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
          const Divider(height: 30),
          _row("Vehículo", ticketFinalizado!['placa'], isDark),
          _row("H. Entrada", _formatDate(ticketFinalizado!['entrada']), isDark),
          _row("H. Salida", _formatDate(ticketFinalizado!['salida']), isDark),
          const SizedBox(height: 15),
          const Text("Sistema actualizado: Espacio libre", 
            style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _row(String label, String valor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Text(valor, style: TextStyle(
            color: isDark ? Colors.white : Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: 16
          )),
        ],
      ),
    );
  }
}