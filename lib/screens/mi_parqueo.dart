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
  dynamic idMiVehiculo; 
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
        // 1. Obtenemos la placa y el ID del vehículo vinculado al usuario
        final perfil = await supabase
            .from('perfiles')
            .select('placa_principal')
            .eq('id', user.id)
            .single();

        final vehiculo = await supabase
            .from('vehiculos')
            .select('id_vehiculo')
            .eq('id_usuario', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            miPlaca = perfil['placa_principal']?.toString().toUpperCase().trim();
            idMiVehiculo = vehiculo?['id_vehiculo'];
            cargandoPerfil = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo perfil: $e");
      if (mounted) setState(() => cargandoPerfil = false);
    }
  }

  void _iniciarReloj(DateTime entrada) {
    // Si ya hay un timer corriendo, lo cancelamos antes de crear uno nuevo para evitar duplicidad
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          tiempoTranscurrido = DateTime.now().difference(entrada);
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

    if (cargandoPerfil) {
      return const Center(child: CircularProgressIndicator(color: AppColors.amarillo));
    }

    if (miPlaca == null || miPlaca!.isEmpty) {
      return _buildVistaSinPlaca(isDark);
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      // ESCUCHA ACTIVA: Solo tickets que sigan marcados como 'activo'
      stream: supabase
          .from('tickets')
          .stream(primaryKey: ['id_ticket'])
          .eq('estado_ticket', 'activo')
          .order('fecha_hora_entrada', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error al conectar con el servidor"));
        
        final todosLosTickets = snapshot.data ?? [];

        // Filtramos para encontrar el ticket que pertenece a este usuario
        Map<String, dynamic> miTicketActivo = {};
        
        try {
          miTicketActivo = todosLosTickets.firstWhere(
            (t) {
              final idEnTicket = t['id_vehiculo']?.toString();
              final miIdString = idMiVehiculo?.toString();
              final obs = t['observaciones']?.toString().toUpperCase() ?? "";
              
              // Coincidencia por ID de vehículo o por Placa en observaciones
              return (miIdString != null && idEnTicket == miIdString) || 
                     (obs.contains(miPlaca!));
            },
            orElse: () => {},
          );
        } catch (e) {
          miTicketActivo = {};
        }

        // Si no hay ticket activo (porque se cerró o no ha entrado), limpiamos reloj y mostramos vacío
        if (miTicketActivo.isEmpty) {
          timer?.cancel();
          timer = null;
          return _buildVistaVacia(isDark);
        }

        // Si hay ticket, iniciamos o mantenemos el reloj
        final DateTime entrada = DateTime.parse(miTicketActivo['fecha_hora_entrada']).toLocal();
        if (timer == null || !timer!.isActive) {
          _iniciarReloj(entrada);
        }

        // Cálculo de cobro estimado
        double horas = tiempoTranscurrido.inSeconds / 3600;
        if (horas < 0) horas = 0;
        double montoActual = horas * tarifaPorHora;

        return _buildVistaActiva(isDark, miTicketActivo, montoActual);
      },
    );
  }

  Widget _buildVistaSinPlaca(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text(
          "Registra tu placa en 'Mi Vehículo' para monitorear tu tiempo.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }

  Widget _buildVistaVacia(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons. beach_access_outlined, size: 80, color: AppColors.amarillo),
          const SizedBox(height: 20),
          const Text("SIN ACTIVIDAD", 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.amarillo)),
          const SizedBox(height: 10),
          Text("Placa vinculada: $miPlaca", 
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text("No tienes un ticket de parqueo activo en este momento.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildVistaActiva(bool isDark, Map<String, dynamic> ticket, double monto) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // CABECERA DEL CRONÓMETRO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.azul,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [if(!isDark) const BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))]
            ),
            child: Column(
              children: [
                const Icon(Icons.timer, size: 50, color: AppColors.amarillo),
                const SizedBox(height: 15),
                Text(
                  "${tiempoTranscurrido.inHours.toString().padLeft(2, '0')}:${(tiempoTranscurrido.inMinutes % 60).toString().padLeft(2, '0')}:${(tiempoTranscurrido.inSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    color: AppColors.amarillo, 
                    fontSize: 55, 
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'monospace'
                  ),
                ),
                const Text("TIEMPO EN PARQUEO", 
                  style: TextStyle(color: Colors.white70, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          
          // TARJETA DE COSTO
          Card(
            elevation: 0,
            color: isDark ? Colors.white10 : Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.attach_money, color: Colors.white),
              ),
              title: const Text("Cobro Estimado", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Tarifa: \$${tarifaPorHora.toStringAsFixed(2)} / hora"),
              trailing: Text(
                "\$${monto.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ),

          const SizedBox(height: 20),
          
          // DETALLES ADICIONALES
          _buildInfoRow(Icons.login, "Entrada", DateFormat('hh:mm a').format(DateTime.parse(ticket['fecha_hora_entrada']).toLocal())),
          _rowSimple("Fecha:", DateFormat('dd/MM/yyyy').format(DateTime.parse(ticket['fecha_hora_entrada']).toLocal()), isDark),
          _rowSimple("Placa Detectada:", miPlaca ?? "N/A", isDark),
          
          const Divider(height: 40),
          
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey),
              SizedBox(width: 5),
              Text("El tiempo se detendrá cuando el vigilante registre tu salida.", 
                style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.amarillo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.amarillo),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _rowSimple(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}