import 'package:flutter/material.dart';
import 'package:ucad_parki/utils/app_colors.dart';
import 'package:ucad_parki/widgets/input_ucad.dart';
import 'package:ucad_parki/widgets/boton_ucad.dart';
import 'package:ucad_parki/widgets/label_ucad.dart';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final carnetCtrl = TextEditingController();
  final codigoCtrl = TextEditingController();

  String tipoUsuario = "Estudiante";
  String? facultad;
  String? carrera;

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

  bool validarCorreo(String correo) {
    return correo.endsWith("@ucad.edu.sv");
  }

  bool validarPassword(String pass) {
    return pass.length >= 8;
  }

  void registrar() {
    if (!validarCorreo(correoCtrl.text)) {
      mostrar("Correo debe ser institucional @ucad.edu.sv");
      return;
    }

    if (!validarPassword(passCtrl.text)) {
      mostrar("La contraseña debe tener al menos 8 caracteres");
      return;
    }

    if (tipoUsuario == "Estudiante" && (facultad == null || carrera == null)) {
      mostrar("Selecciona facultad y carrera");
      return;
    }

    if (tipoUsuario != "Estudiante" && codigoCtrl.text.isEmpty) {
      mostrar("Debes ingresar tu código institucional");
      return;
    }

    mostrar("Registro exitoso 🎉");
  }

  void mostrar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azul,
      appBar: AppBar(title: Text("Registro"), backgroundColor: AppColors.azul),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelUcad(texto: "Nombre"),
            InputUcad(hint: "Ingresa tu nombre", controller: nombreCtrl),

            SizedBox(height: 15),

            LabelUcad(texto: "Apellidos"),
            InputUcad(hint: "Ingresa tus apellidos", controller: apellidoCtrl),

            SizedBox(height: 15),

            LabelUcad(texto: "Correo"),
            InputUcad(hint: "correo@ucad.edu.sv", controller: correoCtrl),

            SizedBox(height: 15),

            LabelUcad(texto: "Contraseña"),
            InputUcad(
              hint: "Mínimo 8 caracteres",
              isPassword: true,
              controller: passCtrl,
            ),

            SizedBox(height: 20),

            // 👤 TIPO USUARIO
            LabelUcad(texto: "Tipo de usuario"),
            DropdownButtonFormField(
              value: tipoUsuario,
              items: [
                "Estudiante",
                "Docente",
                "Empleado",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => tipoUsuario = v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            SizedBox(height: 20),

            // 🎓 ESTUDIANTE
            if (tipoUsuario == "Estudiante") ...[
              LabelUcad(texto: "Facultad"),
              DropdownButtonFormField(
                value: facultad,
                items: carrerasPorFacultad.keys
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    facultad = v;
                    carrera = null;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              SizedBox(height: 15),

              if (facultad != null)
                DropdownButtonFormField(
                  value: carrera,
                  items: carrerasPorFacultad[facultad]!
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => carrera = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Selecciona carrera",
                  ),
                ),

              SizedBox(height: 15),

              LabelUcad(texto: "Carnet"),
              InputUcad(hint: "Ej: 2020-1234", controller: carnetCtrl),
            ],

            // 👨‍🏫 DOCENTE / EMPLEADO
            if (tipoUsuario != "Estudiante") ...[
              LabelUcad(texto: "Código institucional"),
              InputUcad(
                hint: "Código proporcionado por la universidad",
                controller: codigoCtrl,
              ),
            ],

            SizedBox(height: 25),

            BotonUcad(
              texto: "Registrarse",
              color: AppColors.amarillo,
              onPressed: registrar,
            ),

            SizedBox(height: 15),

            Center(
              child: Text(
                "UCAD Parki ©",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
