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

  // --- FUNCIÓN PARA EXTRAER EXCLUSIVAMENTE LA PLACA ---
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

  // --- FUNCIÓN PARA EXTRAER EL NOMBRE DEL PROPIETARIO ---
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

  // --- FUNCIÓN PARA EXTRAER EL TIPO DE USUARIO ---
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

  // --- DETALLE DEL TICKET (MODAL FLOTANTE OPTIMIZADO) ---
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

            // TARJETA INTERNA DE DATOS (CON ESPACIO HORIZONTAL AMPLIADO)
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
                  
                  _datoSimple(Icons.badge_rounded, "TIPO", tipo, isDark),
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

  // --- FILA DE DATOS CON CONTROL FLEXIBLE PARA EVITAR CORTES ---
  Widget _datoSimple(IconData icono, String label, String valor, bool isDark) {
    return Row(
      children: [
        Icon(icono, color: isDark ? AppColors.amarillo.withOpacity(0.8) : AppColors.azul.withOpacity(0.8), size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 95, 
          child: Text(
            label, 
            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
          ),
        ),
        Expanded(
          child: Text(
            valor, 
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87, 
              fontWeight: FontWeight.w900, 
              fontSize: 13.5
            ),
          ),
        ),
      ],
    );
  }

  // --- TARJETA DE LA LISTA PRINCIPAL (ESTILO BOLETO PREMIUM) ---
  Widget cardTicket(Map<String, dynamic> t, bool isDark) {
    final entrada = DateTime.parse(t['fecha_hora_entrada']).toLocal();
    final duracion = t['fecha_hora_salida'] != null 
        ? DateTime.parse(t['fecha_hora_salida']).toLocal().difference(entrada).abs() : Duration.zero;
    final monto = (duracion.inMinutes / 60) * tarifaPorHora;

    final Color ticketBgColor = isDark ? AppColors.azul.withOpacity(0.8) : AppColors.azul;
    final Color badgeBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final String placaLimpia = extraerPlaca(t['observaciones']?.toString());

    return GestureDetector(
      onTap: () => mostrarTicket(t, isDark),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 115, 
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            // CUERPO DEL TICKET (PARTE IZQUIERDA CON RECORTE)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(right: 80), 
                child: ClipPath(
                  clipper: TicketClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ticketBgColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 14), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_parking_rounded, color: AppColors.amarillo, size: 11),
                              const SizedBox(width: 4),
                              const Text(
                                "UCAD PARKI",
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              placaLimpia, 
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Tiempo: ${duracion.inHours}h ${duracion.inMinutes % 60}m",
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BADGE FLOTANTE (PARTE DERECHA CON FECHA Y MONTO)
            Positioned(
              right: 0, 
              child: Container(
                width: 92,
                height: 98, 
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM').format(entrada).toUpperCase(),
                      style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    Text(
                      DateFormat('dd').format(entrada),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, height: 1.1),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "\$${monto.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isDark ? AppColors.amarillo : AppColors.azul),
                    ),
                  ],
                ),
              ),
            )
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

// CLIPPER ENCARGADO DEL EFECTO SEMICIRCULAR DE ENCAJE
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double holeRadius = 12; 
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.arcToPoint(Offset(size.width, holeRadius * 2), radius: Radius.circular(holeRadius), clockwise: false);
    path.lineTo(size.width, size.height - (holeRadius * 2));
    path.arcToPoint(Offset(size.width, size.height), radius: Radius.circular(holeRadius), clockwise: false);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}