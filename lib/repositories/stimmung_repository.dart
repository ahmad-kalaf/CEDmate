import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cedmate/models/stimmung.dart';

class StimmungRepository {
  final FirebaseFirestore _firestore;

  StimmungRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('stimmungen');

  Future<String> add(String userId, Stimmung eintrag) async {
    final document = await _collection(userId).add(_data(eintrag));
    return document.id;
  }

  Stream<List<Stimmung>> getAll(String userId) {
    return _collection(userId).snapshots().map((snapshot) {
      final entries = snapshot.docs
          .map((document) => Stimmung.fromMap(document.data(), id: document.id))
          .toList();
      entries.sort(
        (a, b) => b.stimmungsZeitpunkt.compareTo(a.stimmungsZeitpunkt),
      );
      return entries;
    });
  }

  Stream<List<Stimmung>> getByMonthYear(String userId, int month, int year) {
    assert(month >= 1 && month <= 12);
    return getAll(userId).map(
      (entries) => entries
          .where(
            (entry) =>
                entry.stimmungsZeitpunkt.year == year &&
                entry.stimmungsZeitpunkt.month == month,
          )
          .toList(),
    );
  }

  Stream<List<Stimmung>> getByDate(String userId, DateTime date) {
    return getAll(userId).map(
      (entries) => entries
          .where((entry) => _isSameDate(entry.stimmungsZeitpunkt, date))
          .toList(),
    );
  }

  Future<Stimmung?> getById(String userId, String id) async {
    final document = await _collection(userId).doc(id).get();
    final data = document.data();
    return data == null ? null : Stimmung.fromMap(data, id: document.id);
  }

  Future<void> update(String userId, String id, Stimmung stimmung) {
    final data = _data(stimmung);
    if (stimmung.notiz?.trim().isNotEmpty != true) {
      data['tagebuch'] = FieldValue.delete();
    }
    if (stimmung.tags?.isNotEmpty != true) {
      data['tags'] = FieldValue.delete();
    }
    return _collection(userId).doc(id).update(data);
  }

  Future<void> delete(String userId, String id) {
    return _collection(userId).doc(id).delete();
  }

  Future<int> zaehleEintraegeFuerDatum(String userId, DateTime date) async {
    final snapshot = await _collection(userId).get();
    return snapshot.docs
        .map((document) => Stimmung.fromMap(document.data(), id: document.id))
        .where((entry) => _isSameDate(entry.stimmungsZeitpunkt, date))
        .length;
  }

  Map<String, dynamic> _data(Stimmung stimmung) =>
      Map<String, dynamic>.from(stimmung.toMap())..remove('id');

  bool _isSameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
