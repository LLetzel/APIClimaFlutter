import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// Traduções de clima
const Map<String, String> traducaoClima = {
  'thunderstorm with light rain': 'trovoada com chuva fraca',
  'thunderstorm with rain': 'trovoada com chuva',
  'thunderstorm with heavy rain': 'trovoada com chuva forte',
  'light thunderstorm': 'trovoada leve',
  'thunderstorm': 'trovoada',
  'heavy thunderstorm': 'forte tempestade',
  'ragged thunderstorm': 'tempestade irregular',
  'thunderstorm with light drizzle': 'trovoada com leve garoa',
  'thunderstorm with drizzle': 'trovoada com garoa',
  'thunderstorm with heavy drizzle': 'trovoada com forte garoa',
  'light intensity drizzle': 'chuvisco de baixa intensidade',
  'drizzle': 'chuvisco',
  'heavy intensity drizzle': 'chuvisco de forte intensidade',
  'light intensity drizzle rain': 'chuvisco de baixa intensidade com chuva',
  'drizzle rain': 'chuvisco exponencial',
  'heavy intensity drizzle rain': 'chuva forte com garoa',
  'shower rain and drizzle': 'chuva e garoa',
  'shower drizzle': 'chuvisco forte',
  'light rain': 'chuva leve',
  'clear sky': 'céu limpo',
  'few clouds': 'poucas nuvens',
  'scattered clouds': 'nuvens dispersas',
  'broken clouds': 'nuvens separadas',
  'overcast clouds': 'muitas nuvens',
  'moderate rain': 'chuva moderada',
  'heavy intensity rain': 'chuva de forte intensidade',
  'very heavy rain': 'chuva muito forte',
  'extreme rain': 'chuva extrema',
  'freezing rain': 'chuva congelante',
  'light intensity shower rain': 'banho de chuva de fraca intensidade',
  'shower rain': 'banho de chuva',
  'heavy intensity shower rain': 'banho de chuva de intensidade pesada',
  'ragged shower rain': 'banho de chuva irregular',
  'light snow': 'leve neve',
  'snow': 'neve',
  'heavy snow': 'neve pesada',
  'sleet': 'granizo',
  'light shower sleet': 'neve com granizo leve',
  'shower sleet': 'neve com granizo',
  'light rain and snow': 'chuva fraca e neve',
  'rain and snow': 'chuva e neve',
  'light shower snow': 'chuva leve de neve',
  'shower snow': 'chuva de neve',
  'heavy shower snow': 'forte chuva de neve',
  'mist': 'névoa',
  'smoke': 'fumaça',
  'haze': 'neblina',
  'sand/dust whirls': 'redemoinhos de areia/poeira',
  'fog': 'névoa',
  'sand': 'areia',
  'dust': 'poeira',
  'volcanic ash': 'cinza vulcânica',
  'squalls': 'ventania',
  'tornado': 'tornado',
};

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String city = "Pompeia,";
  String apiKey = "";
  String weather = "Carregando...";
  double temperature = 0;

  @override
  void initState() {
    super.initState();
    loadApiKey().then((_) => fetchWeather());
  }

  Future<void> loadApiKey() async {
    try {
      final String response = await rootBundle.loadString('config.json');
      final data = jsonDecode(response);
      setState(() {
        apiKey = data["apiKey"];
      });
    } catch (e) {
      print("Erro ao carregar config.json: $e");
      setState(() {
        weather = "Erro ao carregar chave da API.";
      });
    }
  }

  Future<void> fetchWeather() async {
    if (apiKey.isEmpty) {
      setState(() {
        weather = "API Key não carregada.";
      });
      return;
    }

    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weatherDescription = data["weather"][0]["description"];
        final translatedWeather =
            traducaoClima[weatherDescription] ?? weatherDescription;

        setState(() {
          weather = translatedWeather;
          temperature = data["main"]["temp"];
        });
      } else {
        setState(() {
          weather = "Erro ao carregar dados da API.";
        });
      }
    } catch (e) {
      print("Erro na conexão com a API: $e");
      setState(() {
        weather = "Erro ao se conectar.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App de Clima"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Cidade: $city",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "Clima: $weather",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "Temperatura: ${temperature.toStringAsFixed(1)}°C",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchWeather,
              child: Text("Atualizar"),
            ),
          ],
        ),
      ),
    );
  }
}
