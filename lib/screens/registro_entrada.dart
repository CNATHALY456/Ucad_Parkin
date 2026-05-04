import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrarEntrada extends StatefulWidget {
  @override
  _RegistrarEntradaState createState() => _RegistrarEntradaState();
}

class _RegistrarEntradaState extends State<RegistrarEntrada> {
  final supabase = Supabase.instance.client;
  TextEditingController placaCtrl = TextEditingController();
  
  bool mostrarFormulario = false;
  bool cargando = false;
  Map<String, dynamic>? ticketActivo;

  // --- 1. READ: Buscar ticket activo ---
  void verificarPlaca() async {
    if (placaCtrl.text.isEmpty) return;
    setState(() => cargando = true);
    
    try {
      final response = await supabase
          .from('tickets')
          .select()
          .eq('estado_ticket', 'activo')
          .ilike('observaciones', '%${placaCtrl.text}%')
          .maybeSingle();

      setState(() {
        ticketActivo = response;
        mostrarFormulario = (response == null);
        cargando = false;
      });
    } catch (e) {
      _showSnack("Error al buscar: $e", Colors.red);
    }
  }

  // --- 2. CREATE: Insertar nuevo ticket ---
  void registrarEntrada() async {
    try {
      final nuevaEntrada = await supabase.from('tickets').insert({
        'fecha_hora_entrada': DateTime.now().toIso8601String(),
        'estado_ticket': 'activo',
        'metodo_ingreso': 'manual',
        'observaciones': 'PLACA: ${placaCtrl.text.toUpperCase()}',
      }).select().single(); // Traemos el registro creado para tener el ID

      setState(() {
        ticketActivo = nuevaEntrada;
        mostrarFormulario = false;
      });
      _showSnack("Entrada registrada con éxito", Colors.green);
    } catch (e) {
      _showSnack("Error al registrar: $e", Colors.red);
    }
  }

  // --- 3. UPDATE: Registrar salida (Finalizar ticket) ---
  void registrarSalida() async {
    if (ticketActivo == null) return;

    try {
      await supabase.from('tickets').update({
        'estado_ticket': 'finalizado',
        'fecha_hora_salida': DateTime.now().toIso8601String(),
      }).eq('id', ticketActivo!['id']); // Usamos el ID único

      setState(() {
        ticketActivo = null;
        placaCtrl.clear();
      });
      _showSnack("Salida registrada. Ticket finalizado.", Colors.blue);
    } catch (e) {
      _showSnack("Error al actualizar: $e", Colors.red);
    }
  }

  // --- 4. DELETE: Eliminar registro (Corrección de error) ---
  void eliminarTicket() async {
    if (ticketActivo == null) return;

    try {
      await supabase.from('tickets').delete().eq('id', ticketActivo!['id']);
      
      setState(() {
        ticketActivo = null;
        placaCtrl.clear();
      });
      _showSnack("Registro eliminado correctamente", Colors.orange);
    } catch (e) {
      _showSnack("Error al eliminar: $e", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD UCAD Parki")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: placaCtrl, decoration: InputDecoration(labelText: "Placa")),
            ElevatedButton(onPressed: verificarPlaca, child: Text("Verificar")),
            
            if (mostrarFormulario) 
              ElevatedButton(onPressed: registrarEntrada, child: Text("CREAR: Registrar Entrada")),

            if (ticketActivo != null) ...[
              _buildTicketCard(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: registrarSalida, 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("UPDATE: Salida"),
                  ),
                  ElevatedButton(
                    onPressed: eliminarTicket, 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("DELETE: Borrar"),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: ListTile(
        title: Text(ticketActivo!['observaciones']),
        subtitle: Text("Entrada: ${ticketActivo!['fecha_hora_entrada']}"),
      ),
    );
  }
}