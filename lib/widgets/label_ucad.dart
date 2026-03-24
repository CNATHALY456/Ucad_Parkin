import 'package:flutter/material.dart';

class LabelUcad extends StatelessWidget {
  final String texto;

  const LabelUcad({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
