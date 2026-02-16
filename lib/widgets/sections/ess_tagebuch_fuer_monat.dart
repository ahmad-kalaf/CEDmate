import 'package:cedmate/models/mahlzeit.dart';
import 'package:cedmate/services/mahlzeit_service.dart';
import 'package:cedmate/widgets/forms/mahlzeit_eintragen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/EintraegeFuerMonat.dart';

class EssTagebuchFuerMonat extends StatelessWidget {
  const EssTagebuchFuerMonat({super.key});

  @override
  Widget build(BuildContext context) {
    final mahlzeitService = context.read<MahlzeitService>();
    void zeigeDialogMitElementen(
      BuildContext context,
      String title,
      List<String> items,
    ) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400, maxWidth: 350),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          leading: const Icon(Icons.circle, size: 8),
                          title: Text(items[i]),
                          dense: true,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Schließen'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return EintraegeFuerMonat<Mahlzeit>(
      title: 'Ess-Tagebuch',
      streamProvider: mahlzeitService.ladeFuerMonatJahr,
      itemBuilder: (context, mahlzeit, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: InkWell(
            onTap: () async {
              final bool? bearbeiten = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Eintrag ${index + 1} bearbeiten'),
                  content: const Text(
                    'Möchtest du die Eintragsdetails bearbeiten?',
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
              if (bearbeiten == true && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MahlzeitEintragen(mahlzeit: mahlzeit),
                  ),
                );
              }
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}) ${mahlzeit.bezeichnung}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${mahlzeit.mahlzeitZeitpunkt.day}.${mahlzeit.mahlzeitZeitpunkt.month}.${mahlzeit.mahlzeitZeitpunkt.year}\n'
                          '${mahlzeit.mahlzeitZeitpunkt.hour}:${mahlzeit.mahlzeitZeitpunkt.minute.toString().padLeft(2, '0')} Uhr',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    if (mahlzeit.notiz?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          mahlzeit.notiz!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (mahlzeit.zutaten != null &&
                            mahlzeit.zutaten!.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () => zeigeDialogMitElementen(
                              context,
                              mahlzeit.bezeichnung,
                              mahlzeit.zutaten!,
                            ),
                            icon: const Icon(Icons.restaurant_menu, size: 18),
                            label: const Text('Zutaten anzeigen'),
                          ),
                        if (mahlzeit.unvertraeglichkeiten != null &&
                            mahlzeit.unvertraeglichkeiten!.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () => zeigeDialogMitElementen(
                              context,
                              mahlzeit.bezeichnung,
                              mahlzeit.unvertraeglichkeiten!,
                            ),
                            icon: const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                            ),
                            label: const Text('Unverträglichkeiten'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
