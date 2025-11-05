import 'package:cedmate/widgets/symptom_erfassen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/symptom_service.dart';
import '../models/symptom.dart';
import '../utils/monat_jahr_auswahl.dart';

class AlleSymptome extends StatefulWidget {
  const AlleSymptome({super.key});

  @override
  State<AlleSymptome> createState() => _AlleSymptomeState();
}

class _AlleSymptomeState extends State<AlleSymptome> {
  DateTime _filterDatum = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final symptomService = context.read<SymptomService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alle Symptome')),
      body: Column(
        children: [
          // Fester Filterbereich (nicht scrollbar)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Monat-/Jahrauswahl
                MonatJahrAuswahl(
                  firstDate: DateTime(DateTime.now().year - 100),
                  lastDate: DateTime.now(),
                  showResetButton: true,
                  onChanged: (date) {
                    setState(() => _filterDatum = date);
                  },
                  onReset: (date) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Filter zurückgesetzt auf ${date.month}.${date.year}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Nur die Liste ist scrollbar
          Expanded(
            child: StreamBuilder<List<Symptom>>(
              stream: symptomService.ladeFuerMonatJahr(
                _filterDatum.month,
                _filterDatum.year,
              ),
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
                  return const Center(
                    child: Text('Keine Einträge in diesem Monat.'),
                  );
                }

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
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                                builder: (context) =>
                                    SymptomErfassen(symptom: s),
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
          ),
        ],
      ),
    );
  }
}
