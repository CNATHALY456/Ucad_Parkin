import 'package:flutter/material.dart';

class SwitchItem extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool valor;
  final Function(bool)? onChanged;
  final Color color;

  const SwitchItem({
    super.key,
    required this.texto,
    required this.icono,
    required this.valor,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icono, color: color),
      title: Text(texto),
      value: valor,
      activeColor: color,
      onChanged: onChanged,
    );
  }
}
