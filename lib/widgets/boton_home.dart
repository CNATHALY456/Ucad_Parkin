import 'package:flutter/material.dart';

class BotonHome extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final VoidCallback onTap;
  final Color azul;
  final Color amarillo;

  const BotonHome({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.onTap,
    required this.azul,
    required this.amarillo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 6,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // ICONO
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: azul),
                ),

                const SizedBox(width: 15),

                // TEXTO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: amarillo,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Icon(Icons.arrow_forward_ios, color: amarillo, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
