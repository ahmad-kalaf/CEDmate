import 'package:cedmate/widgets/symptom_erfassen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/symptom.dart';
import '../services/symptom_service.dart';

class SymptomeFuerDatum extends StatefulWidget {
  final DateTime filterDatum;

  const SymptomeFuerDatum({super.key, required this.filterDatum});

  @override
  State<SymptomeFuerDatum> createState() => _SymptomeFuerDatumState();
}

class _SymptomeFuerDatumState extends State<SymptomeFuerDatum> {
  @override
  Widget build(BuildContext context) {
    final symptomService = context.read<SymptomService>();

    return StreamBuilder<List<Symptom>>(
      stream: symptomService.ladeFuerDatum(widget.filterDatum),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Fehler: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Einträge gefunden.'));
        }

        final symptome = snapshot.data!;

        if (symptome.isEmpty) {
          return const Center(child: Text('Keine Einträge in diesem Monat.'));
        }

        final String uhrSymbol = String.fromCharCode(0x1F570);

        return ListView.builder(
          itemCount: symptome.length,
          shrinkWrap: true,
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
                  child: SizedBox(
                    width: 250,
                    child: Column(
                      children: [
                        Text(
                          '${s.startZeit.day}.${s.startZeit.month}.${s.startZeit.year}'
                          ' $uhrSymbol '
                          '${s.startZeit.hour}:${s.startZeit.minute} Uhr',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Dauer: ${s.dauerInMinuten} Min',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        ListTile(
                          title: Text(s.bezeichnung),
                          subtitle: Text('Intensität: ${s.intensitaet}'),
                        ),
                        // Notiz anzeigen, falls vorhanden
                        if (s.notizen != null && s.notizen!.isNotEmpty) ...[
                          Divider(thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Notiz: ${s.notizen}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
