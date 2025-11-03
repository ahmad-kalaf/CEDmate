import 'package:cloud_firestore/cloud_firestore.dart';

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
  /// Firestore-Dokument-ID (optional)
  final String? id;

  /// Konsistenz des Stuhlgangs (z. B. "fest", "weich", "flüssig")
  final String konsistenz;

  /// Anzahl der Stuhlgänge pro Tag
  final int haeufigkeit;

  /// Optionale Auffälligkeiten (z. B. Blut, Schleim, ungewöhnliche Farbe)
  final String? auffaelligkeiten;

  /// Freitext-Notizen (z. B. Begleitsymptome oder Ernährung)
  final String? notizen;

  /// Zeitpunkt des Eintrags
  /// Wird automatisch auf die aktuelle Zeit gesetzt, wenn keiner angegeben wird.
  final DateTime eintragZeitpunkt;

  Stuhlgang({
    this.id,
    required this.konsistenz,
    required this.haeufigkeit,
    this.auffaelligkeiten,
    this.notizen,
    DateTime? eintragZeitpunkt,
  }) : eintragZeitpunkt = eintragZeitpunkt ?? DateTime.now();

  /// Erstellt ein [Stuhlgang]-Objekt aus einem Firestore-Dokument.
  factory Stuhlgang.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Stuhlgang(
      id: doc.id,
      konsistenz: (data['konsistenz'] as String?) ?? '',
      haeufigkeit: (data['haeufigkeit'] as int?) ?? 0,
      auffaelligkeiten: _bereinigeOptionalenString(data['auffaelligkeiten']),
      notizen: _bereinigeOptionalenString(data['notizen']),
      eintragZeitpunkt: _parseZeitstempel(data['eintragZeitpunkt']),
    );
  }

  /// Wandelt das Objekt in eine Map um, die in Firestore gespeichert werden kann.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'konsistenz': konsistenz,
      'haeufigkeit': haeufigkeit,
      'eintragZeitpunkt': Timestamp.fromDate(eintragZeitpunkt),
    };

    if (_istNichtLeer(auffaelligkeiten)) {
      map['auffaelligkeiten'] = auffaelligkeiten;
    }
    if (_istNichtLeer(notizen)) {
      map['notizen'] = notizen;
    }

    return map;
  }

  // ─────────────────────────────
  // 🔧 Hilfsfunktionen
  // ─────────────────────────────

  /// Entfernt leere oder nur aus Leerzeichen bestehende Strings → gibt null zurück.
  static String? _bereinigeOptionalenString(dynamic value) {
    final str = (value as String?)?.trim();
    return (str == null || str.isEmpty) ? null : str;
  }

  /// Prüft, ob ein String-Feld Text enthält.
  static bool _istNichtLeer(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Wandelt Firestore-Timestamp oder DateTime in ein DateTime-Objekt um.
  static DateTime _parseZeitstempel(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now(); // Fallback bei fehlendem Wert
  }
}
