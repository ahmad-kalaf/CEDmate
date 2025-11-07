import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums/stimmung_level.dart';

/// Repräsentiert einen Stimmungseintrag (SeelenLog).
class Stimmung {
  final String? id;
  final StimmungLevel level;
  final int stresslevel; // 1–10
  final String? tagebuch; // optionaler Freitext
  final List<String>? tags; // optional (z.\b. Angst, Wut, Freude)
  final DateTime stimmungsZeitpunkt;

  Stimmung({
    this.id,
    required this.level,
    required this.stresslevel,
    this.tagebuch,
    this.tags,
    DateTime? stimmungsZeitpunkt,
  }) : assert(stresslevel >= 1 && stresslevel <= 10),
       stimmungsZeitpunkt = stimmungsZeitpunkt ?? DateTime.now();

  /// Firestore → Model
  factory Stimmung.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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

    String? cleanOptional(dynamic v) {
      final s = (v as String?)?.trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return Stimmung(
      id: doc.id,
      level: parseStimmungLevel(data['stimmungsLevel']),
      stresslevel: (data['stresslevel'] as int?) ?? 5,
      tagebuch: cleanOptional(data['tagebuch']),
      tags: (data['tags'] != null) ? toStringList(data['tags']) : null,
      stimmungsZeitpunkt: parseZeit(data['stimmungsZeitpunkt']),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'stimmungsLevel': level.name,
      'stresslevel': stresslevel,
      'stimmungsZeitpunkt': Timestamp.fromDate(stimmungsZeitpunkt),
    };
    if (tagebuch != null && tagebuch!.trim().isNotEmpty) {
      map['tagebuch'] = tagebuch;
    }
    if (tags != null && tags!.isNotEmpty) {
      map['tags'] = tags;
    }
    return map;
  }

  Stimmung copyWith({
    String? id,
    StimmungLevel? level,
    int? stresslevel,
    String? tagebuch,
    List<String>? tags,
    DateTime? stimmungsZeitpunkt,
  }) {
    return Stimmung(
      id: id ?? this.id,
      level: level ?? this.level,
      stresslevel: stresslevel ?? this.stresslevel,
      tagebuch: tagebuch ?? this.tagebuch,
      tags: tags ?? this.tags,
      stimmungsZeitpunkt: stimmungsZeitpunkt ?? this.stimmungsZeitpunkt,
    );
  }
}
