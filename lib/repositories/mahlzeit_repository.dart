import 'package:cedmate/models/mahlzeit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MahlzeitRepository {
  final FirebaseFirestore _firestore;

  MahlzeitRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collectionReference(
    String userId,
  ) => _firestore.collection('users').doc(userId).collection('mahlzeiten');

  Future<String> add(String userId, Mahlzeit eintrag) async {
    final ref = await _collectionReference(userId).add(eintrag.toMap());
    return ref.id;
  }

  Stream<List<Mahlzeit>> getAll(String userId) {
    return _collectionReference(userId)
        .orderBy('mahlzeitZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => Mahlzeit.fromFirestore(e)).toList(),
        );
  }

  /// Stream aller Mahlzeiten eines Monats (neueste zuerst).
  Stream<List<Mahlzeit>> getByMonthYear(String userId, int month, int year) {
    assert(month >= 1 && month <= 12);
    final start = DateTime(year, month, 1);
    final end = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    return _collectionReference(userId)
        .where(
          'mahlzeitZeitpunkt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('mahlzeitZeitpunkt', isLessThan: Timestamp.fromDate(end))
        .orderBy('mahlzeitZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Mahlzeit.fromFirestore(doc)).toList(),
        );
  }

  /// Stream aller Mahlzeiten eines Datums (neueste zuerst).
  Stream<List<Mahlzeit>> getByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _collectionReference(userId)
        .where(
          'mahlzeitZeitpunkt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('mahlzeitZeitpunkt', isLessThan: Timestamp.fromDate(end))
        .orderBy('mahlzeitZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Mahlzeit.fromFirestore(doc)).toList(),
        );
  }

  /// Einzelne Mahlzeit per Dokument-ID.
  Future<Mahlzeit?> getById(String userId, String id) async {
    final doc = await _collectionReference(userId).doc(id).get();
    if (!doc.exists) return null;
    return Mahlzeit.fromFirestore(doc);
  }

  /// Aktualisiert eine bestehende Mahlzeit.
  Future<void> update(String userId, String id, Mahlzeit mahlzeit) async {
    await _collectionReference(userId).doc(id).update(mahlzeit.toMap());
  }

  /// Löscht eine Mahlzeit.
  Future<void> delete(String userId, String id) async {
    await _collectionReference(userId).doc(id).delete();
  }

  /// Anzahl der Einträge für einen Benutzer an einem bestimmten Datum zählen
  Future<int> zaehleEintraegeFuerDatum(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final ende = DateTime(date.year, date.month, date.day + 1);

    final snapshot = await _collectionReference(userId)
        .where(
          'mahlzeitZeitpunkt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('mahlzeitZeitpunkt', isLessThan: Timestamp.fromDate(ende))
        .get();

    return snapshot.size;
  }
}
