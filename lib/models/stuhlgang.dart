import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums/bristol_stuhlform.dart';

/// Repräsentiert einen einzelnen Stuhlgang-Eintrag.
///
/// Dieses Modell ist:
/// - **unveränderlich (immutable)** – alle Felder sind final.
/// - **Firestore-kompatibel** – enthält saubere `toMap()` und `fromFirestore()`-Methoden.
/// - **robust** – prüft auf null, leere Strings und fehlerhafte Datentypen.
///
/// Enthält Informationen über:
/// - Konsistenz (z. B. fest, weich, flüssig)
/// - Häufigkeit pro Tag
/// - optionale Auffälligkeiten (z. B. Blut, Schleim)
/// - optionale Notizen
/// - Zeitpunkt des Eintrags (wird automatisch gesetzt, falls nicht übergeben)
class Stuhlgang {
  final String? id;
  final BristolStuhlform konsistenz; // ✅ enum statt String
  final int haeufigkeit;
  final String? auffaelligkeiten;
  final String? notizen;
  final DateTime eintragZeitpunkt;

  Stuhlgang({
    this.id,
    required this.konsistenz,
    required this.haeufigkeit,
    this.auffaelligkeiten,
    this.notizen,
    DateTime? eintragZeitpunkt,
  }) : eintragZeitpunkt = eintragZeitpunkt ?? DateTime.now();

  /// Firestore → Model
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
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'konsistenz': konsistenz.name, // ✅ enum als String speichern
      'haeufigkeit': haeufigkeit,
      'eintragZeitpunkt': Timestamp.fromDate(eintragZeitpunkt),
    };
    if (_istNichtLeer(auffaelligkeiten)) {
      map['auffaelligkeiten'] = auffaelligkeiten;
    }
    if (_istNichtLeer(notizen)) map['notizen'] = notizen;
    return map;
  }

  // ─ Hilfsfunktionen ─
  static String? _bereinigeOptionalenString(dynamic value) {
    final str = (value as String?)?.trim();
    return (str == null || str.isEmpty) ? null : str;
  }

  static bool _istNichtLeer(String? value) =>
      value != null && value.trim().isNotEmpty;

  static DateTime _parseZeitstempel(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Stuhlgang copyWith({
    String? id,
    BristolStuhlform? konsistenz,
    int? haeufigkeit,
    String? auffaelligkeiten,
    String? notizen,
    DateTime? eintragZeitpunkt,
  }) {
    return Stuhlgang(
      id: id ?? this.id,
      konsistenz: konsistenz ?? this.konsistenz,
      haeufigkeit: haeufigkeit ?? this.haeufigkeit,
      auffaelligkeiten: auffaelligkeiten ?? this.auffaelligkeiten,
      notizen: notizen ?? this.notizen,
      eintragZeitpunkt: eintragZeitpunkt ?? this.eintragZeitpunkt,
    );
  }
}
