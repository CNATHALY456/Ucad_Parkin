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
    // Detectamos el brillo actual del sistema o del provider
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        // Elevación original de 6 para el modo claro, reducida para el oscuro
        elevation: isDark ? 2 : 6, 
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              // Mantenemos el color que viene del Home (Gris en Dark, Azul en Light)
              color: azul, 
              borderRadius: BorderRadius.circular(20),
              // Solo añadimos borde sutil si es Dark
              border: isDark ? Border.all(color: Colors.white10) : null,
            ),
            child: Row(
              children: [
                // CONTENEDOR DEL ICONO
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // MODO CLARO: Mantiene el blanco sólido original
                    // MODO OSCURO: Usa transparencia para coherencia
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icono, 
                    // MODO CLARO: Usa el azul original
                    // MODO OSCURO: Usa el amarillo para resaltar
                    color: isDark ? amarillo : azul,
                  ),
                ),

                const SizedBox(width: 15),

                // TEXTO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          // MODO CLARO: Amarillo original
                          // MODO OSCURO: Blanco para legibilidad
                          color: isDark ? Colors.white : amarillo,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          // MODO CLARO: Blanco70 original
                          // MODO OSCURO: Un blanco más tenue
                          color: isDark ? Colors.white60 : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.arrow_forward_ios, color: amarillo, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}