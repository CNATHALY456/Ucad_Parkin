class Transporte {
  String placa;
  String tipo; // carro, moto
  String duenio;
  String tipoUsuario;
  String horaEntrada;
  String horaSalida;
  bool activo;

  Transporte({
    required this.placa,
    required this.tipo,
    required this.duenio,
    required this.tipoUsuario,
    required this.horaEntrada,
    required this.horaSalida,
    required this.activo,
  });
}
