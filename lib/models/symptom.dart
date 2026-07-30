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
  factory Symptom.fromMap(Map<String, dynamic> data, {String? id}) {
    return Symptom(
      id: id ?? (data['id'] as String?),
      bezeichnung: data['bezeichnung'] as String,
      intensitaet: data['intensitaet'] as int,
      startZeit: _parseZeitstempel(data['startZeit']),
      dauerInMinuten: data['dauerInMinuten'] as int,
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

  static DateTime _parseZeitstempel(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
