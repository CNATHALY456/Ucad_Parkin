import 'package:flutter/material.dart';
import 'package:ucad_parki/widgets/switch_item.dart';
import 'package:ucad_parki/utils/app_colors.dart';

class ConfiguracionPage extends StatefulWidget {
  @override
  _ConfiguracionPageState createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool modoOscuro = false;
  String idiomaSeleccionado = "Español";

  List<String> idiomas = ["Español", "Inglés"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // VOLVER
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
              "Configuración",
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
                    // 🌙 MODO OSCURO
                    SwitchItem(
                      texto: "Modo oscuro",
                      icono: Icons.dark_mode,
                      valor: modoOscuro,
                      color: AppColors.amarillo,
                      onChanged: (value) {
                        setState(() {
                          modoOscuro = value;
                        });
                      },
                    ),

                    const Divider(),

                    //  IDIOMA
                    ListTile(
                      leading: Icon(Icons.language, color: AppColors.azul),
                      title: const Text("Idioma"),
                      trailing: DropdownButton<String>(
                        value: idiomaSeleccionado,
                        underline: const SizedBox(),
                        items: idiomas.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (nuevo) {
                          setState(() {
                            idiomaSeleccionado = nuevo!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    //  INFO
                    const Text(
                      "Personaliza la apariencia y el idioma de la aplicación.",
                      style: TextStyle(color: Colors.grey),
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
