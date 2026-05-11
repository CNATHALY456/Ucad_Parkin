import 'package:flutter/material.dart';
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

  // 🎟️ DETALLE TICKET (Modal Estilo Recibo)
  void mostrarTicket(Map<String, dynamic> t) {
    final entrada = DateTime.parse(t['fecha_hora_entrada']).toLocal();
    final salida = t['fecha_hora_salida'] != null 
        ? DateTime.parse(t['fecha_hora_salida']).toLocal() 
        : DateTime.now();
    final duracion = salida.difference(entrada);
    final monto = (duracion.inMinutes / 60) * tarifaPorHora;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60, height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, 
                    borderRadius: BorderRadius.circular(20)
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Universidad Cristiana\nde las Asambleas de Dios",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.azul, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "RECIBO DE PARQUEO\n(UCAD PARKI)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.amarillo, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.azul, borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    children: [
                      const Icon(Icons.confirmation_number, color: AppColors.amarillo, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        "ID-TICKET #${t['id_ticket']}",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _infoItem("Fecha", DateFormat('dd/MM/yyyy').format(entrada)),
                _infoItem("Hora entrada", DateFormat('hh:mm a').format(entrada)),
                _infoItem("Hora salida", DateFormat('hh:mm a').format(salida)),
                _infoItem("Tiempo total", "${duracion.inHours}h ${duracion.inMinutes % 60}m"),
                _infoItem("Monto Pagado", "\$${monto.toStringAsFixed(2)}"),
                _infoItem("Placa", t['observaciones']?.toString().toUpperCase() ?? "N/A"),

                const SizedBox(height: 25),
                const Text("Estudiante UCAD", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem(String titulo, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          Text(valor, style: TextStyle(color: AppColors.azul, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget cardTicket(Map<String, dynamic> t) {
    final entrada = DateTime.parse(t['fecha_hora_entrada']).toLocal();
    
    return GestureDetector(
      onTap: () => mostrarTicket(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.azul,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.azul.withValues(alpha: 0.2), 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15), 
                borderRadius: BorderRadius.circular(18)
              ),
              child: const Icon(Icons.history_edu, color: AppColors.amarillo, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ESTADÍA FINALIZADA",
                    style: TextStyle(color: AppColors.amarillo, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    t['observaciones']?.toString().toUpperCase() ?? "PLACA N/A",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('dd MMM, yyyy').format(entrada),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Historial",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.azul),
              ),
              const Text("Tus registros anteriores", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  // Quitamos el .eq() que causaba error y lo manejamos en el builder
                  stream: supabase
                      .from('tickets')
                      .stream(primaryKey: ['id_ticket'])
                      .order('fecha_hora_salida', ascending: false),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Center(child: Text("Error al conectar"));
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    // FILTRADO DINÁMICO: Solo tickets del usuario logueado y finalizados
                    final data = snapshot.data!
                        .where((t) => 
                          t['id_usuario'] == user?.id && 
                          t['estado_ticket'] == 'finalizado')
                        .toList();

                    if (data.isEmpty) {
                      return const Center(
                        child: Text("Aún no tienes historial.", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) => cardTicket(data[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}