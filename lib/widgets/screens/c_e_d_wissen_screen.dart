import 'package:cedmate/widgets/layout/ced_layout.dart';
import 'package:cedmate/widgets/screens/wissen_beitrag_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/c_e_d_wissen.dart';
import '../../services/wissen_service.dart';
import '../../cedmate_colors.dart';

class CEDWissenScreen extends StatelessWidget {
  const CEDWissenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<WissenService>();

    return CEDLayout(
      title: 'CED Wissen',
      // Nur zum Debugen
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.add),
      //     onPressed: () async {
      //       final service = context.read<WissenService>();
      //       await _addDummyData(service);

      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text("Beispielwissen hinzugefügt")),
      //       );
      //     },
      //   ),
      // ],
      child: StreamBuilder<List<CEDWissen>>(
        stream: service.alleWissen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Keine Einträge vorhanden.'));
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final w = list[index];
              return _WissenCard(
                wissen: w,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WissenBeitragScreen(beitrag: w),
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

class _WissenCard extends StatelessWidget {
  final CEDWissen wissen;
  final VoidCallback? onTap;

  const _WissenCard({required this.wissen, this.onTap});

  IconData _iconForFormat(WissenFormat f) {
    switch (f) {
      case WissenFormat.video:
        return Icons.videocam;
      case WissenFormat.artikel:
        return Icons.article;
      case WissenFormat.checkliste:
        return Icons.check_box;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: CEDColors.background.withValues(alpha: 0.3),
                child: Icon(
                  _iconForFormat(wissen.format),
                  size: 20,
                  color: CEDColors.iconPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wissen.titel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      wissen.beschreibung,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text(
                            wissen.kategorie.name,
                            style: TextStyle(color: CEDColors.surface),
                          ),
                        ),
                        if (wissen.fachgesellschaftLinks != null &&
                            wissen.fachgesellschaftLinks!.isNotEmpty)
                          Chip(
                            label: Text(
                              '${wissen.fachgesellschaftLinks!.length} '
                              '${wissen.fachgesellschaftLinks!.length == 1 ? 'Quelle' : 'Quellen'}',
                              style: TextStyle(color: CEDColors.surface),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _addDummyData(WissenService service) async {
  final video1 = CEDWissen(
    id: '',
    titel: 'CED & Ernährung – Grundlagen erklärt',
    beschreibung:
        'Kurzes Einführungsvideo zu Ernährungsempfehlungen bei Morbus Crohn und Colitis ulcerosa.',
    kategorie: WissenKategorie.ernaehrung,
    format: WissenFormat.video,
    contentUrl: 'https://example.com/video/ernaehrung',
    contentText:
        'In diesem Video werden grundlegende Zusammenhänge zwischen Ernährung und CED erklärt.',
    fachgesellschaftLinks: ['https://www.dccv.de'],
  );

  final video2 = CEDWissen(
    id: '',
    titel: 'Stress, Psyche und CED',
    beschreibung:
        'Warum Stress einen Einfluss auf den Krankheitsverlauf haben kann.',
    kategorie: WissenKategorie.psyche,
    format: WissenFormat.video,
    contentUrl: 'https://example.com/video/psyche',
    contentText:
        'Psychische Belastung kann Symptome verstärken. Das Video erklärt mögliche Mechanismen.',
    fachgesellschaftLinks: ['https://www.dgvs.de'],
  );

  final artikel = CEDWissen(
    id: '',
    titel: 'Bewegung im Alltag mit CED',
    beschreibung:
        'Wie viel Bewegung ist sinnvoll und worauf sollte man achten?',
    kategorie: WissenKategorie.bewegung,
    format: WissenFormat.artikel,
    contentText: '''
Regelmäßige, moderate Bewegung kann sich positiv auf das allgemeine Wohlbefinden auswirken.

Empfohlen werden:
- Spaziergänge
- leichtes Krafttraining
- Dehnübungen

Wichtig ist, auf die eigenen Grenzen zu achten und Bewegung an den aktuellen Gesundheitszustand anzupassen.
''',
    fachgesellschaftLinks: [
      'https://www.awmf.org',
      'https://www.bundesgesundheitsministerium.de/service/publikationen/details/nationale-empfehlungen-fuer-bewegung-und-bewegungsfoerderung.html',
    ],
  );

  final checkliste = CEDWissen(
    id: '',
    titel: 'Alltag im Schub – Checkliste',
    beschreibung:
        'Hilfreiche Punkte, die im Alltag während eines Schubs beachtet werden können.',
    kategorie: WissenKategorie.alltag,
    format: WissenFormat.checkliste,
    contentText: '''
□ Ausreichend trinken  
□ Leicht verdauliche Nahrung wählen  
□ Stress reduzieren  
□ Medikamente regelmäßig einnehmen  
□ Bei Verschlechterung ärztlichen Rat einholen
''',
    fachgesellschaftLinks: ['https://www.patienten-information.de'],
  );

  await service.neuesWissenEintragen(video1);
  await service.neuesWissenEintragen(video2);
  await service.neuesWissenEintragen(artikel);
  await service.neuesWissenEintragen(checkliste);
}
