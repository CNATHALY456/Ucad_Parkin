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

  // --- MÉTODOS DE EXTRACCIÓN DE METADATA PARA EL MODAL DETALLADO ---
  String extraerPlaca(String? observaciones) {
    if (observaciones == null || observaciones.isEmpty) return "SIN PLACA";
    if (observaciones.contains('|') || observaciones.contains('PLACA:')) {
      try {
        String primeraParte = observaciones.split('|')[0];
        return primeraParte.replaceAll('PLACA:', '').trim().toUpperCase();
      } catch (e) {
        return observaciones.toUpperCase();
      }
    }
    return observaciones.toUpperCase();
  }

  String extraerNombre(String? observaciones) {
    if (observaciones == null || !observaciones.contains('INFO:')) return "N/A";
    try {
      final partes = observaciones.split('|');
      for (var parte in partes) {
        if (parte.contains('INFO:')) {
          return parte.replaceAll('INFO:', '').trim().toUpperCase();
        }
      }
    } catch (_) {}
    return "N/A";
  }

  String extraerTipoUsuario(String? observaciones) {
    if (observaciones == null || !observaciones.contains('TIPO:')) return "ESTUDIANTE";
    try {
      final partes = observaciones.split('|');
      for (var parte in partes) {
        if (parte.contains('TIPO:')) {
          return parte.replaceAll('TIPO:', '').trim().toUpperCase();
        }
      }
    } catch (_) {}
    return "ESTUDIANTE";
  }

  // --- DETALLE DEL TICKET (BOTTOM SHEET AL DAR TAP) ---
  void mostrarTicket(Map<String, dynamic> t, bool isDark) {
    final entrada = DateTime.parse(t['fecha_hora_entrada']).toLocal();
    final salida = t['fecha_hora_salida'] != null 
        ? DateTime.parse(t['fecha_hora_salida']).toLocal() 
        : DateTime.now().toLocal();
    final duracion = salida.difference(entrada).abs(); 
    final monto = (duracion.inMinutes / 60) * tarifaPorHora;

    final String observacionesRaw = t['observaciones']?.toString() ?? "";
    final String placa = extraerPlaca(observacionesRaw);
    final String nombre = extraerNombre(observacionesRaw);
    final String tipo = extraerTipoUsuario(observacionesRaw);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 15, 24, MediaQuery.of(context).padding.bottom + 30), 
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : const Color(0xFFFBFBFB),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 30),
            
            const Text("PAGO TOTAL", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 5),
            Text("\$${monto.toStringAsFixed(2)}", 
              style: TextStyle(color: isDark ? AppColors.amarillo : AppColors.azul, fontSize: 48, fontWeight: FontWeight.w900)),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]
              ),
              child: Column(
                children: [
                  _datoSimple(Icons.directions_car_filled_rounded, "PLACA", placa, isDark),
                  const Divider(height: 30, thickness: 0.6),
                  
                  _datoSimple(Icons.person_rounded, "PROPIETARIO", nombre, isDark),
                  const Divider(height: 30, thickness: 0.6),
                  
                  _datoSimple(Icons.badge_rounded, "TIPO USUARIO", tipo, isDark),
                  const Divider(height: 30, thickness: 0.6),
                  
                  _datoSimple(Icons.timer_rounded, "TIEMPO TOTAL", "${duracion.inHours}h ${duracion.inMinutes % 60}m", isDark),
                  const Divider(height: 30, thickness: 0.6),
                  
                  _datoSimple(Icons.calendar_today_rounded, "FECHA ENTRADA", DateFormat('dd MMM yyyy - hh:mm a').format(entrada), isDark),
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
        Icon(icono, color: isDark ? AppColors.amarillo.withOpacity(0.8) : AppColors.azul.withOpacity(0.8), size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 95, 
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        Expanded(
          child: Text(
            valor, 
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w900, fontSize: 13.5),
          ),
        ),
      ],
    );
  }

  // --- TARJETA DE TICKET CORREGIDA EXACTAMENTE COMO LA REFERENCIA ---
  Widget cardTicket(Map<String, dynamic> t, bool isDark) {
    final entrada = DateTime.parse(t['fecha_hora_entrada']).toLocal();
    final duracion = t['fecha_hora_salida'] != null 
        ? DateTime.parse(t['fecha_hora_salida']).toLocal().difference(entrada).abs() : Duration.zero;
    final monto = (duracion.inMinutes / 60) * tarifaPorHora;

    // Adaptación cromática oficial
    final Color ticketBgColor = isDark ? AppColors.azul.withOpacity(0.85) : AppColors.azul;
    final Color badgeBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final String ticketId = t['id_ticket']?.toString() ?? 'N/A';

    return GestureDetector(
      onTap: () => mostrarTicket(t, isDark),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 110, // Dimensión proporcional calcada del mockup
        child: Row(
          children: [
            // PARTE IZQUIERDA: Bloque Principal Información (Azul)
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: ticketBgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TICKET #$ticketId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CANCELADO: \$${monto.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amarillo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 4), // Separador central milimétrico limpio

            // PARTE DERECHA: Bloque de Fecha Troquelado (Blanco / Dark)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM').format(entrada).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      DateFormat('dd').format(entrada),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.azul,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'UCAD PARKI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
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
        // Título superior estilizado e integrado
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 15, 24, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "HISTORIAL", 
                style: TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.w900, 
                  color: isDark ? Colors.white : AppColors.azul, 
                  letterSpacing: 1.2
                ),
              ),
              Text(
                "Tus últimos tickets finalizados", 
                style: TextStyle(color: Colors.grey[500], fontSize: 13)
              ),
            ],
          ),
        ),
        
        // Render dinámico en tiempo real desde Supabase
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('tickets')
                .stream(primaryKey: ['id_ticket'])
                .order('fecha_hora_salida', ascending: false),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              // Filtro reactivo por ID de usuario y tickets procesados con éxito
              final data = snapshot.data!
                  .where((t) => t['id_usuario'] == user?.id && t['estado_ticket'] == 'finalizado')
                  .toList();
              
              if (data.isEmpty) {
                return const Center(
                  child: Text("Sin registros en el historial", style: TextStyle(color: Colors.grey))
                );
              }

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