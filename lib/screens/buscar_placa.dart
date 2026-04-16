import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Agregar esta dependencia en pubspec.yaml

class BuscarPlaca extends StatefulWidget {
  @override
  _BuscarPlacaState createState() => _BuscarPlacaState();
}

class _BuscarPlacaState extends State<BuscarPlaca> {
  final supabase = Supabase.instance.client;
  TextEditingController buscador = TextEditingController();

  List<Map<String, dynamic>> lista = [];
  List<Map<String, dynamic>> filtrados = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  //CONSULTA CON JOIN: Traemos datos del ticket y el nombre del usuario
  void cargarDatos() async {
    try {
      // Usamos 'usuarios(nombres)' para traer el nombre asociado vía la FK id_usuario
      final data = await supabase
          .from('tickets')
          .select('*, usuarios(nombres, telefono)') 
          .order('fecha_hora_entrada', ascending: false);

      setState(() {
        lista = List<Map<String, dynamic>>.from(data);
        filtrados = lista;
        cargando = false;
      });
    } catch (e) {
      print("Error en Join: $e");
      setState(() => cargando = false);
    }
  }

  void filtrar(String texto) {
    setState(() {
      filtrados = lista.where((v) {
        final obs = (v['observaciones'] ?? "").toString().toLowerCase();
        final nombre = (v['usuarios']?['nombres'] ?? "").toString().toLowerCase();
        return obs.contains(texto.toLowerCase()) || nombre.contains(texto.toLowerCase());
      }).toList();
    });
  }

  //FUNCIÓN PARA LLAMAR O CONTACTAR
  void contactarUsuario(String? telefono) async {
    if (telefono == null || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No hay teléfono registrado para este usuario")),
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: telefono);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(title: Text("Historial UCAD"), backgroundColor: AppColors.azul, elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: buscador,
                onChanged: filtrar,
                decoration: InputDecoration(
                  hintText: "Buscar placa o nombre...",
                  prefixIcon: Icon(Icons.search, color: AppColors.azul),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: cargando
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) => tarjetaExpandible(filtrados[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tarjetaExpandible(Map<String, dynamic> v) {
    bool esActivo = v['estado_ticket'] == 'activo';
    String nombreUsuario = v['usuarios']?['nombres'] ?? "Usuario General";
    String telefono = v['usuarios']?['telefono'] ?? "";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          leading: Icon(
            (v['metodo_ingreso'] == 'QR') ? Icons.qr_code : Icons.directions_car,
            color: AppColors.azul,
            size: 30,
          ),
          title: Text(
            v['observaciones'] ?? "SIN PLACA",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azul),
          ),
          subtitle: Text(
            esActivo ? "• En parqueo" : "• Finalizado",
            style: TextStyle(color: esActivo ? Colors.green : Colors.red, fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DUEÑO REGISTRADO:", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(nombreUsuario, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => contactarUsuario(telefono),
                        icon: Icon(Icons.phone, color: Colors.green),
                        style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("DETALLES DEL TICKET", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text("ID Ticket: #${v['id_ticket']}"),
                  Text("Entrada: ${v['fecha_hora_entrada']}"),
                  if (!esActivo) Text("Salida: ${v['fecha_hora_salida']}"),
                  SizedBox(height: 10),
                  // BOTÓN DE ACCIÓN RÁPIDA
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Aquí podrías navegar a la pantalla de pago o recibo
                      },
                      icon: Icon(Icons.receipt_long),
                      label: Text("Ver Recibo Completo"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
