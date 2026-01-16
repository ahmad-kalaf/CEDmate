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

  static String _stringOrEmpty(dynamic value) => value is String ? value : '';

  static String? _stringOrNull(dynamic value) => value is String ? value : null;

  static DateTime? _dateTimeOrNull(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static T _enumOrDefault<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null) {
      return fallback;
    }
    return values.firstWhere((e) => e.name == name, orElse: () => fallback);
  }

  factory CEDWissen.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const <String, dynamic>{};

    return CEDWissen(
      id: doc.id,
      titel: _stringOrEmpty(data['titel']),
      beschreibung: _stringOrEmpty(data['beschreibung']),
      kategorie: _enumOrDefault(
        WissenKategorie.values,
        _stringOrNull(data['kategorie']),
        WissenKategorie.ernaehrung,
      ),
      format: _enumOrDefault(
        WissenFormat.values,
        _stringOrNull(data['format']),
        WissenFormat.artikel,
      ),
      contentUrl: _stringOrNull(data['contentUrl']),
      contentText: _stringOrNull(data['contentText']),
      fachgesellschaftLinks: (data['fachgesellschaftLinks'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      specialIcon: _enumOrDefault(
        WissenSpecialIcon.values,
        _stringOrNull(data['specialIcon']) ?? 'none',
        WissenSpecialIcon.none,
      ),
      createdAt: _dateTimeOrNull(data['createdAt']),
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
