import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  // --- TARJETA DEL DASHBOARD ADAPTATIVA ---
  Widget cardDashboard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
    bool isDark,
    ColorScheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Cambia el fondo blanco por el contenedor oscuro del tema
        color: isDark ? theme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 35),
          const SizedBox(height: 15),
          Text(
            valor,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.onSurface, // Texto adaptativo (Blanco o Negro)
            ),
          ),
          const SizedBox(height: 5),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    
    // --- LECTURA DEL ESTADO DEL MODO OSCURO ---
    final config = Provider.of<ConfigProvider>(context);
    final isDark = config.isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('tickets').stream(primaryKey: ['id_ticket']),
      builder: (context, snapshot) {
        final String vehiculos = snapshot.hasData 
            ? snapshot.data!.map((t) => t['observaciones']?.toString().split('|')[0] ?? '').toSet().where((p) => p.isNotEmpty).length.toString()
            : "...";
            
        final String activos = snapshot.hasData
            ? snapshot.data!.where((t) => t['estado_ticket'] == 'activo').length.toString()
            : "...";

        final String fechaHoy = DateTime.now().toLocal().toString().substring(0, 10);
        final String ticketsHoy = snapshot.hasData
            ? snapshot.data!.where((t) => t['fecha_hora_entrada'].toString().startsWith(fechaHoy)).length.toString()
            : "...";

        int calculoEspacios = 100 - (snapshot.hasData ? snapshot.data!.where((t) => t['estado_ticket'] == 'activo').length : 0);
        final String espacios = snapshot.hasData ? calculoEspacios.toString() : "...";
        final String ocupadosTexto = snapshot.hasData 
            ? "${snapshot.data!.where((t) => t['estado_ticket'] == 'activo').length}/100 espacios ocupados"
            : "Cargando espacios ocupados...";

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bienvenido, Administrador",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sistema inteligente de gestión vehicular",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  cardDashboard("Vehículos", vehiculos, Icons.directions_car, Colors.blue, isDark, theme),
                  cardDashboard("Activos", activos, Icons.local_parking, Colors.green, isDark, theme),
                  cardDashboard("Tickets Hoy", ticketsHoy, Icons.confirmation_num, Colors.orange, isDark, theme),
                  cardDashboard("Espacios", espacios, Icons.garage, Colors.red, isDark, theme),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // --- CONTENEDOR GRANDE INFERIOR (ADAPTATIVO) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // Si es modo oscuro usa el contenedor primario del sistema; de lo contrario, tu azul insignia
                  color: isDark ? theme.primaryContainer : AppColors.azul,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Parqueo Principal",
                      style: TextStyle(
                        color: isDark ? theme.onPrimaryContainer : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ocupadosTexto,
                      style: TextStyle(
                        color: isDark ? theme.onPrimaryContainer.withAlpha(180) : Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}