import 'package:cloud_firestore/cloud_firestore.dart';

/// Modell für ein einzelnes Symptom im SymptomRadar.
/// Enthält Bezeichnung, Intensität, Startzeit, Dauer sowie optionale Notizen.
/// Das Modell ist unveränderlich und vollständig Firestore-kompatibel.
class Symptom {
  /// Firestore-Dokument-ID des Symptoms (optional).
  final String? id;

  /// Name oder Beschreibung des Symptoms.
  final String bezeichnung;

  /// Intensität des Symptoms, Skala 1 bis 10.
  final int intensitaet;

  /// Zeitpunkt, an dem das Symptom begonnen hat.
  final DateTime startZeit;

  /// Dauer des Symptoms in Minuten.
  final int dauerInMinuten;

  /// Optionale Freitextnotizen zum Symptom.
  final String? notizen;

  /// Konstruktor für ein unveränderliches Symptom-Objekt.
  const Symptom({
    this.id,
    required this.bezeichnung,
    required this.intensitaet,
    required this.startZeit,
    required this.dauerInMinuten,
    this.notizen,
  });

  /// Erzeugt ein Symptom-Objekt aus einem Firestore-Dokument.
  /// Alle Felder werden direkt aus der Map gelesen und korrekt konvertiert.
  factory Symptom.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Symptom(
      id: doc.id,
      bezeichnung: data['bezeichnung'] as String,
      intensitaet: data['intensitaet'] as int,
      startZeit: (data['startZeit'] as Timestamp).toDate(),
      dauerInMinuten: data['dauerInMinuten'] as int,

      // Leere Strings werden in null umgewandelt.
      notizen: (data['notizen'] as String?)?.isEmpty == true
          ? null
          : data['notizen'] as String?,
    );
  }

  /// Wandelt das Symptom in eine Map um, um es in Firestore zu speichern.
  /// Optionales Feld "notizen" wird nur gespeichert, wenn es vorhanden und nicht leer ist.
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
