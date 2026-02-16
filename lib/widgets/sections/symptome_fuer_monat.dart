import 'package:cedmate/widgets/forms/symptom_erfassen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/symptom_service.dart';
import '../../models/symptom.dart';
import '../layout/EintraegeFuerMonat.dart';

class SymptomeFuerMonat extends StatelessWidget {
  const SymptomeFuerMonat({super.key});

  @override
  Widget build(BuildContext context) {
    final symptomService = context.read<SymptomService>();

    return EintraegeFuerMonat<Symptom>(
      title: 'Alle Symptome',
      streamProvider: symptomService.ladeFuerMonatJahr,
      itemBuilder: (context, symptom, index) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: Text('${index + 1})'),
            title: Text(symptom.bezeichnung),
            subtitle: Text(
              'Intensität: ${symptom.intensitaet} • Dauer: ${symptom.dauerInMinuten} Min',
            ),
            trailing: Text(
              '${symptom.startZeit.day}.${symptom.startZeit.month}.${symptom.startZeit.year}\n'
              '${symptom.startZeit.hour}:${symptom.startZeit.minute.toString().padLeft(2, '0')} Uhr',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.right,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SymptomErfassen(symptom: symptom),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
