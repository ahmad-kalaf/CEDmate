import 'package:cedmate/models/stimmung.dart';
import 'package:cedmate/services/stimmung_service.dart';
import 'package:cedmate/widgets/stimmung_notieren.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeelenLogFuerDatum extends StatefulWidget {
  final DateTime filterDatum;

  const SeelenLogFuerDatum({super.key, required this.filterDatum});

  @override
  State<SeelenLogFuerDatum> createState() => _SeelenLogFuerDatumState();
}

class _SeelenLogFuerDatumState extends State<SeelenLogFuerDatum> {
  void _zeigeDialogMitTags(BuildContext context, List<String> tags) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 350),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tags',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: const Icon(Icons.label, size: 18),
                      title: Text(tags[i]),
                      dense: true,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final stimmungService = context.read<StimmungService>();

    return StreamBuilder<List<Stimmung>>(
      stream: stimmungService.ladeStimmungenFuerDatum(widget.filterDatum),
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

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: eintraege.length,
          itemBuilder: (context, index) {
            final stimmung = eintraege[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
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
                        builder: (_) => StimmungNotieren(stimmung: stimmung),
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
                                '${index + 1}) ${stimmung.level.name.toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${stimmung.stimmungsZeitpunkt.day}.${stimmung.stimmungsZeitpunkt.month}.${stimmung.stimmungsZeitpunkt.year}\n'
                              '${stimmung.stimmungsZeitpunkt.hour}:${stimmung.stimmungsZeitpunkt.minute.toString().padLeft(2, '0')} Uhr',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.speed,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Stresslevel: ${stimmung.stresslevel}/10',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        if (stimmung.notiz?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              stimmung.notiz!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (stimmung.tags != null && stimmung.tags!.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () =>
                                _zeigeDialogMitTags(context, stimmung.tags!),
                            icon: const Icon(Icons.tag, size: 18),
                            label: const Text('Tags anzeigen'),
                          ),
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
