import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/symptom.dart';

/// Zugriffsschicht auf Firestore (keine Logik).
class SymptomRepository {
  final FirebaseFirestore _firestore;

  SymptomRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('symptoms');

  /// Neues Symptom hinzufügen
  Future<String> addSymptom(String userId, Symptom symptom) async {
    final docRef = await _collection(userId).add(symptom.toMap());
    return docRef.id;
  }

  /// Alle Symptome eines Users live abrufen
  Stream<List<Symptom>> getSymptoms(String userId) {
    return _collection(userId)
        .orderBy('startZeit', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => Symptom.fromFirestore(d)).toList(),
        );
  }

  /// Gibt einen Stream aller Stuhlgang-Einträge des Benutzers zurück,
  /// die in einem bestimmten Monat und Jahr liegen.
  Stream<List<Symptom>> getByMonthYear(String userId, int month, int year) {
    assert(month >= 1 && month <= 12);
    final start = DateTime(year, month, 1);
    final end = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    return _collection(userId)
        .where('startZeit', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startZeit', isLessThan: Timestamp.fromDate(end))
        .orderBy('startZeit', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Symptom.fromFirestore(doc)).toList(),
        );
  }

  /// Gibt einen Stream aller Stuhlgang-Einträge des Benutzers zurück,
  /// die an einem bestimmten Datum liegen.
  Stream<List<Symptom>> getByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _collection(userId)
        .where('startZeit', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startZeit', isLessThan: Timestamp.fromDate(end))
        .orderBy('startZeit', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Symptom.fromFirestore(doc)).toList(),
        );
  }

  /// Einzelnes Symptom abrufen
  Future<Symptom> getSymptom(String userId, String symptomId) async {
    final doc = await _collection(userId).doc(symptomId).get();
    return Symptom.fromFirestore(doc);
  }

  /// Symptom aktualisieren
  Future<void> updateSymptom(String userId, Symptom symptom) async {
    if (symptom.id == null) {
      throw ArgumentError('Symptom-ID darf nicht null sein.');
    }
    await _collection(userId).doc(symptom.id).update(symptom.toMap());
  }

  /// Symptom löschen
  Future<void> deleteSymptom(String userId, String symptomId) async {
    await _collection(userId).doc(symptomId).delete();
  }

  /// Anzahl der Symptome für einen Benutzer an einem bestimmten Datum zählen
  Future<int> zaehleSymptomeFuerDatum(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final ende = DateTime(date.year, date.month, date.day + 1);

    final snapshot = await _collection(userId)
        .where('startZeit', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startZeit', isLessThan: Timestamp.fromDate(ende))
        .get();

    return snapshot.size;
  }
}
