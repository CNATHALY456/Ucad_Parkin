import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (placaCtrl.text.isEmpty) return;

    setState(() => procesando = true);
    final placa = placaCtrl.text.toUpperCase();
    final fechaSalida = DateTime.now().toIso8601String();

    try {
      final ticketActivo = await supabase
          .from('tickets')
          .select()
          .eq('estado_ticket', 'activo')
          .ilike('observaciones', '%$placa%')
          .maybeSingle();

      if (ticketActivo != null) {
        await supabase
            .from('tickets')
            .update({
              'fecha_hora_salida': fechaSalida,
              'estado_ticket': 'finalizado',
              'metodo_salida': 'manual'
            })
            .eq('id_ticket', ticketActivo['id_ticket']);

        setState(() {
          ticketFinalizado = {
            'placa': placa,
            'entrada': ticketActivo['fecha_hora_entrada'],
            'salida': fechaSalida
          };
          procesando = false;
        });
        
        placaCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.blue, content: Text("Salida registrada con éxito")),
        );
      } else {
        setState(() => procesando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se encontró entrada activa para esta placa")),
        );
      }
    } catch (e) {
      setState(() => procesando = false);
      debugPrint("Error en salida: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectar el tema actual
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      // Fondo dinámico basado en el tema
      backgroundColor: isDark ? theme.surface : AppColors.azul,
      appBar: AppBar(
        title: const Text("Salida UCAD", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Campo de texto adaptativo
            TextField(
              controller: placaCtrl,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Ingrese Placa",
                hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                filled: true, 
                fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.directions_car, color: isDark ? AppColors.amarillo : AppColors.azul),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: procesando ? null : procesarSalida,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amarillo,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  procesando ? "Procesando..." : "Registrar Salida", 
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                ),
              ),
            ),
            
            if (ticketFinalizado != null) _buildResumen(isDark, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen(bool isDark, ColorScheme theme) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 50),
          const SizedBox(height: 10),
          Text(
            "RESUMEN DE SALIDA", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : Colors.black
            )
          ),
          const Divider(),
          _resumenRow("Vehículo", ticketFinalizado!['placa'], isDark),
          _resumenRow("Entrada", ticketFinalizado!['entrada'], isDark),
          _resumenRow("Salida", ticketFinalizado!['salida'], isDark),
        ],
      ),
    );
  }

  Widget _resumenRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        ],
      ),
    );
  }
}