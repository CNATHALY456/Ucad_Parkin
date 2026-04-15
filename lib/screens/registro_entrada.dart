import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/models/transporte.dart';

class RegistrarEntrada extends StatefulWidget {
  @override
  _RegistrarEntradaState createState() => _RegistrarEntradaState();
}

class _RegistrarEntradaState extends State<RegistrarEntrada> {
  TextEditingController placaCtrl = TextEditingController();
  TextEditingController nombreCtrl = TextEditingController();

  String tipoUsuario = "Estudiante";
  String tipoVehiculo = "carro";

  bool mostrarFormulario = false;
  Transporte? ticket;

  List<Transporte> baseDatos = [];

  // 🔍 VERIFICAR PLACA
  void verificarPlaca() {
    final existe = baseDatos.where((v) => v.placa == placaCtrl.text);

    if (existe.isNotEmpty) {
      setState(() {
        ticket = existe.first;
        mostrarFormulario = false;
      });
    } else {
      setState(() {
        mostrarFormulario = true;
        ticket = null;
      });
    }
  }

  // 💾 REGISTRAR VEHÍCULO
  void registrarVehiculo() {
    final hora = TimeOfDay.now().format(context);

    Transporte nuevo = Transporte(
      placa: placaCtrl.text,
      tipo: tipoVehiculo,
      duenio: nombreCtrl.text,
      tipoUsuario: tipoUsuario,
      horaEntrada: hora,
      horaSalida: "Pendiente",
      activo: true,
    );

    baseDatos.add(nuevo);

    setState(() {
      ticket = nuevo;
      mostrarFormulario = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(
        title: Text("Registrar Entrada"),
        backgroundColor: AppColors.azul,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔵 INPUT PLACA
            TextField(
              controller: placaCtrl,
              decoration: InputDecoration(
                hintText: "Ingresar placa",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 15),

            // 🟡 BOTÓN VERIFICAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verificarPlaca,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amarillo,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  "Verificar placa",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            SizedBox(height: 20),

            // 📄 FORMULARIO
            if (mostrarFormulario) ...[
              Text(
                "Vehículo no registrado",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),

              SizedBox(height: 15),

              // NOMBRE
              TextField(
                controller: nombreCtrl,
                decoration: InputDecoration(
                  hintText: "Nombre completo",
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              // TIPO USUARIO
              DropdownButtonFormField<String>(
                value: tipoUsuario,
                items: ["Estudiante", "Empleado", "Visitante"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => tipoUsuario = value!);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              // TIPO VEHÍCULO
              DropdownButtonFormField<String>(
                value: tipoVehiculo,
                items: ["carro", "moto", "bicicleta"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => tipoVehiculo = value!);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              SizedBox(height: 15),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registrarVehiculo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text("Guardar"),
                ),
              ),
            ],

            SizedBox(height: 25),

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
                        "TICKET DE REGISTRO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    Text("Placa: ${ticket!.placa}"),
                    Text("Dueño: ${ticket!.duenio}"),
                    Text("Tipo usuario: ${ticket!.tipoUsuario}"),
                    Text("Vehículo: ${ticket!.tipo}"),
                    Text("Entrada: ${ticket!.horaEntrada}"),
                    Text("Salida: ${ticket!.horaSalida}"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
