import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Traduções de clima, ícones associados e cores de fundo
const Map<String, Map<String, dynamic>> traducaoClima = {
  "thunderstorm with light rain": {
    "texto": "Trovoada com chuva fraca",
    "icone": FontAwesomeIcons.bolt,
    "cores": [Colors.black, Colors.deepPurple]
  },
  "thunderstorm with rain": {
    "texto": "Trovoada com chuva",
    "icone": FontAwesomeIcons.bolt,
    "cores": [Colors.black, Colors.deepPurple]
  },
  "thunderstorm with heavy rain": {
    "texto": "Trovoada com chuva forte",
    "icone": FontAwesomeIcons.bolt,
    "cores": [Colors.black, Colors.deepPurple]
  },
  "light thunderstorm": {
    "texto": "Trovoada leve",
    "icone": FontAwesomeIcons.bolt,
    "cores": [Colors.black, Colors.deepPurple]
  },
  "thunderstorm": {
    "texto": "Trovoada",
    "icone": FontAwesomeIcons.bolt,
    "cores": [Colors.black, Colors.deepPurple]
  },
  "heavy thunderstorm": {
    "texto": "Forte tempestade",
    "icone": FontAwesomeIcons.bolt,
    "cores": [Colors.black, Colors.deepPurple]
  },
  "ragged thunderstorm": {
    "texto": "Tempestade irregular",
    "icone": FontAwesomeIcons.bolt,
    "cores": [Colors.black, Colors.deepPurple]
  },
  "thunderstorm with light drizzle": {
    "texto": "Trovoada com leve garoa",
    "icone": FontAwesomeIcons.bolt,
    "cores": [Colors.black, Colors.deepPurple]
  },
  "light intensity drizzle": {
    "texto": "Chuvisco de baixa intensidade",
    "icone": FontAwesomeIcons.cloudRain,
    "cores": [Colors.blueGrey, Colors.lightBlue]
  },
  "drizzle": {
    "texto": "Chuvisco",
    "icone": FontAwesomeIcons.cloudRain,
    "cores": [Colors.blueGrey, Colors.lightBlue]
  },
  "light rain": {
    "texto": "Chuva leve",
    "icone": FontAwesomeIcons.cloudShowersHeavy,
    "cores": [Colors.blueGrey, Colors.grey]
  },
  "clear sky": {
    "texto": "Céu limpo",
    "icone": FontAwesomeIcons.sun,
    "cores": [Colors.orange, Colors.yellow]
  },
  "few clouds": {
    "texto": "Poucas nuvens",
    "icone": FontAwesomeIcons.cloudSun,
    "cores": [Colors.blue, Colors.lightBlueAccent]
  },
  "scattered clouds": {
    "texto": "Nuvens dispersas",
    "icone": FontAwesomeIcons.cloud,
    "cores": [Colors.grey, Colors.blueGrey]
  },
  "broken clouds": {
    "texto": "Nuvens separadas",
    "icone": FontAwesomeIcons.cloud,
    "cores": [Colors.grey, Colors.blueGrey]
  },
  "shower rain": {
    "texto": "Banho de chuva",
    "icone": FontAwesomeIcons.cloudRain,
    "cores": [Colors.blueGrey, Colors.lightBlue]
  },
  "moderate rain": {
    "texto": "Chuva moderada",
    "icone": FontAwesomeIcons.cloudShowersHeavy,
    "cores": [Colors.blueGrey, Colors.grey]
  },
  "snow": {
    "texto": "Neve",
    "icone": FontAwesomeIcons.snowflake,
    "cores": [Colors.white, Colors.lightBlue]
  },
  "mist": {
    "texto": "Névoa",
    "icone": FontAwesomeIcons.smog,
    "cores": [Colors.grey, Colors.lightBlueAccent]
  },
  "fog": {
    "texto": "Névoa",
    "icone": FontAwesomeIcons.smog,
    "cores": [Colors.grey, Colors.lightBlueAccent]
  },
  "tornado": {
    "texto": "Tornado",
    "icone": FontAwesomeIcons.wind,
    "cores": [Colors.grey, Colors.black]
  }
};

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  String? city = "Pompeia";
  String apiKey = "";
  String? weather = "Carregando...";
  double? temperature = 0;
  IconData weatherIcon = FontAwesomeIcons.cloud;
  List<Color> backgroundColors = [Colors.blue, Colors.lightBlueAccent];
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
    _iconAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
        final translatedWeather =
            traducaoClima[weatherDescription]?['texto'] ?? "Clima desconhecido";
        final translatedIcon = traducaoClima[weatherDescription]?['icone'] ??
            FontAwesomeIcons.cloud;
        final translatedColors = traducaoClima[weatherDescription]?['cores'] ??
            [Colors.blue, Colors.lightBlueAccent];

        setState(() {
          weather = translatedWeather;
          temperature = data["main"]["temp"];
          weatherIcon = translatedIcon;
          backgroundColors = translatedColors;
        });

        _controller.reset();
        _controller.forward(); // Dispara a animação ao atualizar o clima
      } else {
        setState(() {
          weather = "Erro ao carregar dados da API.";
          temperature = null;
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
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            const Text(
              "Weather App",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black45,
      ),
      body: Stack(
        children: [
          // Fundo com gradiente dinâmico
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundColors,
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
                      "$weather",
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
                      temperature != null
                          ? "Temperatura: ${temperature!.toStringAsFixed(1)}°C"
                          : "",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: fetchWeather,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.all(10),
                      shape:
                          const CircleBorder(), // Estilo circular para o botão
                    ),
                    child: const Icon(
                      Icons.refresh,
                      size: 24, // Tamanho do ícone
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
