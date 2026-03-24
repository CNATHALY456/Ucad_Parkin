import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/models/transporte.dart';

class BuscarPlaca extends StatefulWidget {
  @override
  _BuscarPlacaState createState() => _BuscarPlacaState();
}

class _BuscarPlacaState extends State<BuscarPlaca> {
  TextEditingController buscador = TextEditingController();

  List<Transporte> lista = [
    Transporte(
      placa: "P123-456",
      tipo: "carro",
      duenio: "Juan Pérez",
      horaEntrada: "08:30 AM",
      horaSalida: "Pendiente",
      activo: true,
    ),
    Transporte(
      placa: "M789-222",
      tipo: "moto",
      duenio: "Carlos López",
      horaEntrada: "09:10 AM",
      horaSalida: "Pendiente",
      activo: true,
    ),
  ];

  List<Transporte> filtrados = [];

  @override
  void initState() {
    super.initState();
    filtrados = lista;
  }

  void filtrar(String texto) {
    setState(() {
      filtrados = lista
          .where((v) => v.placa.toLowerCase().contains(texto.toLowerCase()))
          .toList();
    });
  }

  IconData iconoVehiculo(String tipo) {
    switch (tipo) {
      case "moto":
        return Icons.two_wheeler;
      case "bicicleta":
        return Icons.pedal_bike;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),

            //  BUSCADOR
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: buscador,
                onChanged: filtrar,
                decoration: InputDecoration(
                  hintText: "Buscar placa...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            //  RESULTADOS
            Expanded(
              child: ListView.builder(
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final v = filtrados[index];

                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 400),
                    tween: Tween(begin: 0.8, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: tarjetaVehiculo(v),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  TARJETA
  Widget tarjetaVehiculo(Transporte v) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // 🚗 ICONO
              Column(
                children: [
                  Icon(iconoVehiculo(v.tipo), size: 40, color: AppColors.azul),

                  SizedBox(height: 10),

                  //  ESTADO
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: v.activo ? Colors.green : Colors.red,
                  ),
                ],
              ),

              SizedBox(width: 15),

              //  INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.placa,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azul,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text("Dueño: ${v.duenio}"),

                    SizedBox(height: 5),

                    Text("Entrada: ${v.horaEntrada}"),

                    Text("Salida: ${v.horaSalida}"),
                  ],
                ),
              ),

              //  BOTÓN CONTACTO
              GestureDetector(
                onTap: () {
                  print("Contactar a ${v.duenio}");
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.amarillo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.phone, color: AppColors.azul),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
