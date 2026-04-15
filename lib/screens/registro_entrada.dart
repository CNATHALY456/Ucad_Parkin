import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrarEntrada extends StatefulWidget {
  @override
  _RegistrarEntradaState createState() => _RegistrarEntradaState();
}

class _RegistrarEntradaState extends State<RegistrarEntrada> {
  final supabase = Supabase.instance.client;
  TextEditingController placaCtrl = TextEditingController();
  
  bool mostrarFormulario = false;
  bool cargando = false;
  Map<String, dynamic>? ticketActivo;

  // 🔍 READ: Verificar si la placa ya tiene un ticket activo en tu tabla SQL
  void verificarPlaca() async {
    if (placaCtrl.text.isEmpty) return;
    
    setState(() => cargando = true);
    final placa = placaCtrl.text.toUpperCase();

    try {
      final response = await supabase
          .from('tickets')
          .select()
          .eq('estado_ticket', 'activo')
          .ilike('observaciones', '%$placa%')
          .maybeSingle();

      setState(() {
        cargando = false;
        if (response != null) {
          ticketActivo = response;
          mostrarFormulario = false;
        } else {
          mostrarFormulario = true;
          ticketActivo = null;
        }
      });
    } catch (e) {
      setState(() => cargando = false);
      print("Error al verificar: $e");
    }
  }

  // 📥 CREATE: Insertar registro en la tabla 'tickets'
  void registrarEntrada() async {
    final placa = placaCtrl.text.toUpperCase();
    final fechaIso = DateTime.now().toIso8601String();

    try {
      await supabase.from('tickets').insert({
        'fecha_hora_entrada': fechaIso,
        'estado_ticket': 'activo',
        'metodo_ingreso': 'manual',
        'observaciones': 'PLACA: $placa', 
        // Nota: Los IDs de usuario/vehículo quedan nulos para no romper FKs
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("Se ha registrado la entrada exitosamente")),
      );

      setState(() {
        mostrarFormulario = false;
        ticketActivo = {
          'observaciones': 'PLACA: $placa',
          'fecha_hora_entrada': fechaIso,
        };
      });
    } catch (e) {
      print("Error al insertar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Error al guardar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(title: Text("Entrada UCAD"), backgroundColor: AppColors.azul),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: placaCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "Número de Placa",
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cargando ? null : verificarPlaca,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.amarillo),
                child: Text(cargando ? "Buscando..." : "Verificar Placa", style: TextStyle(color: Colors.black)),
              ),
            ),
            if (mostrarFormulario) ...[
              SizedBox(height: 30),
              Text("Vehículo no detectado. ¿Registrar ingreso?", style: TextStyle(color: Colors.white)),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registrarEntrada,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Registrar Entrada"),
                ),
              ),
            ],
            if (ticketActivo != null) _buildTicketView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketView() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text("TICKET EN CURSO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Divider(),
          Text("${ticketActivo!['observaciones']}"),
          Text("Fecha: ${ticketActivo!['fecha_hora_entrada']}"),
        ],
      ),
    );
  }
}