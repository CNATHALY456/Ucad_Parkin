import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucad_parki/providers/config_provider.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class BuscarPlaca extends StatefulWidget {
  const BuscarPlaca({super.key});

  @override
  _BuscarPlacaState createState() => _BuscarPlacaState();
}

class _BuscarPlacaState extends State<BuscarPlaca> {
  final supabase = Supabase.instance.client;
  TextEditingController buscador = TextEditingController();
  String filtroTexto = "";

  // Formateador de fecha para los detalles
  final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

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

  void enviarWhatsapp(String? telefono) async {
    if (telefono == null || telefono.isEmpty) {
      _errorMensaje("No hay teléfono registrado");
      return;
    }
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
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.azul,
      appBar: AppBar(
        title: const Text("Monitoreo en Tiempo Real", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: buscador,
              onChanged: (val) => setState(() => filtroTexto = val.toLowerCase()),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Buscar placa o propietario...",
                hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                prefixIcon: Icon(Icons.search, color: isDark ? AppColors.amarillo : AppColors.azul),
                filled: true, 
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), 
                  borderSide: BorderSide.none
                ),
              ),
            ),
          ),

          // LISTADO REACTIVO CON STREAM
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // Escuchamos cambios en la tabla tickets
              stream: supabase
                  .from('tickets')
                  .stream(primaryKey: ['id_ticket'])
                  .order('fecha_hora_entrada', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.amarillo));
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error al conectar con la base de datos", style: TextStyle(color: Colors.white70)));
                }

                final todosLosTickets = snapshot.data ?? [];

                // Filtro local basado en el texto del buscador
                final filtrados = todosLosTickets.where((t) {
                  final obs = (t['observaciones'] ?? "").toString().toLowerCase();
                  return obs.contains(filtroTexto);
                }).toList();

                if (filtrados.isEmpty) {
                  return const Center(child: Text("Sin registros que coincidan", style: TextStyle(color: Colors.white38)));
                }

                return ListView.builder(
                  itemCount: filtrados.length,
                  padding: const EdgeInsets.only(bottom: 30),
                  itemBuilder: (context, index) => tarjetaExpandible(filtrados[index], isDark, theme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaExpandible(Map<String, dynamic> v, bool isDark, ColorScheme theme) {
    // LA CLAVE: El estado ahora manda sobre la lógica visual
    bool esActivo = v['estado_ticket'] == 'activo';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: esActivo 
            ? Border.all(color: Colors.green.withOpacity(0.4), width: 1.5) 
            : Border.all(color: Colors.transparent),
        boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          backgroundColor: esActivo ? Colors.green.withOpacity(0.03) : null,
          iconColor: isDark ? AppColors.amarillo : AppColors.azul,
          collapsedIconColor: isDark ? Colors.white54 : Colors.grey,
          leading: CircleAvatar(
            backgroundColor: esActivo ? Colors.green : (isDark ? Colors.white10 : Colors.grey[200]),
            child: Icon(
              esActivo ? Icons.local_parking : Icons.history,
              color: esActivo ? Colors.white : (isDark ? Colors.white38 : Colors.grey),
              size: 20,
            ),
          ),
          title: Text(
            (v['observaciones'] ?? "S/N").toString().toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : AppColors.azul
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: esActivo ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                esActivo ? "ACTIVO" : "FINALIZADO",
                style: TextStyle(
                  color: esActivo ? Colors.green : Colors.red, 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _infoRow("ID Ticket", "#${v['id_ticket']}", Icons.tag, isDark),
                  _infoRow("Entrada", _formatearFecha(v['fecha_hora_entrada']), Icons.login, isDark),
                  if (!esActivo) 
                    _infoRow("Salida", _formatearFecha(v['fecha_hora_salida']), Icons.logout, isDark),
                  
                  const Divider(height: 30),
                  
                  // Botones de Acción (Solo si es un ticket con ID de usuario vinculado)
                  if (v['id_usuario'] != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton("WhatsApp", Icons.chat, Colors.green, () {
                          // Aquí podrías hacer un fetch rápido del teléfono si no viene en el stream
                          _errorMensaje("Abriendo chat...");
                        }),
                        _actionButton("Llamar", Icons.phone, Colors.blue, () {
                          _errorMensaje("Iniciando llamada...");
                        }),
                      ],
                    )
                  else
                    const Text("Registro Manual (Sin contacto)", 
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null) return "Pendiente";
    try {
      final fecha = DateTime.parse(fechaStr).toLocal();
      return formatter.format(fecha);
    } catch (e) {
      return fechaStr;
    }
  }

  Widget _infoRow(String label, String valor, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.amarillo),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(child: Text(valor, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
    );
  }
}