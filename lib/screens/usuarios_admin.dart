import 'package:flutter/material.dart';

class UsuariosAdmin extends StatelessWidget {
  const UsuariosAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Buscar usuario",
            prefixIcon: Icon(Icons.search),

            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ListView.builder(
            itemCount: 10,

            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),

                  title: Text("Usuario $index"),

                  subtitle: Text("Estudiante"),

                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 1, child: Text("Editar")),

                      const PopupMenuItem(value: 2, child: Text("Eliminar")),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
