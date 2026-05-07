import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class MiVehiculo extends StatefulWidget {
  const MiVehiculo({super.key});

  @override
  State<MiVehiculo> createState() => _MiVehiculoState();
}

class _MiVehiculoState extends State<MiVehiculo> {
  // 🚗 LISTA VEHÍCULOS
  List<Map<String, dynamic>> vehiculos = [];

  // 📝 CONTROLLERS
  final placaCtrl = TextEditingController();
  final marcaCtrl = TextEditingController();
  final modeloCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final anioCtrl = TextEditingController();

  String tipoVehiculo = "Carro";

  // ➕ AGREGAR VEHÍCULO
  void mostrarFormulario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),

              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "Agregar Vehículo",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azul,
                      ),
                    ),

                    const SizedBox(height: 25),

                    campo("Placa", placaCtrl),
                    campo("Marca", marcaCtrl),
                    campo("Modelo", modeloCtrl),
                    campo("Color", colorCtrl),
                    campo("Año", anioCtrl),

                    const SizedBox(height: 20),

                    Text(
                      "Tipo de vehículo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.azul,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: tipoVehiculo,

                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),

                      items: ["Carro", "Moto", "Bicicleta"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),

                      onChanged: (value) {
                        setModalState(() {
                          tipoVehiculo = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            vehiculos.add({
                              "placa": placaCtrl.text,
                              "marca": marcaCtrl.text,
                              "modelo": modeloCtrl.text,
                              "color": colorCtrl.text,
                              "anio": anioCtrl.text,
                              "tipo": tipoVehiculo,
                            });
                          });

                          placaCtrl.clear();
                          marcaCtrl.clear();
                          modeloCtrl.clear();
                          colorCtrl.clear();
                          anioCtrl.clear();

                          Navigator.pop(context);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azul,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        child: const Text(
                          "Guardar Vehículo",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ❌ ELIMINAR
  void eliminarVehiculo(int index) {
    setState(() {
      vehiculos.removeAt(index);
    });
  }

  // 🚗 ICONOS
  IconData iconoVehiculo(String tipo) {
    switch (tipo.toLowerCase()) {
      case "moto":
        return Icons.two_wheeler;

      case "bicicleta":
        return Icons.pedal_bike;

      default:
        return Icons.directions_car;
    }
  }

  // 📝 CAMPOS
  Widget campo(String titulo, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: AppColors.azul,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: controller,

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mi Vehículo",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.azul,
          ),
        ),

        const SizedBox(height: 25),

        // 🚫 NO VEHÍCULOS
        if (vehiculos.isEmpty)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    "assets/parky_sin_vehiculo.png",
                    height: 220,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "No tienes ningún vehículo",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azul,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Agrega tu vehículo para comenzar",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: mostrarFormulario,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azul,
                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    child: const Text(
                      "Agregar mi vehículo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 🚗 VEHÍCULOS
        if (vehiculos.isNotEmpty)
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: vehiculos.length,

                    itemBuilder: (context, index) {
                      final v = vehiculos[index];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),

                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 10,
                        ),

                        padding: const EdgeInsets.all(25),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconoVehiculo(v["tipo"]),
                              size: 120,
                              color: AppColors.azul,
                            ),

                            const SizedBox(height: 25),

                            Text(
                              v["placa"],
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: AppColors.azul,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "${v["marca"]} ${v["modelo"]}",
                              style: const TextStyle(fontSize: 18),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Color: ${v["color"]}",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            Text(
                              "Año: ${v["anio"]}",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            Text(
                              "Tipo: ${v["tipo"]}",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            const SizedBox(height: 25),

                            ElevatedButton.icon(
                              onPressed: () {
                                eliminarVehiculo(index);
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 14,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),

                              icon: const Icon(Icons.delete),
                              label: const Text("Eliminar vehículo"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: mostrarFormulario,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azul,
                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Agregar vehículo",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
