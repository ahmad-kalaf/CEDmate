import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/c_e_d_wissen.dart';
import '../services/wissen_service.dart';
import 'c_e_d_colors.dart';

class CEDWissenScreen extends StatelessWidget {
  const CEDWissenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<WissenService>();

    return CEDLayout(
      title: 'CED Wissen',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final service = context.read<WissenService>();
            await _addDummyData(service);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Beispielwissen hinzugefügt")),
            );
          },
        ),
      ],
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
                onTap: () => _showDetails(context, w),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, CEDWissen w) {
    showAboutDialog(
      context: context,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('PLATZHALTER')],
          ),
        ),
      ],
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
                child: Icon(_iconForFormat(wissen.format), size: 20),
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
                        Chip(label: Text(wissen.kategorie.name)),
                        if (wissen.fachgesellschaftLinks != null &&
                            wissen.fachgesellschaftLinks!.isNotEmpty)
                          Chip(
                            label: Text(
                              '${wissen.fachgesellschaftLinks!.length} Quelle(n)',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (wissen.specialIcon != WissenSpecialIcon.none)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    wissen.specialIcon == WissenSpecialIcon.communityFaq
                        ? Icons.forum
                        : Icons.local_hospital,
                    color: Theme.of(context).colorScheme.primary,
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
  final d1 = CEDWissen(
    id: '',
    titel: "Ernährung – Grundlagen",
    beschreibung: "Tipps zur Ernährung bei CED",
    kategorie: WissenKategorie.ernaehrung,
    format: WissenFormat.artikel,
    contentText: "Ballaststoffe, viel trinken...",
    fachgesellschaftLinks: ["https://dccv.de"],
  );

  final d2 = CEDWissen(
    id: '',
    titel: "Stress & Psyche",
    beschreibung: "Warum Stress einen Einfluss auf CED hat",
    kategorie: WissenKategorie.psyche,
    format: WissenFormat.video,
    contentUrl: "https://youtube.com/xyz",
  );

  await service.neuesWissenEintragen(d1);
  await service.neuesWissenEintragen(d2);
}
