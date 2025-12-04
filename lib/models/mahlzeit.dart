import 'package:cloud_firestore/cloud_firestore.dart';

/// Modell für eine erfasste Mahlzeit.
/// Enthält Angaben zu Bezeichnung, Zutaten, Notizen,
/// möglichen Unverträglichkeiten sowie dem Zeitpunkt der Mahlzeit.
/// Der Zeitpunkt wird automatisch gesetzt, falls keiner übergeben wurde.
class Mahlzeit {
  /// Firestore-Dokument-ID, optional.
  final String? id;

  /// Bezeichnung der Mahlzeit, z. B. "Hähnchen mit Reis".
  final String bezeichnung;

  /// Liste der Zutaten oder Bestandteile der Mahlzeit.
  final List<String>? zutaten;

  /// Optionale Freitextnotiz zur Mahlzeit.
  final String? notiz;

  /// Optionale Liste an Unverträglichkeiten, die mit der Mahlzeit verbunden sind.
  final List<String>? unvertraeglichkeiten;

  /// Zeitpunkt, an dem die Mahlzeit eingenommen wurde.
  /// Wird automatisch auf die aktuelle Zeit gesetzt, falls nicht übergeben.
  final DateTime mahlzeitZeitpunkt;

  /// Konstruktor zum Erstellen eines Mahlzeit-Objekts.
  Mahlzeit({
    this.id,
    required this.bezeichnung,
    this.zutaten,
    this.notiz,
    this.unvertraeglichkeiten,
    DateTime? mahlzeitZeitpunkt,
  }) : mahlzeitZeitpunkt = mahlzeitZeitpunkt ?? DateTime.now();

  /// Erstellt ein Mahlzeit-Objekt aus einem Firestore-Dokument.
  /// Enthält defensive Logik, um Listen und optionale Strings korrekt einzulesen.
  factory Mahlzeit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Hilfsfunktion zur sicheren Umwandlung dynamischer Listen in String-Listen.
    List<String> toStringList(dynamic value) {
      if (value is List) {
        return value
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return <String>[];
    }

    return Mahlzeit(
      id: doc.id,
      bezeichnung: (data['bezeichnung'] as String?) ?? '',
      zutaten: (data['zutaten'] != null) ? toStringList(data['zutaten']) : null,
      notiz: _bereinigeOptionalenString(data['notizen']),
      unvertraeglichkeiten: (data['unvertraeglichkeiten'] != null)
          ? toStringList(data['unvertraeglichkeiten'])
          : null,
      mahlzeitZeitpunkt: _parseZeitstempel(data['mahlzeitZeitpunkt']),
    );
  }

  /// Wandelt die Mahlzeit in eine Map um, um sie in Firestore zu speichern.
  /// Es werden nur tatsächlich vorhandene Werte gespeichert.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'bezeichnung': bezeichnung,
      'mahlzeitZeitpunkt': Timestamp.fromDate(mahlzeitZeitpunkt),
    };

    if (zutaten != null && zutaten!.isNotEmpty) {
      map['zutaten'] = zutaten;
    }
    if (_istNichtLeer(notiz)) {
      map['notizen'] = notiz;
    }
    if (unvertraeglichkeiten != null && unvertraeglichkeiten!.isNotEmpty) {
      map['unvertraeglichkeiten'] = unvertraeglichkeiten;
    }

    return map;
  }

  /// Bereinigt einen optionalen String und gibt null zurück, wenn er leer ist.
  static String? _bereinigeOptionalenString(dynamic value) {
    final str = (value as String?)?.trim();
    return (str == null || str.isEmpty) ? null : str;
  }

  /// Prüft, ob ein optionaler String nicht leer ist.
  static bool _istNichtLeer(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Parst verschiedene mögliche Zeitformate aus Firestore.
  /// Unterstützt Timestamp, DateTime und ISO-Strings.
  /// Fällt zurück auf die aktuelle Zeit, falls nichts gültig ist.
  static DateTime _parseZeitstempel(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    return DateTime.now();
  }

  /// Gibt eine neue Instanz zurück, bei der einzelne Felder optional überschrieben werden können.
  Mahlzeit copyWith({
    String? id,
    String? bezeichnung,
    List<String>? zutaten,
    String? notizen,
    List<String>? unvertraeglichkeiten,
    DateTime? mahlzeitZeitpunkt,
  }) {
    return Mahlzeit(
      id: id ?? this.id,
      bezeichnung: bezeichnung ?? this.bezeichnung,
      zutaten: zutaten ?? this.zutaten,
      notiz: notizen ?? this.notiz,
      unvertraeglichkeiten: unvertraeglichkeiten ?? this.unvertraeglichkeiten,
      mahlzeitZeitpunkt: mahlzeitZeitpunkt ?? this.mahlzeitZeitpunkt,
    );
  }
}
