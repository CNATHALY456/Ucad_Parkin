import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistroSalida extends StatefulWidget {
  @override
  _RegistroSalidaState createState() => _RegistroSalidaState();
}

class _RegistroSalidaState extends State<RegistroSalida> {
  final supabase = Supabase.instance.client;
  TextEditingController placaCtrl = TextEditingController();
  Map<String, dynamic>? ticketFinalizado;
  bool procesando = false;

  // 📤 UPDATE: Actualizar registro existente en 'tickets'
  void procesarSalida() async {
    if (placaCtrl.text.isEmpty) return;

    setState(() => procesando = true);
    final placa = placaCtrl.text.toUpperCase();
    final fechaSalida = DateTime.now().toIso8601String();

    try {
      // 1. Buscamos el ticket que esté activo para esa placa
      final ticketActivo = await supabase
          .from('tickets')
          .select()
          .eq('estado_ticket', 'activo')
          .ilike('observaciones', '%$placa%')
          .maybeSingle();

      if (ticketActivo != null) {
        // 2. Actualizamos el registro (UPDATE) usando su ID Primaria 'id_ticket'
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
          SnackBar(backgroundColor: Colors.blue, content: Text("Salida registrada con éxito")),
        );
      } else {
        setState(() => procesando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se encontró entrada activa para esta placa")),
        );
      }
    } catch (e) {
      setState(() => procesando = false);
      print("Error en salida: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(title: Text("Salida UCAD"), backgroundColor: AppColors.azul),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: placaCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "Ingrese Placa",
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: procesando ? null : procesarSalida,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.amarillo),
                child: Text(procesando ? "Procesando..." : "Registrar Salida", style: TextStyle(color: Colors.black)),
              ),
            ),
            if (ticketFinalizado != null) _buildResumen(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 50),
          Text("RESUMEN DE SALIDA", style: TextStyle(fontWeight: FontWeight.bold)),
          Divider(),
          Text("Vehículo: ${ticketFinalizado!['placa']}"),
          Text("Entrada: ${ticketFinalizado!['entrada']}"),
          Text("Salida: ${ticketFinalizado!['salida']}"),
        ],
      ),
    );
  }
}