import 'package:flutter/material.dart';

class LabelUcad extends StatelessWidget {
  final String texto;

  const LabelUcad({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white, // Siempre blanco para el fondo azul
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
