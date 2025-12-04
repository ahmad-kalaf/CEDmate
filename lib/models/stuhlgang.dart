import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums/bristol_stuhlform.dart';

/// Modell für einen einzelnen Stuhlgang-Eintrag.
/// Enthält Angaben zur Konsistenz, Häufigkeit, optionalen Auffälligkeiten,
/// Schmerzen sowie dem Zeitpunkt der Eintragung.
/// Das Modell ist unveränderlich und vollständig Firestore-kompatibel.
class Stuhlgang {
  /// Firestore-Dokument-ID des Eintrags.
  final String? id;

  /// Stuhlkonsistenz gemäß Bristol-Skala.
  final BristolStuhlform konsistenz;

  /// Häufigkeit des Stuhlgangs am Tag.
  final int haeufigkeit;

  /// Schmerzlevel beim Stuhlgang, Skala 1 (kein Schmerz) bis 5 (starker Schmerz).
  final int schmerzLevel;

  /// Optionale Auffälligkeiten im Stuhl, z. B. Blut oder Schleim.
  final String? auffaelligkeiten;

  /// Optionale Freitextnotizen.
  final String? notizen;

  /// Zeitpunkt, an dem der Eintrag vorgenommen wurde.
  final DateTime eintragZeitpunkt;

  /// Konstruktor, der einen neuen Stuhlgang-Eintrag erstellt.
  /// Der Zeitpunkt wird automatisch gesetzt, falls keiner übergeben wird.
  Stuhlgang({
    this.id,
    required this.konsistenz,
    required this.haeufigkeit,
    required this.schmerzLevel,
    this.auffaelligkeiten,
    this.notizen,
    DateTime? eintragZeitpunkt,
  }) : eintragZeitpunkt = eintragZeitpunkt ?? DateTime.now();

  /// Erstellt ein Stuhlgang-Objekt aus einem Firestore-Dokument.
  /// Enums werden anhand des Namens rekonstruiert.
  /// Optionale Strings werden bereinigt und leere Werte entfernt.
  factory Stuhlgang.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Stuhlgang(
      id: doc.id,
      konsistenz: BristolBeschreibung.fromName(
        (data['konsistenz'] as String?) ?? 'typ4',
      ),
      haeufigkeit: (data['haeufigkeit'] as int?) ?? 0,
      auffaelligkeiten: _bereinigeOptionalenString(data['auffaelligkeiten']),
      notizen: _bereinigeOptionalenString(data['notizen']),
      eintragZeitpunkt: _parseZeitstempel(data['eintragZeitpunkt']),
      schmerzLevel: (data['schmerzLevel'] as int?) ?? 1,
    );
  }

  /// Wandelt den Eintrag in eine Firestore-kompatible Map um.
  /// Nur tatsächlich vorhandene Werte für Auffälligkeiten und Notizen werden gespeichert.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'konsistenz': konsistenz.name,
      'haeufigkeit': haeufigkeit,
      'eintragZeitpunkt': Timestamp.fromDate(eintragZeitpunkt),
      'schmerzLevel': schmerzLevel,
    };

    if (_istNichtLeer(auffaelligkeiten)) {
      map['auffaelligkeiten'] = auffaelligkeiten;
    }
    if (_istNichtLeer(notizen)) {
      map['notizen'] = notizen;
    }

    return map;
  }

  /// Bereinigt optionale Strings und gibt null zurück, wenn der Wert leer ist.
  static String? _bereinigeOptionalenString(dynamic value) {
    final str = (value as String?)?.trim();
    return (str == null || str.isEmpty) ? null : str;
  }

  /// Prüft, ob ein optionaler String einen Inhalt hat.
  static bool _istNichtLeer(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Parst einen Firestore-Zeitwert.
  /// Unterstützt Timestamp und DateTime, ansonsten wird die aktuelle Zeit verwendet.
  static DateTime _parseZeitstempel(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// Gibt eine neue Instanz zurück, bei der einzelne Felder überschrieben werden können.
  /// Die übrigen Werte bleiben unverändert.
  Stuhlgang copyWith({
    String? id,
    BristolStuhlform? konsistenz,
    int? haeufigkeit,
    String? auffaelligkeiten,
    String? notizen,
    DateTime? eintragZeitpunkt,
    int? schmerzLevel,
  }) {
    return Stuhlgang(
      id: id ?? this.id,
      konsistenz: konsistenz ?? this.konsistenz,
      haeufigkeit: haeufigkeit ?? this.haeufigkeit,
      auffaelligkeiten: auffaelligkeiten ?? this.auffaelligkeiten,
      notizen: notizen ?? this.notizen,
      eintragZeitpunkt: eintragZeitpunkt ?? this.eintragZeitpunkt,
      schmerzLevel: schmerzLevel ?? this.schmerzLevel,
    );
  }
}
