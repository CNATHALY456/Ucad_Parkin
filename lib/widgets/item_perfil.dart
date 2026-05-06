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
          // CORRECCIÓN: Usamos directamente la variable 'color' 
          // para que sea blanco en Dark Mode y azul/negro en Light Mode.
          color: color, 
          fontWeight: color == Colors.redAccent || color == Colors.red 
              ? FontWeight.bold 
              : FontWeight.normal,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios, 
        size: 15, 
        // También le damos color a la flecha para que no se pierda
        color: color.withOpacity(0.5), 
      ),
      onTap: onTap,
    );
  }
}