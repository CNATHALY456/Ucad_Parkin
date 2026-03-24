class Transporte {
  String placa;
  String tipo; // carro, moto, bicicleta
  String duenio;
  String horaEntrada;
  String horaSalida;
  bool activo;

  Transporte({
    required this.placa,
    required this.tipo,
    required this.duenio,
    required this.horaEntrada,
    required this.horaSalida,
    required this.activo,
  });
}
