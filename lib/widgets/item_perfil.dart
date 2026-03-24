import 'package:flutter/material.dart';

class ItemPerfil extends StatelessWidget {
  final String texto;
  final IconData icono;
  final VoidCallback onTap;
  final Color color;

  const ItemPerfil({
    super.key,
    required this.texto,
    required this.icono,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: color),
      title: Text(
        texto,
        style: TextStyle(
          color: color == Colors.red ? Colors.red : Colors.black,
          fontWeight: color == Colors.red ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      onTap: onTap,
    );
  }
}
