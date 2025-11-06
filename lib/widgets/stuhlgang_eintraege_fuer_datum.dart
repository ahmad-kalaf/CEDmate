import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/widgets/stuhlgang_notieren.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StuhlgangEintraegeFuerDatum extends StatefulWidget {
  final DateTime filterDatum;

  const StuhlgangEintraegeFuerDatum({super.key, required this.filterDatum});

  @override
  State<StuhlgangEintraegeFuerDatum> createState() =>
      _StuhlgangEintraegeFuerDatumState();
}

class _StuhlgangEintraegeFuerDatumState
    extends State<StuhlgangEintraegeFuerDatum> {
  @override
  Widget build(BuildContext context) {
    final stuhlgangEintraegeService = context.read<StuhlgangService>();

    return StreamBuilder<List<Stuhlgang>>(
      stream: stuhlgangEintraegeService.ladeFuerDatum(widget.filterDatum),
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

        final eintrag = snapshot.data!;

        if (eintrag.isEmpty) {
          return const Center(child: Text('Keine Einträge zu diesem Datum.'));
        }

        final String uhrSymbol = String.fromCharCode(0x1F570);

        return ListView.builder(
          itemCount: eintrag.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final s = eintrag[index];
            return Padding(
              padding: const EdgeInsets.all(10),
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
                  child: SizedBox(
                    width: 250,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${s.eintragZeitpunkt.day}.${s.eintragZeitpunkt.month}.${s.eintragZeitpunkt.year}'
                            ' $uhrSymbol '
                            '${s.eintragZeitpunkt.hour}:${s.eintragZeitpunkt.minute} Uhr',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          Text('Konsistenz: ${s.konsistenz.name}'),
                          Text(
                            'Häufigkeit am Tag: ${s.haeufigkeit.toString()}',
                          ),
                          // Notiz anzeigen, falls vorhanden
                          if (s.notizen != null && s.notizen!.isNotEmpty) ...[
                            Divider(thickness: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                'Notizen: ${s.notizen}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ],
                      ),
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
