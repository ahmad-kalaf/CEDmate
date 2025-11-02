import 'package:flutter/material.dart';

class DatenExportieren extends StatelessWidget {
  const DatenExportieren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daten exportieren')),
      body: Center(
        child: Text(
          'Diese Funktion wird noch entwickelt.\nHier kann man später seine'
          ' Daten als Vorbereitung für den Arztbesuch exportieren.',
        ),
      ),
    );
  }
}
