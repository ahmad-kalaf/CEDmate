import 'package:flutter/material.dart';

class Statistiken extends StatelessWidget {
  const Statistiken({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiken')),
      body: Center(
        child: Text(
          'Diese Funktion wird noch entwickelt.\n'
          'Man kann hier später die bereits erfassten Daten analysieren.',
        ),
      ),
    );
  }
}
