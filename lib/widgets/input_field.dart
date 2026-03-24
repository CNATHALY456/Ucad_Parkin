import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final IconData icono;
  final TextEditingController controller;
  final bool esPassword;

  const InputField({
    super.key,
    required this.label,
    required this.icono,
    required this.controller,
    this.esPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: esPassword,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icono),
        ),
      ),
    );
  }
}
