import 'package:cedmate/widgets/symptom_erfassen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/symptom_service.dart';
import '../models/symptom.dart';

class AlleSymptome extends StatefulWidget {
  const AlleSymptome({super.key});

  @override
  State<AlleSymptome> createState() => _AlleSymptomeState();
}

class _AlleSymptomeState extends State<AlleSymptome> {
  @override
  Widget build(BuildContext context) {
    final symptomService = context.read<SymptomService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alle Symptome')),
      body: StreamBuilder<List<Symptom>>(
        stream: symptomService.getSymptoms(),
        builder: (context, snapshot) {
          // Ladeanzeige
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Fehlerbehandlung
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          // Keine Daten?
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Symptome gefunden.'));
          }

          // Liste rendern
          final symptome = snapshot.data!;

          return ListView.builder(
            itemCount: symptome.length,
            itemBuilder: (context, index) {
              final s = symptome[index];
              return Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () async {
                    final bool? bearbeitenBestaetigt = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Symptom ${index + 1} bearbeiten'),
                        content: const Text(
                          'Möchtest du die Symptomdetails bearbeiten?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Abbrechen'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Ja'),
                          ),
                        ],
                      ),
                    );
                    if (bearbeitenBestaetigt == true) {
                      if (!context.mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SymptomErfassen(symptom: s),
                        ),
                      );
                    }
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(s.bezeichnung),
                      subtitle: Text(
                        'Intensität: ${s.intensitaet} • Dauer: ${s.dauerInMinuten} Min',
                      ),
                      trailing: Text(
                        '${s.startZeit.day}.${s.startZeit.month}.${s.startZeit.year}'
                        '\n'
                        '${s.startZeit.hour}:${s.startZeit.minute} Uhr',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      leading: Text('${index + 1})'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
