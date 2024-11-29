class ClimaModel {
  final double Temperatura;
  final double Umidade;
  final double VelocidadeVento;
  final String Clima;

  ClimaModel(
      {required this.Temperatura,
      required this.Umidade,
      required this.VelocidadeVento,
      required this.Clima});

   factory ClimaModel.fromMap(Map<String, dynamic> map) {
    return ClimaModel(
        Temperatura: map['temperatura'] * 1.0,
        Umidade: map['umidade'] * 1.0,
        VelocidadeVento: map['velocidadevento'] * 1.0,
        Clima: map['clima']);
  }
}
