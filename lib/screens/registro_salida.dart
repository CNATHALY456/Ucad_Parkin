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

  // Lógica principal de salida
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
      // 1. BUSQUEDA: Solo tickets con estado 'activo'
      final ticketActivo = await supabase
          .from('tickets')
          .select()
          .eq('estado_ticket', 'activo')
          .ilike('observaciones', '%$placaLimpia%')
          .maybeSingle();

      if (ticketActivo != null) {
        final idTicket = ticketActivo['id_ticket'];

        // 2. ACTUALIZACIÓN: Cambiamos estado a 'finalizado' y grabamos hora de salida
        await supabase
            .from('tickets')
            .update({
              'fecha_hora_salida': DateTime.now().toIso8601String(),
              'estado_ticket': 'finalizado',
              'metodo_salida': 'manual'
            })
            .match({'id_ticket': idTicket});

        // 3. VERIFICACIÓN: Confirmamos que el cambio impactó en la DB
        final confirmacion = await supabase
            .from('tickets')
            .select('estado_ticket')
            .eq('id_ticket', idTicket)
            .single();

        if (confirmacion['estado_ticket'] == 'finalizado') {
          setState(() {
            ticketFinalizado = {
              'placa': placaLimpia,
              'entrada': ticketActivo['fecha_hora_entrada'],
              'salida': DateTime.now().toIso8601String()
            };
            procesando = false;
          });
          placaCtrl.clear();
          _showSnackBar("✅ Salida registrada y confirmada", Colors.green);
        } else {
          throw "Error de consistencia: El estado no cambió.";
        }
      } else {
        setState(() => procesando = false);
        _showSnackBar("⚠️ No hay tickets ACTIVOS para: $placaLimpia", Colors.orange);
      }
    } catch (e) {
      setState(() => procesando = false);
      debugPrint("Error crítico en salida: $e");
      _showSnackBar("❌ Error al guardar: Revisa tus políticas RLS", Colors.red);
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
    final theme = Theme.of(context).colorScheme;

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
            // CAMPO DE TEXTO PARA PLACA
            TextField(
              controller: placaCtrl,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "PLACA DEL VEHÍCULO",
                hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.exit_to_app, color: isDark ? AppColors.amarillo : Colors.redAccent),
              ),
            ),
            const SizedBox(height: 25),
            
            // BOTÓN DE ACCIÓN
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: procesando ? null : procesarSalida,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.amarillo : Colors.redAccent,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: procesando 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("MARCAR SALIDA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            // RESUMEN VISUAL SI LA SALIDA FUE EXITOSA
            if (ticketFinalizado != null) _buildResumen(isDark, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen(bool isDark, ColorScheme theme) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
          const SizedBox(height: 10),
          const Text("SALIDA PROCESADA", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
          const Divider(height: 30),
          _row("Vehículo", ticketFinalizado!['placa'], isDark),
          _row("H. Entrada", _formatDate(ticketFinalizado!['entrada']), isDark),
          _row("H. Salida", _formatDate(ticketFinalizado!['salida']), isDark),
          const SizedBox(height: 10),
          const Text("El espacio ha sido liberado en el sistema.", 
            style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(date).toLocal());
    } catch (e) {
      return date;
    }
  }

  Widget _row(String label, String valor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(valor, style: TextStyle(
            color: isDark ? Colors.white : Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: 15
          )),
        ],
      ),
    );
  }
}