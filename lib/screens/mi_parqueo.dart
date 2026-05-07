import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class MiParqueo extends StatefulWidget {
  const MiParqueo({super.key});

  @override
  State<MiParqueo> createState() => _MiParqueoState();
}

class _MiParqueoState extends State<MiParqueo> {
  // 🚗 ESTADO SIMULADO
  // false = no está usando parqueo
  // true = vehículo dentro del parqueo
  bool usandoParqueo = true;

  // ⏱️ TIMER
  Duration tiempo = Duration.zero;
  Timer? timer;

  // 📅 HORA ENTRADA
  final DateTime horaEntrada = DateTime.now().subtract(
    const Duration(hours: 2, minutes: 35),
  );

  @override
  void initState() {
    super.initState();

    if (usandoParqueo) {
      iniciarTiempo();
    }
  }

  void iniciarTiempo() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        tiempo = DateTime.now().difference(horaEntrada);
      });
    });
  }

  String formatearTiempo(Duration d) {
    String horas = d.inHours.toString().padLeft(2, '0');
    String minutos = (d.inMinutes % 60).toString().padLeft(2, '0');
    String segundos = (d.inSeconds % 60).toString().padLeft(2, '0');

    return "$horas:$minutos:$segundos";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget infoItem(IconData icono, String titulo, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: AppColors.azul.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icono, color: AppColors.azul),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  valor,
                  style: TextStyle(
                    color: AppColors.azul,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏠 TÍTULO
          Text(
            "Mi Parqueo",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.azul,
            ),
          ),

          const SizedBox(height: 25),

          // 🚫 NO ESTÁ EN PARQUEO
          if (!usandoParqueo)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "NO ESTÁS USANDO EL PARQUEO",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: AppColors.amarillo,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 35),

                  Center(
                    child: Image.asset(
                      "assets/parky_parqueo_vacio.png",
                      height: 260,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Tu vehículo aún no ha sido registrado",
                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.grey.shade600, fontSize: 17),
                  ),
                ],
              ),
            ),

          // 🚗 VEHÍCULO DENTRO DEL PARQUEO
          if (usandoParqueo)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                child: Column(
                  children: [
                    // 🚗 CARD PRINCIPAL
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),

                      width: double.infinity,

                      padding: const EdgeInsets.all(25),

                      decoration: BoxDecoration(
                        color: AppColors.azul,
                        borderRadius: BorderRadius.circular(35),

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.azul.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          Icon(
                            Icons.directions_car,
                            size: 120,
                            color: AppColors.amarillo,
                          ),

                          const SizedBox(height: 20),

                          Text(
                            "P 123-456",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(30),
                            ),

                            child: const Text(
                              "Vehículo dentro del parqueo",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ⏱️ TIEMPO
                          Container(
                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(25),
                            ),

                            child: Column(
                              children: [
                                const Text(
                                  "Tiempo dentro",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  formatearTiempo(tiempo),
                                  style: TextStyle(
                                    color: AppColors.amarillo,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 📋 INFORMACIÓN
                    infoItem(Icons.local_parking, "Parqueo", "Principal"),

                    infoItem(Icons.place, "Espacio", "A-15"),

                    infoItem(Icons.category, "Tipo de vehículo", "Carro"),

                    infoItem(Icons.color_lens, "Color", "Negro"),

                    infoItem(Icons.access_time, "Hora de entrada", "08:30 AM"),

                    infoItem(Icons.logout, "Hora de salida", "Pendiente"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
