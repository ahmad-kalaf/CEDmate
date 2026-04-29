/// Modell für einen Stimmungseintrag im SeelenLog.
class Stimmung {
  final String? id;
  final int level;
  final int stresslevel;
  final String? notiz;
  final List<String>? tags;
  final DateTime stimmungsZeitpunkt;

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

  factory Stimmung.fromMap(Map<String, dynamic> data, {String? id}) {
    return Stimmung(
      id: id ?? _cleanOptional(data['id']),
      level: _parseInt(data['stimmungsLevel'], fallback: 3),
      stresslevel: _parseInt(data['stresslevel'], fallback: 5),
      notiz: _cleanOptional(data['tagebuch']),
      tags: data['tags'] != null ? _toStringList(data['tags']) : null,
      stimmungsZeitpunkt: _parseZeit(data['stimmungsZeitpunkt']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'stimmungsLevel': level,
      'stresslevel': stresslevel,
      'stimmungsZeitpunkt': stimmungsZeitpunkt.toIso8601String(),
    };

    if (notiz != null && notiz!.trim().isNotEmpty) {
      map['tagebuch'] = notiz;
    }

    if (tags != null && tags!.isNotEmpty) {
      map['tags'] = tags;
    }

    return map;
  }

  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
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

  static DateTime _parseZeit(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  static String? _cleanOptional(dynamic v) {
    final s = (v as String?)?.trim();
    return (s == null || s.isEmpty) ? null : s;
  }

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
