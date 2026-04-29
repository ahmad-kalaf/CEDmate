/// Modell für eine erfasste Mahlzeit.
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

  factory Mahlzeit.fromMap(Map<String, dynamic> data, {String? id}) {
    return Mahlzeit(
      id: id ?? _bereinigeOptionalenString(data['id']),
      bezeichnung: (data['bezeichnung'] as String?) ?? '',
      zutaten: data['zutaten'] != null ? _toStringList(data['zutaten']) : null,
      notiz: _bereinigeOptionalenString(data['notizen']),
      unvertraeglichkeiten: data['unvertraeglichkeiten'] != null
          ? _toStringList(data['unvertraeglichkeiten'])
          : null,
      mahlzeitZeitpunkt: _parseZeitstempel(data['mahlzeitZeitpunkt']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'bezeichnung': bezeichnung,
      'mahlzeitZeitpunkt': mahlzeitZeitpunkt.toIso8601String(),
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

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  static String? _bereinigeOptionalenString(dynamic value) {
    final str = (value as String?)?.trim();
    return (str == null || str.isEmpty) ? null : str;
  }

  static bool _istNichtLeer(String? value) =>
      value != null && value.trim().isNotEmpty;

  static DateTime _parseZeitstempel(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
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
