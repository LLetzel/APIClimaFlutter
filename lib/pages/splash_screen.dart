import 'dart:async';
import 'package:climatempo/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<IconData> icons = [
    FontAwesomeIcons.sun,
    FontAwesomeIcons.cloud,
    FontAwesomeIcons.cloudRain,
    FontAwesomeIcons.snowflake,
    FontAwesomeIcons.bolt,
    FontAwesomeIcons.wind,
  ];
  int currentIconIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(); // Faz a animação continuar em loop.

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted) {
        setState(() {
          currentIconIndex = (currentIconIndex + 1) % icons.length;
        });
      }
    });

    // Navega para a próxima página após 5 segundos.
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WeatherPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Icon(
              icons[currentIconIndex],
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
