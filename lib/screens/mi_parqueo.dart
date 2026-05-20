import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:intl/intl.dart';

class MiParqueo extends StatefulWidget {
  const MiParqueo({super.key});

  @override
  State<MiParqueo> createState() => _MiParqueoState();
}

class _MiParqueoState extends State<MiParqueo> {
  final supabase = Supabase.instance.client;
  String? miPlaca;
  Timer? timer;
  Duration tiempoTranscurrido = Duration.zero;
  bool cargandoPerfil = true;
  double tarifaPorHora = 0.50;

  @override
  void initState() {
    super.initState();
    _obtenerDatosUsuario();
  }

  Future<void> _obtenerDatosUsuario() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final perfil = await supabase
            .from('perfiles')
            .select('placa_principal')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            miPlaca = perfil['placa_principal']?.toString().toUpperCase().trim();
            cargandoPerfil = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => cargandoPerfil = false);
    }
  }

  void _iniciarReloj(DateTime entradaLocal) {
    timer?.cancel();
    if (mounted) {
      setState(() {
        tiempoTranscurrido = DateTime.now().difference(entradaLocal);
      });
    }
    
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          tiempoTranscurrido = DateTime.now().difference(entradaLocal);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (cargandoPerfil) return const Center(child: CircularProgressIndicator(color: AppColors.amarillo));
    if (miPlaca == null || miPlaca!.isEmpty) return _buildVistaSinPlaca(isDark);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('tickets')
          .stream(primaryKey: ['id_ticket'])
          .eq('id_usuario', supabase.auth.currentUser!.id)
          .order('fecha_hora_entrada', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = snapshot.data ?? [];
        Map<String, dynamic> miTicketActivo;

        try {
          miTicketActivo = tickets.firstWhere(
            (t) => t['estado_ticket'] == 'activo' && t['fecha_hora_salida'] == null,
            orElse: () => {},
          );
        } catch (e) {
          miTicketActivo = {};
        }

        if (miTicketActivo.isEmpty) {
          if (timer != null) {
            timer?.cancel();
            timer = null;
          }
          return _buildVistaVacia(isDark);
        }

        final DateTime entrada = DateTime.parse(miTicketActivo['fecha_hora_entrada']).toLocal();

        // 🔥 CORRECCIÓN PARA EL ERROR SETSTATE DURING BUILD
        if (timer == null || !timer!.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _iniciarReloj(entrada);
          });
        }

        double horasDecimales = tiempoTranscurrido.inSeconds / 3600;
        double montoActual = (horasDecimales < 0 ? 0 : horasDecimales) * tarifaPorHora;

        return _buildVistaActiva(isDark, miTicketActivo, entrada, montoActual);
      },
    );
  }

  // --- VISTA SIN PLACA ---
  Widget _buildVistaSinPlaca(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              // ✅ CORRECCIÓN withValues
              color: isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : AppColors.azul.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.no_crash_rounded, size: 80, color: isDark ? AppColors.amarillo : AppColors.azul),
          ),
          const SizedBox(height: 30),
          const Text("SIN PLACA VINCULADA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 15),
          Text(
            "Vincula tu vehículo principal en la sección de 'Mi Vehículo' para monitorear tu estancia en UCAD Parki.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }

  // --- VISTA ESTACIONAMIENTO LIBRE ---
  Widget _buildVistaVacia(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 100, color: Colors.greenAccent[400]),
          const SizedBox(height: 25),
          const Text("TODO EN ORDEN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            // ✅ CORRECCIÓN withValues
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(miPlaca ?? "SIN PLACA", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.all(40),
            child: Text("No detectamos tu vehículo en el parqueo. ¡Tu cuenta está libre de cargos activos!", 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // --- VISTA ACTIVA (TICKET EN CURSO) ---
  Widget _buildVistaActiva(bool isDark, Map<String, dynamic> ticket, DateTime entradaLocal, double monto) {
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    final horas = dosDigitos(tiempoTranscurrido.inHours);
    final minutos = dosDigitos(tiempoTranscurrido.inMinutes.remainder(60));
    final segundos = dosDigitos(tiempoTranscurrido.inSeconds.remainder(60));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // HEADER CON CRONÓMETRO
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? [const Color(0xFF1E1E1E), const Color(0xFF121212)] : [AppColors.azul, const Color(0xFF0D47A1)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              // ✅ CORRECCIÓN withValues en Shadow
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  // ✅ CORRECCIÓN withValues
                  decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
                      const SizedBox(width: 8),
                      Text("EN CURSO", style: TextStyle(color: Colors.redAccent[100], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "$horas:$minutos:$segundos",
                  style: TextStyle(
                    color: isDark ? AppColors.amarillo : Colors.white, 
                    fontSize: 65, 
                    fontWeight: FontWeight.w900, 
                    fontFamily: 'monospace',
                    letterSpacing: -2
                  ),
                ),
                Text("TIEMPO ESTACIONADO", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // SECCIÓN DE COSTO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                // ✅ CORRECCIÓN withValues y nulabilidad
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50]?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200] ?? Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("COSTO ACTUAL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 5),
                      Text("\$${monto.toStringAsFixed(2)}", style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.green)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("TARIFA", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
                      Text("\$${tarifaPorHora.toStringAsFixed(2)}/hr", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // DETALLES DE ENTRADA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                _buildDetalle(Icons.login_rounded, "Ingreso", DateFormat('hh:mm a').format(entradaLocal), isDark),
                const SizedBox(height: 20),
                _buildDetalle(Icons.calendar_month_rounded, "Fecha", DateFormat('dd MMM, yyyy').format(entradaLocal), isDark),
                const SizedBox(height: 20),
                _buildDetalle(Icons.pin_drop_rounded, "Ubicación", "UCAD El Salvador", isDark),
              ],
            ),
          ),

          const SizedBox(height: 40),
          
          // NOTA AL PIE
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "El monto mostrado es una estimación. El total exacto se calculará al salir.",
                    style: TextStyle(color: isDark ? Colors.amber[100] : Colors.amber[900], fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDetalle(IconData icon, String titulo, String valor, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : AppColors.azul.withValues(alpha: 0.05), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(icon, color: isDark ? AppColors.amarillo : AppColors.azul, size: 20),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}