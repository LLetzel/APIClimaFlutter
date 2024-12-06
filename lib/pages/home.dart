import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Traduções de clima e ícones associados
const Map<String, Map<String, dynamic>> traducaoClima = {
  'clear sky': {'texto': 'céu limpo', 'icone': FontAwesomeIcons.sun},
  'few clouds': {'texto': 'poucas nuvens', 'icone': FontAwesomeIcons.cloudSun},
  'scattered clouds': {'texto': 'nuvens dispersas', 'icone': FontAwesomeIcons.cloud},
  'broken clouds': {'texto': 'nuvens separadas', 'icone': FontAwesomeIcons.cloud},
  'shower rain': {'texto': 'banho de chuva', 'icone': FontAwesomeIcons.cloudRain},
  'rain': {'texto': 'chuva', 'icone': FontAwesomeIcons.cloudShowersHeavy},
  'thunderstorm': {'texto': 'trovoada', 'icone': FontAwesomeIcons.bolt},
  'snow': {'texto': 'neve', 'icone': FontAwesomeIcons.snowflake},
  'mist': {'texto': 'névoa', 'icone': FontAwesomeIcons.smog},
};

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with SingleTickerProviderStateMixin {
  String city = "Pompeia";
  String apiKey = "";
  String weather = "Carregando...";
  double temperature = 0;
  IconData weatherIcon = FontAwesomeIcons.cloud;
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _iconAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    loadApiKey().then((_) => fetchWeather());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    setState(() {
      isLoading = true;
    });

    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weatherDescription = data["weather"][0]["description"];
        final translatedWeather = traducaoClima[weatherDescription]?['texto'] ?? "Clima desconhecido";
        final translatedIcon = traducaoClima[weatherDescription]?['icone'] ?? FontAwesomeIcons.cloud;

        setState(() {
          weather = translatedWeather;
          temperature = data["main"]["temp"];
          weatherIcon = translatedIcon;
        });

        _controller.reset();
        _controller.forward(); // Dispara a animação ao atualizar o clima
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateCity(String newCity) {
    setState(() {
      city = newCity;
    });
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "App de Clima",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: Stack(
        children: [
          // Fundo com gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Conteúdo principal
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _iconAnimation,
                    child: Icon(
                      weatherIcon,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onSubmitted: updateCity,
                    decoration: InputDecoration(
                      hintText: "Digite a cidade",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Cidade: $city",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      "Clima: $weather",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      "Temperatura: ${temperature.toStringAsFixed(1)}°C",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: fetchWeather,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Atualizar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
