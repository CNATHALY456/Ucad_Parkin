import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/widgets/switch_item.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  bool notificacionesActivas = true;
  bool sonidoActivo = true;
  String sonidoSeleccionado = "Clásico";
  List<String> sonidos = ["Clásico", "Digital", "Suave"];

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado del Dark Mode
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      // Fondo superior dinámico
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.azul,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // BOTÓN VOLVER
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 10),

            // TÍTULO
            const Text(
              "Notificaciones",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // TARJETA DE OPCIONES
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // Fondo adaptativo de la tarjeta
                  color: isDark ? theme.surface : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    // NOTIFICACIONES
                    SwitchItem(
                      texto: "Activar notificaciones",
                      icono: Icons.notifications,
                      valor: notificacionesActivas,
                      color: AppColors.amarillo,
                      onChanged: (value) {
                        setState(() {
                          notificacionesActivas = value;
                        });
                      },
                    ),

                    Divider(color: isDark ? Colors.white10 : Colors.grey[300]),

                    // SONIDO
                    SwitchItem(
                      texto: "Sonido",
                      icono: Icons.volume_up,
                      valor: sonidoActivo,
                      color: AppColors.amarillo,
                      onChanged: notificacionesActivas
                          ? (value) {
                              setState(() {
                                sonidoActivo = value;
                              });
                            }
                          : null,
                    ),

                    Divider(color: isDark ? Colors.white10 : Colors.grey[300]),

                    // TIPO SONIDO
                    ListTile(
                      leading: Icon(
                        Icons.music_note, 
                        color: isDark ? AppColors.amarillo : AppColors.azul
                      ),
                      title: Text(
                        "Tipo de sonido",
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      ),
                      trailing: DropdownButton<String>(
                        value: sonidoSeleccionado,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        iconEnabledColor: isDark ? AppColors.amarillo : AppColors.azul,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.azul,
                          fontWeight: FontWeight.bold
                        ),
                        items: sonidos.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (notificacionesActivas && sonidoActivo)
                            ? (nuevo) {
                                setState(() {
                                  sonidoSeleccionado = nuevo!;
                                });
                              }
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // INFO
                    Text(
                      "Configura cómo quieres recibir alertas del sistema de parqueo.",
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}