import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cedmate/models/mahlzeit.dart';

class MahlzeitRepository {
  final FirebaseFirestore _firestore;

  MahlzeitRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('mahlzeiten');

  Future<String> add(String userId, Mahlzeit eintrag) async {
    final document = await _collection(userId).add(_data(eintrag));
    return document.id;
  }

  Stream<List<Mahlzeit>> getAll(String userId) {
    return _collection(userId).snapshots().map((snapshot) {
      final entries = snapshot.docs
          .map((document) => Mahlzeit.fromMap(document.data(), id: document.id))
          .toList();
      entries.sort(
        (a, b) => b.mahlzeitZeitpunkt.compareTo(a.mahlzeitZeitpunkt),
      );
      return entries;
    });
  }

  Stream<List<Mahlzeit>> getByMonthYear(String userId, int month, int year) {
    assert(month >= 1 && month <= 12);
    return getAll(userId).map(
      (entries) => entries
          .where(
            (entry) =>
                entry.mahlzeitZeitpunkt.year == year &&
                entry.mahlzeitZeitpunkt.month == month,
          )
          .toList(),
    );
  }

  Stream<List<Mahlzeit>> getByDate(String userId, DateTime date) {
    return getAll(userId).map(
      (entries) => entries
          .where((entry) => _isSameDate(entry.mahlzeitZeitpunkt, date))
          .toList(),
    );
  }

  Future<Mahlzeit?> getById(String userId, String id) async {
    final document = await _collection(userId).doc(id).get();
    final data = document.data();
    return data == null ? null : Mahlzeit.fromMap(data, id: document.id);
  }

  Future<void> update(String userId, String id, Mahlzeit mahlzeit) {
    final data = _data(mahlzeit);
    if (mahlzeit.zutaten?.isNotEmpty != true) {
      data['zutaten'] = FieldValue.delete();
    }
    if (mahlzeit.notiz?.trim().isNotEmpty != true) {
      data['notizen'] = FieldValue.delete();
    }
    if (mahlzeit.unvertraeglichkeiten?.isNotEmpty != true) {
      data['unvertraeglichkeiten'] = FieldValue.delete();
    }
    return _collection(userId).doc(id).update(data);
  }

  Future<void> delete(String userId, String id) {
    return _collection(userId).doc(id).delete();
  }

  Future<int> zaehleEintraegeFuerDatum(String userId, DateTime date) async {
    final snapshot = await _collection(userId).get();
    return snapshot.docs
        .map((document) => Mahlzeit.fromMap(document.data(), id: document.id))
        .where((entry) => _isSameDate(entry.mahlzeitZeitpunkt, date))
        .length;
  }

  Map<String, dynamic> _data(Mahlzeit mahlzeit) =>
      Map<String, dynamic>.from(mahlzeit.toMap())..remove('id');

  bool _isSameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
