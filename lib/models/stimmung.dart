import 'package:cloud_firestore/cloud_firestore.dart';

/// Modell für einen Stimmungseintrag im SeelenLog.
/// Enthält Angaben zu Stimmung, Stresslevel, optionalen Notizen,
/// passenden Tags sowie dem Zeitpunkt der Eintragung.
class Stimmung {
  /// Firestore-Dokument-ID des Eintrags.
  final String? id;

  /// Stimmungsausprägung auf einer Skala von 1 bis 5.
  final int level;

  /// Stresslevel auf einer Skala von 1 bis 10.
  final int stresslevel;

  /// Optionale Tagebuchnotiz des Nutzers.
  final String? notiz;

  /// Optionale Liste von Tags zur besseren Einordnung.
  final List<String>? tags;

  /// Zeitpunkt, an dem der Stimmungseintrag vorgenommen wurde.
  final DateTime stimmungsZeitpunkt;

  /// Konstruktor für einen Stimmungseintrag.
  /// Enthält Assertions zur Validierung der zulässigen Wertebereiche.
  Stimmung({
    this.id,
    required this.level,
    required this.stresslevel,
    this.notiz,
    this.tags,
    DateTime? stimmungsZeitpunkt,
  }) : assert(level >= 1 && level <= 5),
       assert(stresslevel >= 1 && stresslevel <= 10),
       stimmungsZeitpunkt = stimmungsZeitpunkt ?? DateTime.now();

  /// Erstellt ein Stimmung-Objekt aus einem Firestore-Dokument.
  /// Beinhaltet defensive Datenverarbeitung für verschiedene Formate.
  factory Stimmung.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    /// Wandelt dynamische Werte sicher in int um.
    int parseInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    /// Wandelt dynamische Listen sicher in eine String-Liste um.
    List<String> toStringList(dynamic value) {
      if (value is List) {
        return value
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return <String>[];
    }

    /// Parst verschiedene Zeitformate in ein DateTime-Objekt um.
    DateTime parseZeit(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {}
      }
      return DateTime.now();
    }

    /// Bereinigt optionale Strings, gibt null zurück, wenn leer.
    String? cleanOptional(dynamic v) {
      final s = (v as String?)?.trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return Stimmung(
      id: doc.id,
      level: parseInt(data['stimmungsLevel'], fallback: 3),
      stresslevel: parseInt(data['stresslevel'], fallback: 5),
      notiz: cleanOptional(data['tagebuch']),
      tags: (data['tags'] != null) ? toStringList(data['tags']) : null,
      stimmungsZeitpunkt: parseZeit(data['stimmungsZeitpunkt']),
    );
  }

  /// Wandelt das Objekt in eine Map um, um es in Firestore zu speichern.
  /// Nur ausgefüllte optionale Werte werden gespeichert.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'stimmungsLevel': level,
      'stresslevel': stresslevel,
      'stimmungsZeitpunkt': Timestamp.fromDate(stimmungsZeitpunkt),
    };

    if (notiz != null && notiz!.trim().isNotEmpty) {
      map['tagebuch'] = notiz;
    }
    if (tags != null && tags!.isNotEmpty) {
      map['tags'] = tags;
    }
    return map;
  }

  /// Erstellt eine Kopie des aktuellen Eintrags,
  /// bei der selektiv einzelne Felder überschrieben werden können.
  Stimmung copyWith({
    String? id,
    int? level,
    int? stresslevel,
    String? tagebuch,
    List<String>? tags,
    DateTime? stimmungsZeitpunkt,
  }) {
    return Stimmung(
      id: id ?? this.id,
      level: level ?? this.level,
      stresslevel: stresslevel ?? this.stresslevel,
      notiz: tagebuch ?? this.notiz,
      tags: tags ?? this.tags,
      stimmungsZeitpunkt: stimmungsZeitpunkt ?? this.stimmungsZeitpunkt,
    );
  }
}
