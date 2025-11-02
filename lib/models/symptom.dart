import 'package:cloud_firestore/cloud_firestore.dart';

/// Repräsentiert ein einzelnes Symptom.
/// Immutable, mit sauberem Firestore-Mapping und optionaler ID.
class Symptom {
  final String? id; // Firestore-Dokument-ID (optional)
  final String bezeichnung;
  final int intensitaet; // 1–10
  final DateTime startZeit;
  final int dauerInMinuten;
  final String? notizen;

  const Symptom({
    this.id,
    required this.bezeichnung,
    required this.intensitaet,
    required this.startZeit,
    required this.dauerInMinuten,
    this.notizen,
  });

  /// Firestore → Model
  factory Symptom.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Symptom(
      id: doc.id,
      bezeichnung: data['bezeichnung'] as String,
      intensitaet: data['intensitaet'] as int,
      startZeit: (data['startZeit'] as Timestamp).toDate(),
      dauerInMinuten: data['dauerInMinuten'] as int,
      notizen: (data['notizen'] as String?)?.isEmpty == true
          ? null
          : data['notizen'] as String?,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'bezeichnung': bezeichnung,
      'intensitaet': intensitaet,
      'startZeit': Timestamp.fromDate(startZeit),
      'dauerInMinuten': dauerInMinuten,
    };
    if (notizen != null && notizen!.isNotEmpty) {
      map['notizen'] = notizen;
    }
    return map;
  }
}
