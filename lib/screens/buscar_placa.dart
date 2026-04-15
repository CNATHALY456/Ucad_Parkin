import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuscarPlaca extends StatefulWidget {
  @override
  _BuscarPlacaState createState() => _BuscarPlacaState();
}

class _BuscarPlacaState extends State<BuscarPlaca> {
  final supabase = Supabase.instance.client;

  TextEditingController buscador = TextEditingController();

  List<Map<String, dynamic>> lista = [];
  List<Map<String, dynamic>> filtrados = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  // 🔥 TRAER DATOS DE SUPABASE
  void cargarDatos() async {
    final data = await supabase.from('transporte').select();

    setState(() {
      lista = List<Map<String, dynamic>>.from(data);
      filtrados = lista;
    });
  }

  // 🔍 FILTRAR
  void filtrar(String texto) {
    setState(() {
      filtrados = lista
          .where((v) => v['placa'].toLowerCase().contains(texto.toLowerCase()))
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

            // 🔍 BUSCADOR
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

            // 📋 LISTA
            Expanded(
              child: ListView.builder(
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final v = filtrados[index];

                  return tarjetaVehiculo(v);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🚗 TARJETA
  Widget tarjetaVehiculo(Map<String, dynamic> v) {
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
              Icon(iconoVehiculo(v['tipo']), size: 40, color: AppColors.azul),

              SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🟢 ESTADO + PLACA
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: v['activo'] ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          v['placa'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.azul,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6),

                    // 👤 DUEÑO RESALTADO
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Dueño: ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextSpan(
                            text: v['duenio'],
                            style: TextStyle(
                              color: AppColors.azul,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 5),

                    Text("Entrada: ${v['hora_entrada']}"),
                    Text("Salida: ${v['hora_salida']}"),
                  ],
                ),
              ),

              // 📞 CONTACTO
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.amarillo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.phone, color: AppColors.azul),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
