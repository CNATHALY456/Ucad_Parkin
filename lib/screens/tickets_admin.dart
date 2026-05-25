import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class TicketsAdmin extends StatefulWidget {
  const TicketsAdmin({super.key});

  @override
  State<TicketsAdmin> createState() => _TicketsAdminState();
}

class _TicketsAdminState extends State<TicketsAdmin> {
  final supabase = Supabase.instance.client;

  // --- FUNCIÓN PARA MOSTRAR DETALLES ADAPTATIVOS EN EL MODAL ---
  void mostrarDetallesTicket(Map<String, dynamic> ticket, bool isDark, ColorScheme theme) {
    final String idTicket = ticket['id_ticket']?.toString() ?? 'N/A';
    final String estado = (ticket['estado_ticket'] ?? 'activo').toString().toUpperCase();
    final String observaciones = ticket['observaciones']?.toString() ?? 'Sin detalles adicionales';
    final String entrada = ticket['fecha_hora_entrada']?.toString() ?? 'No registrada';
    final String salida = ticket['fecha_hora_salida']?.toString() ?? 'Sigue en las instalaciones';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface, // Fondo adaptativo al tema
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Ticket #00$idTicket",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isDark ? theme.primary : AppColors.azul, // Azul insignia o Primario Nocturno
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Estado: $estado", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: estado == "ACTIVO" ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text("Entrada: $entrada", style: TextStyle(color: theme.onSurface)),
            const SizedBox(height: 5),
            Text("Salida: $salida", style: TextStyle(color: theme.onSurface)),
            const SizedBox(height: 10),
            Divider(color: theme.outlineVariant),
            Text(
              "Información:", 
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.onSurface),
            ),
            Text(observaciones, style: TextStyle(color: theme.onSurfaceVariant)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- CONEXIÓN AL PROV_CONFIG Y COLOR SCHEME ---
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('tickets')
          .stream(primaryKey: ['id_ticket'])
          .order('fecha_hora_entrada', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: theme.onSurface)));
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? theme.primary : AppColors.azul,
            ),
          );
        }

        final listaTickets = snapshot.data!;

        if (listaTickets.isEmpty) {
          return const Center(
            child: Text(
              "No se han emitido tickets en el sistema",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: listaTickets.length,
          itemBuilder: (context, index) {
            final ticket = listaTickets[index];

            final String idTicket = ticket['id_ticket']?.toString() ?? index.toString();
            final String obsCompleta = ticket['observaciones']?.toString() ?? '';
            final String placaReal = obsCompleta.isNotEmpty ? obsCompleta.split('|')[0].trim() : 'N/A';

            final String fechaCompleta = ticket['fecha_hora_entrada']?.toString() ?? '';
            final String fechaFormateada = fechaCompleta.isNotEmpty ? fechaCompleta.substring(0, 10) : 'N/A';

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                // Si está en modo oscuro usa el contenedor de superficie nocturno; si no, hereda tu azul original
                color: isDark ? theme.surfaceContainer : AppColors.azul,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TICKET #00$idTicket",
                    style: TextStyle(
                      color: isDark ? theme.onSurface : Colors.white, // Letras blancas en claro, adaptables en oscuro
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Placa: $placaReal",
                    style: TextStyle(
                      color: isDark ? theme.onSurfaceVariant : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Fecha: $fechaFormateada",
                    style: TextStyle(
                      color: isDark ? theme.onSurfaceVariant : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? theme.primaryContainer : Colors.white,
                        foregroundColor: isDark ? theme.onPrimaryContainer : AppColors.azul,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        mostrarDetallesTicket(ticket, isDark, theme);
                      },
                      child: const Text("Ver ticket", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}