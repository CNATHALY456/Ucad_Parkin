import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BuscarPlaca extends StatefulWidget {
  const BuscarPlaca({super.key});

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

  void cargarDatos() async {
    try {
      final data = await supabase
          .from('tickets')
          .select('*, usuarios(nombres, telefono)') 
          .order('fecha_hora_entrada', ascending: false);

      if (mounted) {
        setState(() {
          lista = List<Map<String, dynamic>>.from(data);
          filtrados = lista;
          cargando = false;
        });
      }
    } catch (e) {
      debugPrint("Error en Join: $e");
      if (mounted) setState(() => cargando = false);
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

  // --- FUNCIÓN PARA LLAMADA ---
  void contactarUsuario(String? telefono) async {
    if (telefono == null || telefono.isEmpty) {
      _errorMensaje("No hay teléfono registrado");
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: telefono);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // --- FUNCIÓN PARA WHATSAPP ---
  void enviarWhatsapp(String? telefono) async {
    if (telefono == null || telefono.isEmpty) {
      _errorMensaje("No hay teléfono registrado");
      return;
    }

    // Limpia el número y asegura el código 503
    final soloNumeros = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    final numeroFinal = soloNumeros.startsWith('503') ? soloNumeros : '503$soloNumeros';

    final Uri whatsappUri = Uri.parse("https://wa.me/$numeroFinal?text=Hola, te saludo de la caseta de vigilancia de UCAD.");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _errorMensaje("No se pudo abrir WhatsApp");
    }
  }

  void _errorMensaje(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ConfigProvider>(context).isDarkMode;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.azul,
      appBar: AppBar(
        title: const Text("Historial UCAD", style: TextStyle(color: Colors.white)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.azul,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: buscador,
                onChanged: filtrar,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Buscar placa o nombre...",
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  prefixIcon: Icon(Icons.search, color: isDark ? AppColors.amarillo : AppColors.azul),
                  filled: true, 
                  fillColor: isDark ? theme.surface : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), 
                    borderSide: BorderSide.none
                  ),
                ),
              ),
            ),
            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator(color: AppColors.amarillo))
                  : ListView.builder(
                      itemCount: filtrados.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) => tarjetaExpandible(filtrados[index], isDark, theme),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tarjetaExpandible(Map<String, dynamic> v, bool isDark, ColorScheme theme) {
    bool esActivo = v['estado_ticket'] == 'activo';
    String nombreUsuario = v['usuarios']?['nombres'] ?? "Usuario General";
    String telefono = v['usuarios']?['telefono'] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? theme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          iconColor: isDark ? AppColors.amarillo : AppColors.azul,
          collapsedIconColor: isDark ? Colors.white54 : Colors.grey,
          leading: Icon(
            (v['metodo_ingreso'] == 'QR') ? Icons.qr_code : Icons.directions_car,
            color: isDark ? AppColors.amarillo : AppColors.azul,
            size: 30,
          ),
          title: Text(
            v['observaciones'] ?? "SIN PLACA",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : AppColors.azul
            ),
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
                  Divider(color: isDark ? Colors.white10 : Colors.grey[300]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DUEÑO REGISTRADO:", 
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey)
                            ),
                            Text(
                              nombreUsuario, 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87
                              )
                            ),
                          ],
                        ),
                      ),
                      // --- BOTONES DE CONTACTO ---
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => enviarWhatsapp(telefono),
                            icon: const Icon(Icons.chat, color: Colors.green),
                            style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => contactarUsuario(telefono),
                            icon: const Icon(Icons.phone, color: Colors.blue),
                            style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.1)),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  _datoDetalle("ID Ticket", "#${v['id_ticket']}", isDark),
                  _datoDetalle("Entrada", "${v['fecha_hora_entrada']}", isDark),
                  if (!esActivo) _datoDetalle("Salida", "${v['fecha_hora_salida']}", isDark),
                  
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.receipt_long),
                      label: const Text("Ver Recibo Completo"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppColors.amarillo : AppColors.azul,
                        side: BorderSide(color: isDark ? AppColors.amarillo : AppColors.azul),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

  Widget _datoDetalle(String titulo, String valor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
          children: [
            TextSpan(text: "$titulo: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }
}