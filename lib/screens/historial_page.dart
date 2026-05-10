import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  // 📋 HISTORIAL SIMULADO
  final List<Map<String, dynamic>> historial = [
    {
      "ticket": "UCAD-2026-001",
      "placa": "P123-456",
      "fecha": "12/05/2026",

      "entrada": "08:30 AM",
      "salida": "11:45 AM",

      "vigilante": "Carlos Martínez",

      "saldo": "\$1.50",
      "tiempo": "3 horas 15 minutos",

      "duenio": "Juan Pérez",
      "vehiculo": "Toyota Corolla Negro",
    },

    {
      "ticket": "UCAD-2026-002",
      "placa": "M789-222",
      "fecha": "13/05/2026",

      "entrada": "09:10 AM",
      "salida": "12:00 PM",

      "vigilante": "Kevin López",

      "saldo": "\$1.00",
      "tiempo": "2 horas 50 minutos",

      "duenio": "Carlos Hernández",
      "vehiculo": "Honda CBR Roja",
    },
  ];

  // 🎟️ DETALLE TICKET
  void mostrarTicket(Map<String, dynamic> t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 25),

                // 🏫 TITULO
                Text(
                  "Universidad Cristiana\nde las Asambleas de Dios",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: AppColors.azul,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "APP DE PARQUEO\n(UCAD PARKI)",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: AppColors.amarillo,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: AppColors.azul,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Column(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        color: AppColors.amarillo,
                        size: 70,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        t["ticket"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                info("Fecha", t["fecha"]),
                info("Hora entrada", t["entrada"]),
                info("Hora salida", t["salida"]),
                info("Vigilante", t["vigilante"]),
                info("Tiempo total", t["tiempo"]),
                info("Saldo cancelado", t["saldo"]),
                info("Placa", t["placa"]),
                info("Vehículo", t["vehiculo"]),
                info("Dueño", t["duenio"]),

                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📋 ITEM INFORMACIÓN
  Widget info(String titulo, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
          ),

          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,

              style: TextStyle(
                color: AppColors.azul,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎟️ CARD TICKET
  Widget cardTicket(Map<String, dynamic> t) {
    return GestureDetector(
      onTap: () {
        mostrarTicket(t);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        margin: const EdgeInsets.only(bottom: 18),

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: AppColors.azul,
          borderRadius: BorderRadius.circular(25),

          boxShadow: [
            BoxShadow(
              color: AppColors.azul.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),

              child: Icon(
                Icons.confirmation_number,
                color: AppColors.amarillo,
                size: 35,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TICKET",
                    style: TextStyle(
                      color: AppColors.amarillo,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    t["ticket"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    t["placa"],
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  t["fecha"],
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 10),

                Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
              ],
            ),
          ],
        ),
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
          Text(
            "Historial",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.azul,
            ),
          ),

          const SizedBox(height: 25),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),

              itemCount: historial.length,

              itemBuilder: (context, index) {
                return cardTicket(historial[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
