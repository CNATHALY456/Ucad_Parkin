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
  Map<String, dynamic>? ticket;
  String mensaje = "";

  void registrarSalida() async {
    final placa = placaCtrl.text;

    final response = await supabase
        .from('transporte')
        .select()
        .eq('placa', placa)
        .eq('activo', true)
        .maybeSingle();

    if (response != null) {
      final hora = TimeOfDay.now().format(context);

      await supabase
          .from('transporte')
          .update({"hora_salida": hora, "activo": false})
          .eq('id', response['id']);

      setState(() {
        ticket = {...response, "hora_salida": hora};
        mensaje = "";
      });
    } else {
      setState(() {
        mensaje = "Vehículo no encontrado o ya salió";
        ticket = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(
        title: Text("Registro de Salida"),
        backgroundColor: AppColors.azul,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔍 INPUT
            TextField(
              controller: placaCtrl,
              decoration: InputDecoration(
                hintText: "Ingresar placa",
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            SizedBox(height: 15),

            // 🔘 BOTÓN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registrarSalida,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amarillo,
                ),
                child: Text(
                  "Registrar salida",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            SizedBox(height: 20),

            // ❌ ERROR
            if (mensaje.isNotEmpty)
              Text(mensaje, style: TextStyle(color: Colors.red, fontSize: 16)),

            SizedBox(height: 20),

            // 🎟️ TICKET
            if (ticket != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "SALIDA REGISTRADA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    Text("Placa: ${ticket!['placa']}"),
                    Text("Dueño: ${ticket!['duenio']}"),
                    Text("Tipo: ${ticket!['tipo_usuario']}"),
                    Text("Entrada: ${ticket!['hora_entrada']}"),
                    Text("Salida: ${ticket!['hora_salida']}"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
