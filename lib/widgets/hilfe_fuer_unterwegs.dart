import 'package:flutter/material.dart';

class HilfeFuerUnterwegs extends StatelessWidget {
  const HilfeFuerUnterwegs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hilfe für den Weg')),
      body: Center(
        child: Text(
          'Diese Funktion wird noch entwickelt.\nHier sieht man später eine '
          'Karte mit Toileetten und Restaurants in der Nähe.',
        ),
      ),
    );
  }
}
