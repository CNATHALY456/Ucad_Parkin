import 'package:flutter/material.dart';

class InputUcad extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller; // 👈 agregado

  const InputUcad({
    super.key,
    required this.hint,
    this.isPassword = false,
    this.controller, // 👈 agregado
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // 👈 agregado
      obscureText: isPassword,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
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
