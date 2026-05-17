import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  Widget cardDashboard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 35),

          const SizedBox(height: 15),

          Text(
            valor,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            titulo,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Bienvenida Administradora",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Sistema inteligente de gestión vehicular",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            crossAxisSpacing: 15,
            mainAxisSpacing: 15,

            childAspectRatio: 1.1,

            children: [

              cardDashboard(
                "Vehículos",
                "120",
                Icons.directions_car,
                Colors.blue,
              ),

              cardDashboard(
                "Activos",
                "48",
                Icons.local_parking,
                Colors.green,
              ),

              cardDashboard(
                "Tickets Hoy",
                "75",
                Icons.confirmation_num,
                Colors.orange,
              ),

              cardDashboard(
                "Espacios",
                "32",
                Icons.garage,
                Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: AppColors.azul,
              borderRadius: BorderRadius.circular(25),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Parqueo Principal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "78/100 espacios ocupados",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}