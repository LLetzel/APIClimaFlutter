import 'package:http/http.dart' as http;

abstract class IHttpClima {
  Future get({required String url});
}

class HttpClima implements IHttpClima {
  final clima = http.Client();

  @override
  Future get({required String url}) async {
    return await clima.get(Uri.parse(url));
    throw UnimplementedError();
  }
}
