import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';

class DatenExportieren extends StatelessWidget {
  const DatenExportieren({super.key});

  @override
  Widget build(BuildContext context) {
    return CEDLayout(
      title: 'Daten exportieren',
      child: Center(
        child: Text(
          'Diese Funktion wird noch entwickelt.\nHier kann man später seine'
          ' Daten als Vorbereitung für den Arztbesuch exportieren.',
        ),
      ),
    );
  }
}
