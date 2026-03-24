import 'package:flutter/material.dart';
import 'package:ucad_parki/widgets/switch_item.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class NotificacionesPage extends StatefulWidget {
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
    return Scaffold(
      backgroundColor: AppColors.azul,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            //  VOLVER
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 10),

            //  TÍTULO
            const Text(
              "Notificaciones",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            //  TARJETA
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    //  NOTIFICACIONES
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

                    const Divider(),

                    //  SONIDO
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

                    const Divider(),

                    //  TIPO SONIDO
                    ListTile(
                      leading: Icon(Icons.music_note, color: AppColors.azul),
                      title: const Text("Tipo de sonido"),
                      trailing: DropdownButton<String>(
                        value: sonidoSeleccionado,
                        underline: const SizedBox(),
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

                    const SizedBox(height: 10),

                    // INFO
                    const Text(
                      "Configura cómo quieres recibir alertas del sistema de parqueo.",
                      style: TextStyle(color: Colors.grey),
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
