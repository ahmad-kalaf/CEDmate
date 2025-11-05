import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/utils/monat_jahr_auswahl.dart';
import 'package:cedmate/widgets/stuhlgang_notieren.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StuhlgangEintraegeFuerMonat extends StatefulWidget {
  const StuhlgangEintraegeFuerMonat({super.key});

  @override
  State<StuhlgangEintraegeFuerMonat> createState() =>
      _StuhlgangEintraegeFuerMonatState();
}

class _StuhlgangEintraegeFuerMonatState
    extends State<StuhlgangEintraegeFuerMonat> {
  DateTime _filterDatum = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final stuhlgangService = context.read<StuhlgangService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alle Stuhlgang-Einträge')),
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
            child: StreamBuilder<List<Stuhlgang>>(
              stream: stuhlgangService.ladeFuerMonatJahr(
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

                final eintraege = snapshot.data!;

                if (eintraege.isEmpty) {
                  return const Center(
                    child: Text('Keine Einträge in diesem Monat.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: eintraege.length,
                  itemBuilder: (context, index) {
                    final s = eintraege[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: InkWell(
                        onTap: () async {
                          final bool? bearbeitenBestaetigt = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Eintrag ${index + 1} bearbeiten'),
                              content: const Text(
                                'Möchtest du die Eintragdetails bearbeiten?',
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
                                builder: (_) => StuhlgangNotieren(stuhlgang: s),
                              ),
                            );
                          }
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Text('${index + 1})'),
                            title: Text(s.konsistenz.name),
                            subtitle: Text(
                              'Häufigkeit pro Tag: ${s.haeufigkeit}',
                            ),
                            trailing: Text(
                              '${s.eintragZeitpunkt.day}.${s.eintragZeitpunkt.month}.${s.eintragZeitpunkt.year}\n'
                              '${s.eintragZeitpunkt.hour}:${s.eintragZeitpunkt.minute.toString().padLeft(2, '0')} Uhr',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.grey),
                            ),
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
