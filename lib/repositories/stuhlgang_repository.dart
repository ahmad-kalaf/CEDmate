import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cedmate/models/stuhlgang.dart';

/// Firestore-Zugriff für Stuhlgang-Einträge eines Benutzers.
class StuhlgangRepository {
  final FirebaseFirestore _firestore;

  StuhlgangRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('stuhlgaenge');

  Future<String> add(String userId, Stuhlgang stuhlgang) async {
    final document = await _collection(userId).add(stuhlgang.toMap());
    return document.id;
  }

  Stream<List<Stuhlgang>> getAll(String userId) {
    return _collection(userId).snapshots().map((snapshot) {
      final entries = snapshot.docs
          .map(
            (document) => Stuhlgang.fromMap(document.data(), id: document.id),
          )
          .toList();
      entries.sort((a, b) => b.eintragZeitpunkt.compareTo(a.eintragZeitpunkt));
      return entries;
    });
  }

  Stream<List<Stuhlgang>> getByMonthYear(String userId, int month, int year) {
    assert(month >= 1 && month <= 12);
    return getAll(userId).map(
      (entries) => entries
          .where(
            (entry) =>
                entry.eintragZeitpunkt.year == year &&
                entry.eintragZeitpunkt.month == month,
          )
          .toList(),
    );
  }

  Stream<List<Stuhlgang>> getByDate(String userId, DateTime date) {
    return getAll(userId).map(
      (entries) => entries
          .where((entry) => _isSameDate(entry.eintragZeitpunkt, date))
          .toList(),
    );
  }

  Future<Stuhlgang?> getById(String userId, String id) async {
    final document = await _collection(userId).doc(id).get();
    final data = document.data();
    return data == null ? null : Stuhlgang.fromMap(data, id: document.id);
  }

  Future<void> update(String userId, String id, Stuhlgang stuhlgang) {
    final data = stuhlgang.toMap();
    if (stuhlgang.auffaelligkeiten?.trim().isNotEmpty != true) {
      data['auffaelligkeiten'] = FieldValue.delete();
    }
    if (stuhlgang.notizen?.trim().isNotEmpty != true) {
      data['notizen'] = FieldValue.delete();
    }
    return _collection(userId).doc(id).update(data);
  }

  Future<void> delete(String userId, String id) {
    return _collection(userId).doc(id).delete();
  }

  Future<int> zaehleEintraegeFuerDatum(String userId, DateTime date) async {
    final snapshot = await _collection(userId).get();
    return snapshot.docs
        .map((document) => Stuhlgang.fromMap(document.data(), id: document.id))
        .where((entry) => _isSameDate(entry.eintragZeitpunkt, date))
        .length;
  }

  bool _isSameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
