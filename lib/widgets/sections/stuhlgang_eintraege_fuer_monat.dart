import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/widgets/forms/stuhlgang_notieren.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/EintraegeFuerMonat.dart';

class StuhlgangEintraegeFuerMonat extends StatelessWidget {
  const StuhlgangEintraegeFuerMonat({super.key});

  @override
  Widget build(BuildContext context) {
    final stuhlgangService = context.read<StuhlgangService>();
    return EintraegeFuerMonat<Stuhlgang>(
      title: 'Stuhlgang-Tagebuch',
      streamProvider: stuhlgangService.ladeFuerMonatJahr,
      itemBuilder: (context, stuhlgang, index) {
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

              if (bearbeiten == true) {
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StuhlgangNotieren(stuhlgang: stuhlgang),
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
                title: Text(stuhlgang.konsistenz.name),
                subtitle: Text('Häufigkeit pro Tag: ${stuhlgang.haeufigkeit}'),
                trailing: Text(
                  '${stuhlgang.eintragZeitpunkt.day}.${stuhlgang.eintragZeitpunkt.month}.${stuhlgang.eintragZeitpunkt.year}\n'
                  '${stuhlgang.eintragZeitpunkt.hour}:${stuhlgang.eintragZeitpunkt.minute.toString().padLeft(2, '0')} Uhr',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
