import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class TicketsAdmin extends StatelessWidget {
  const TicketsAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,

      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: AppColors.azul,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TICKET #00$index",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Placa: P123-456",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 5),

              const Text(
                "Fecha: 17/05/2026",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,

                child: ElevatedButton(
                  onPressed: () {},

                  child: const Text("Ver ticket"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
