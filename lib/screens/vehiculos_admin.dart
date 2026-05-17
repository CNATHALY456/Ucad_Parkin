import 'package:flutter/material.dart';

class VehiculosAdmin extends StatelessWidget {
  const VehiculosAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,

      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),

            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),

          child: ListTile(
            leading: const Icon(Icons.directions_car, size: 35),

            title: Text("P123-45$index"),

            subtitle: Text("Toyota Corolla"),

            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}
