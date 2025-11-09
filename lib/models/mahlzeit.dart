import 'package:cloud_firestore/cloud_firestore.dart';

/// Repräsentiert eine Mahlzeit
///
/// Enthält:
/// - Bezeichnung
/// - Zutaten
/// - optionale Notizen
/// - optionale Unverträglichkeiten
/// - Zeitpunkt (auto gesetzt, falls nicht übergeben)
class Mahlzeit {
  final String? id;
  final String bezeichnung;
  final List<String>? zutaten;
  final String? notiz;
  final List<String>? unvertraeglichkeiten;
  final DateTime mahlzeitZeitpunkt;

  Mahlzeit({
    this.id,
    required this.bezeichnung,
    this.zutaten,
    this.notiz,
    this.unvertraeglichkeiten,
    DateTime? mahlzeitZeitpunkt,
  }) : mahlzeitZeitpunkt = mahlzeitZeitpunkt ?? DateTime.now();

  /// Firestore → Model
  factory Mahlzeit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

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

  /// Model → Firestore
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

  // ─ Hilfsfunktionen ─
  static String? _bereinigeOptionalenString(dynamic value) {
    final str = (value as String?)?.trim();
    return (str == null || str.isEmpty) ? null : str;
  }

  static bool _istNichtLeer(String? value) =>
      value != null && value.trim().isNotEmpty;

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
