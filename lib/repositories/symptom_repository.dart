import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/symptom.dart';

/// Zugriffsschicht für Symptome unter `users/{uid}/symptoms`.
class SymptomRepository {
  final FirebaseFirestore _firestore;

  SymptomRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('symptoms');

  Future<String> addSymptom(String userId, Symptom symptom) async {
    final document = await _collection(userId).add(symptom.toMap());
    return document.id;
  }

  Stream<List<Symptom>> getSymptoms(String userId) {
    return _collection(userId).snapshots().map((snapshot) {
      final symptoms = snapshot.docs
          .map((document) => Symptom.fromMap(document.data(), id: document.id))
          .toList();
      symptoms.sort((a, b) => b.startZeit.compareTo(a.startZeit));
      return symptoms;
    });
  }

  Stream<List<Symptom>> getByMonthYear(String userId, int month, int year) {
    assert(month >= 1 && month <= 12);
    return getSymptoms(userId).map(
      (symptoms) => symptoms
          .where(
            (symptom) =>
                symptom.startZeit.year == year &&
                symptom.startZeit.month == month,
          )
          .toList(),
    );
  }

  Stream<List<Symptom>> getByDate(String userId, DateTime date) {
    return getSymptoms(userId).map(
      (symptoms) => symptoms
          .where((symptom) => _isSameDate(symptom.startZeit, date))
          .toList(),
    );
  }

  Future<Symptom> getSymptom(String userId, String symptomId) async {
    final document = await _collection(userId).doc(symptomId).get();
    final data = document.data();
    if (data == null) {
      throw StateError('Symptom nicht gefunden.');
    }
    return Symptom.fromMap(data, id: document.id);
  }

  Future<void> updateSymptom(String userId, Symptom symptom) {
    final id = symptom.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Symptom-ID darf nicht leer sein.');
    }
    final data = symptom.toMap();
    if (symptom.notizen?.trim().isNotEmpty != true) {
      data['notizen'] = FieldValue.delete();
    }
    return _collection(userId).doc(id).update(data);
  }

  Future<void> deleteSymptom(String userId, String symptomId) {
    return _collection(userId).doc(symptomId).delete();
  }

  Future<int> zaehleSymptomeFuerDatum(String userId, DateTime date) async {
    final snapshot = await _collection(userId).get();
    return snapshot.docs
        .map((document) => Symptom.fromMap(document.data(), id: document.id))
        .where((symptom) => _isSameDate(symptom.startZeit, date))
        .length;
  }

  bool _isSameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
