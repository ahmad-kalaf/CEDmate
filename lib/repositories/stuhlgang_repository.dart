import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cedmate/models/stuhlgang.dart';

/// Repository für Stuhlgang-Einträge.
///
/// Enthält alle CRUD-Operationen direkt (kein generisches Baserepository mehr).
///
/// Verantwortlichkeiten:
/// - Zugriff auf Firestore-Collection `users/{userId}/stuhlgaenge`
/// - CRUD-Operationen (Create, Read, Update, Delete)
/// - Mapping zwischen Firestore-Dokumenten und [Stuhlgang]-Objekten
class StuhlgangRepository {
  final FirebaseFirestore _firestore;

  StuhlgangRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Gibt die Collection der Stuhlgang-Einträge des Benutzers zurück.
  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('stuhlgaenge');

  /// Fügt einen neuen Stuhlgang-Eintrag hinzu und gibt die generierte ID zurück.
  Future<String> add(String userId, Stuhlgang stuhlgang) async {
    final docRef = await _collection(userId).add(stuhlgang.toMap());
    return docRef.id;
  }

  /// Gibt einen Stream aller Stuhlgang-Einträge des Benutzers zurück,
  /// sortiert nach Zeitpunkt (neueste zuerst).
  Stream<List<Stuhlgang>> getAll(String userId) {
    return _collection(userId)
        .orderBy('eintragZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Stuhlgang.fromFirestore(doc)).toList(),
        );
  }

  /// Gibt einen Stream aller Stuhlgang-Einträge des Benutzers zurück,
  /// die in einem bestimmten Monat und Jahr liegen.
  Stream<List<Stuhlgang>> getByMonthYear(String userId, int month, int year) {
    assert(month >= 1 && month <= 12);
    final start = DateTime(year, month, 1);
    final end = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    return _collection(userId)
        .where(
          'eintragZeitpunkt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('eintragZeitpunkt', isLessThan: Timestamp.fromDate(end))
        .orderBy('eintragZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Stuhlgang.fromFirestore(doc)).toList(),
        );
  }

  /// Gibt einen Stream aller Stuhlgang-Einträge des Benutzers zurück,
  /// die an einem bestimmten Datum liegen.
  Stream<List<Stuhlgang>> getByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _collection(userId)
        .where(
          'eintragZeitpunkt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('eintragZeitpunkt', isLessThan: Timestamp.fromDate(end))
        .orderBy('eintragZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Stuhlgang.fromFirestore(doc)).toList(),
        );
  }

  /// Holt einen bestimmten Stuhlgang-Eintrag anhand seiner Dokument-ID.
  Future<Stuhlgang?> getById(String userId, String id) async {
    final doc = await _collection(userId).doc(id).get();
    if (!doc.exists) return null;
    return Stuhlgang.fromFirestore(doc);
  }

  /// Aktualisiert einen vorhandenen Stuhlgang-Eintrag.
  Future<void> update(String userId, String id, Stuhlgang stuhlgang) async {
    await _collection(userId).doc(id).update(stuhlgang.toMap());
  }

  /// Löscht einen bestimmten Stuhlgang-Eintrag.
  Future<void> delete(String userId, String id) async {
    await _collection(userId).doc(id).delete();
  }

  /// Anzahl der Stuhlgang-Einträge für einen Benutzer an einem bestimmten Datum zählen
  Future<int> zaehleEintraegeFuerDatum(String userId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final ende = DateTime(date.year, date.month, date.day + 1);

    final snapshot = await _collection(userId)
        .where(
          'eintragZeitpunkt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('eintragZeitpunkt', isLessThan: Timestamp.fromDate(ende))
        .get();

    return snapshot.size;
  }
}
