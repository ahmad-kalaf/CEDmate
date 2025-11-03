import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/widgets/stuhlgang_notieren.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlleStuhlgangEintraege extends StatefulWidget {
  const AlleStuhlgangEintraege({super.key});

  @override
  State<AlleStuhlgangEintraege> createState() => _AlleStuhlgangEintraegeState();
}

class _AlleStuhlgangEintraegeState extends State<AlleStuhlgangEintraege> {
  @override
  Widget build(BuildContext context) {
    final stuhlgangService = context.read<StuhlgangService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alle Symptome')),
      body: StreamBuilder<List<Stuhlgang>>(
        stream: stuhlgangService.ladeAlle(),
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
            return const Center(child: Text('Keine Einträge gefunden.'));
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
                        title: Text('Eintrag ${index + 1} bearbeiten'),
                        content: const Text(
                          'Möchtest du die Eintragdetails des Stuhlgangs bearbeiten?',
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
                          builder: (context) => StuhlgangNotieren(stuhlgang: s),
                        ),
                      );
                    }
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text(s.konsistenz.name),
                          subtitle: Text(
                            'Häufigkeit pro Tag: ${s.haeufigkeit}',
                          ),
                          trailing: Text(
                            '${s.eintragZeitpunkt.day}.${s.eintragZeitpunkt.month}.${s.eintragZeitpunkt.year}'
                            '\n'
                            '${s.eintragZeitpunkt.hour}:${s.eintragZeitpunkt.minute} Uhr',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          leading: Text('${index + 1})'),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Notizen: ${s.notizen ?? "Keine"}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                          ),
                        ),
                      ],
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
