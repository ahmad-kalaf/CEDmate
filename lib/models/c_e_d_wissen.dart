import 'package:cloud_firestore/cloud_firestore.dart';

enum WissenKategorie { ernaehrung, bewegung, psyche, alltag }

enum WissenFormat { artikel, video, checkliste }

enum WissenSpecialIcon { none, communityFaq, arztAntwort }

class CEDWissen {
  final String id;
  final String titel;
  final String beschreibung;
  final WissenKategorie kategorie;
  final WissenFormat format;
  final String? contentUrl; // Für Video / Artikel-Links
  final String? contentText; // Für Artikeltexte in der App
  final List<String>? fachgesellschaftLinks;
  final WissenSpecialIcon specialIcon;
  final DateTime? createdAt;

  CEDWissen({
    required this.id,
    required this.titel,
    required this.beschreibung,
    required this.kategorie,
    required this.format,
    this.contentUrl,
    this.contentText,
    this.fachgesellschaftLinks,
    this.specialIcon = WissenSpecialIcon.none,
    this.createdAt,
  });

  factory CEDWissen.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CEDWissen(
      id: doc.id,
      titel: data['titel'],
      beschreibung: data['beschreibung'],
      kategorie: WissenKategorie.values.firstWhere(
        (e) => e.name == data['kategorie'],
      ),
      format: WissenFormat.values.firstWhere((e) => e.name == data['format']),
      contentUrl: data['contentUrl'],
      contentText: data['contentText'],
      fachgesellschaftLinks: (data['fachgesellschaftLinks'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      specialIcon: WissenSpecialIcon.values.firstWhere(
        (e) => e.name == (data['specialIcon'] ?? 'none'),
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titel': titel,
      'beschreibung': beschreibung,
      'kategorie': kategorie.name,
      'format': format.name,
      'contentUrl': contentUrl,
      'contentText': contentText,
      'fachgesellschaftLinks': fachgesellschaftLinks,
      'specialIcon': specialIcon.name,
    };
  }
}
