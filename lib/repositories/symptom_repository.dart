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
}
