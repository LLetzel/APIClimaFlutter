import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _cityController = TextEditingController();   

  List<String> recentCities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clima'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Digite a cidade',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para buscar o clima da cidade
                String city = _cityController.text;
                // ...
                setState(() {
                  recentCities.add(city);
                });
              },
              child: Text('Buscar'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentCities.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(recentCities[index]),
                    // Aqui você adicionaria as informações climáticas
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  }

