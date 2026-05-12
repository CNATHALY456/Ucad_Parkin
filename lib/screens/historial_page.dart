import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:intl/intl.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final supabase = Supabase.instance.client;
  final double tarifaPorHora = 0.50;

  // --- DETALLE DEL TICKET (ANCHO COMPACTO) ---
  void mostrarTicket(Map<String, dynamic> t, bool isDark) {
    final entrada = DateTime.parse(t['fecha_hora_entrada']).toLocal();
    final salida = t['fecha_hora_salida'] != null 
        ? DateTime.parse(t['fecha_hora_salida']).toLocal() 
        : DateTime.now().toLocal();
    final duracion = salida.difference(entrada).abs(); 
    final monto = (duracion.inMinutes / 60) * tarifaPorHora;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        // Padding lateral grande (40) para que el contenido se vea centrado y no "pegado"
        padding: const EdgeInsets.fromLTRB(40, 15, 40, 50), 
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : const Color(0xFFFBFBFB),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 40),
            
            const Text("PAGO TOTAL", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
            Text("\$${monto.toStringAsFixed(2)}", 
              style: TextStyle(color: isDark ? AppColors.amarillo : AppColors.azul, fontSize: 52, fontWeight: FontWeight.w900)),
            const SizedBox(height: 35),

            // TARJETA INTERNA DEL MODAL
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]
              ),
              child: Column(
                children: [
                  _datoSimple(Icons.directions_car_filled_rounded, "PLACA", t['observaciones']?.toString().toUpperCase() ?? "N/A", isDark),
                  const Divider(height: 35, thickness: 0.5),
                  _datoSimple(Icons.timer_rounded, "TIEMPO", "${duracion.inHours}h ${duracion.inMinutes % 60}m", isDark),
                  const Divider(height: 35, thickness: 0.5),
                  _datoSimple(Icons.calendar_today_rounded, "FECHA", DateFormat('dd MMM, yyyy').format(entrada), isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datoSimple(IconData icono, String label, String valor, bool isDark) {
    return Row(
      children: [
        Icon(icono, color: Colors.grey[400], size: 18),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const Spacer(),
        Flexible(
          child: Text(valor, 
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w900, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- TARJETA DE LISTA (CON MÁRGENES LATERALES) ---
  Widget cardTicket(Map<String, dynamic> t, bool isDark) {
    final entrada = DateTime.parse(t['fecha_hora_entrada']).toLocal();
    final duracion = t['fecha_hora_salida'] != null 
        ? DateTime.parse(t['fecha_hora_salida']).toLocal().difference(entrada).abs() : Duration.zero;
    final monto = (duracion.inMinutes / 60) * tarifaPorHora;

    return GestureDetector(
      onTap: () => mostrarTicket(t, isDark),
      child: Container(
        // Margen horizontal de 25 para que se vea como un "ticket" flotante
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), 
        height: 105,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            // Indicador de color sólido al inicio
            Container(
              width: 10,
              decoration: BoxDecoration(
                color: isDark ? AppColors.amarillo : AppColors.azul,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), bottomLeft: Radius.circular(28)),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('EEEE, dd MMMM').format(entrada).toUpperCase(), 
                    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(t['observaciones']?.toString().toUpperCase() ?? "S/P", 
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Text("\$${monto.toStringAsFixed(2)}", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? AppColors.amarillo : AppColors.azul)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final user = supabase.auth.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título alineado con el inicio de las tarjetas
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("HISTORIAL", 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.azul, letterSpacing: 1.5)),
              Text("Tus últimos tickets finalizados", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ],
          ),
        ),
        
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('tickets').stream(primaryKey: ['id_ticket']).order('fecha_hora_salida', ascending: false),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final data = snapshot.data!.where((t) => t['id_usuario'] == user?.id && t['estado_ticket'] == 'finalizado').toList();
              
              if (data.isEmpty) return const Center(child: Text("Sin registros", style: TextStyle(color: Colors.grey)));

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) => cardTicket(data[index], isDark),
              );
            },
          ),
        ),
      ],
    );
  }
}