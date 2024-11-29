import 'package:climatempo/data/model/models.dart';

abstract class IclimaReposity {
  Future<List<ClimaModel>> getClima();
}


class ClimaRepository implements IclimaReposity{
  @override
  Future<List<ClimaModel>> getClima() {
    // TODO: implement getClima
    throw UnimplementedError();
  }
}