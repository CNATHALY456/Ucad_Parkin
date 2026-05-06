import 'package:flutter/material.dart';

class InputUcad extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

  const InputUcad({
    super.key,
    required this.hint,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      // CAMBIO CLAVE: Forzamos el color negro para el texto que se escribe
      style: const TextStyle(
        fontSize: 16, 
        color: Colors.black, // Evita el efecto blanco sobre blanco en Dark Mode
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        // Opcional: Forzar color gris para el texto de sugerencia (hint)
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}