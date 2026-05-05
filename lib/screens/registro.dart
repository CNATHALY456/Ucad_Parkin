import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/widgets/input_ucad.dart';
import 'package:ucad_parki/widgets/boton_ucad.dart';
import 'package:ucad_parki/widgets/label_ucad.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final supabase = Supabase.instance.client;

  // Controladores de texto
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final carnetCtrl = TextEditingController();
  final codigoCtrl = TextEditingController();

  String tipoUsuario = "Estudiante";
  String? facultad;
  String? carrera;
  bool cargando = false;

  final Map<String, List<String>> carrerasPorFacultad = {
    "Ciencias Económicas": [
      "Ingeniería en Ciencias de la Computación",
      "Licenciatura en Administración de Empresas",
      "Licenciatura en Contaduría Pública",
    ],
    "Teología": [
      "Licenciatura en Teología - Misionología",
      "Licenciatura en Teología - Ministerio Pastoral",
    ],
    "Ciencias y Humanidades": [
      "Licenciatura en Comunicaciones",
      "Técnico Multimedia",
    ],
    "Jurisprudencia y Ciencias Sociales": [
      "Licenciatura en Ciencias Jurídicas",
    ],
  };

  @override
  void dispose() {
    correoCtrl.dispose();
    passCtrl.dispose();
    nombreCtrl.dispose();
    apellidoCtrl.dispose();
    carnetCtrl.dispose();
    codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> registrar() async {
    // 1. Validaciones de campos
    if (nombreCtrl.text.trim().isEmpty || apellidoCtrl.text.trim().isEmpty) {
      mostrar("Por favor, ingresa tu nombre completo");
      return;
    }

    if (!correoCtrl.text.trim().endsWith("@ucad.edu.sv")) {
      mostrar("El correo debe ser institucional (@ucad.edu.sv)");
      return;
    }

    if (passCtrl.text.trim().length < 8) {
      mostrar("La contraseña debe tener al menos 8 caracteres");
      return;
    }

    if (tipoUsuario == "Estudiante" && (facultad == null || carrera == null)) {
      mostrar("Por favor selecciona facultad y carrera");
      return;
    }

    setState(() => cargando = true);

    try {
      // 2. Registro en Supabase Auth incluyendo METADATOS
      // Esto es lo que permite que el Login funcione sin consultar tablas adicionales
      await supabase.auth.signUp(
         email: correoCtrl.text.trim(),
         password: passCtrl.text.trim(),
         data: {
          'nombres': nombreCtrl.text.trim(),
          'tipo_usuario': tipoUsuario, // Esta variable debe ser "Vigilante" o "Empleado"
        },
      );

      if (mounted) {
        mostrar("¡Cuenta creada con éxito! Por favor inicia sesión.");
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      mostrar(e.message);
    } catch (e) {
      debugPrint("Error Registro: $e");
      mostrar("Ocurrió un error inesperado.");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void mostrar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(
        title: const Text("Crear Cuenta",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.azul,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LabelUcad(texto: "Nombres"),
            InputUcad(hint: "Tus nombres", controller: nombreCtrl),
            const SizedBox(height: 15),
            const LabelUcad(texto: "Apellidos"),
            InputUcad(hint: "Tus apellidos", controller: apellidoCtrl),
            const SizedBox(height: 15),
            const LabelUcad(texto: "Correo Institucional"),
            InputUcad(hint: "usuario@ucad.edu.sv", controller: correoCtrl),
            const SizedBox(height: 15),
            const LabelUcad(texto: "Contraseña"),
            InputUcad(
                hint: "Mínimo 8 caracteres",
                isPassword: true,
                controller: passCtrl),
            const SizedBox(height: 20),
            const LabelUcad(texto: "Tipo de usuario"),
            DropdownButtonFormField<String>(
              value: tipoUsuario,
              dropdownColor: Colors.white,
              items: ["Estudiante", "Docente", "Empleado", "Vigilante"]
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child:
                          Text(e, style: const TextStyle(color: Colors.black))))
                  .toList(),
              onChanged: (v) => setState(() {
                tipoUsuario = v!;
                facultad = null;
                carrera = null;
              }),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            if (tipoUsuario == "Estudiante") ...[
              const LabelUcad(texto: "Facultad"),
              DropdownButtonFormField<String>(
                value: facultad,
                hint: const Text("Selecciona tu Facultad"),
                items: carrerasPorFacultad.keys
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() {
                  facultad = v;
                  carrera = null;
                }),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              if (facultad != null) ...[
                const LabelUcad(texto: "Carrera"),
                DropdownButtonFormField<String>(
                  value: carrera,
                  hint: const Text("Selecciona tu Carrera"),
                  items: carrerasPorFacultad[facultad]!
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => carrera = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 15),
              ],
              const LabelUcad(texto: "Número de Carnet"),
              InputUcad(hint: "Ej: 2024-0001", controller: carnetCtrl),
            ] else ...[
              const LabelUcad(texto: "Código Institucional"),
              InputUcad(hint: "Código de empleado", controller: codigoCtrl),
            ],
            const SizedBox(height: 35),
            cargando
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.amarillo))
                : BotonUcad(
                    texto: "REGISTRARSE",
                    color: AppColors.amarillo,
                    onPressed: registrar,
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}