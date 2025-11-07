import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cedmate/models/stimmung.dart';

class StimmungRepository {
  final FirebaseFirestore _firestore;

  StimmungRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('stimmungen');

  Future<String> add(String userId, Stimmung eintrag) async {
    final ref = await _collection(userId).add(eintrag.toMap());
    return ref.id;
  }

  Stream<List<Stimmung>> getAll(String userId) {
    return _collection(userId)
        .orderBy('stimmungsZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Stimmung.fromFirestore(d)).toList(),
        );
  }

  Stream<List<Stimmung>> getByMonthYear(String userId, int month, int year) {
    assert(month >= 1 && month <= 12);
    final start = DateTime(year, month, 1);
    final end = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    return _collection(userId)
        .where(
          'stimmungsZeitpunkt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('stimmungsZeitpunkt', isLessThan: Timestamp.fromDate(end))
        .orderBy('stimmungsZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Stimmung.fromFirestore(d)).toList(),
        );
  }

  Stream<List<Stimmung>> getByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _collection(userId)
        .where(
          'stimmungsZeitpunkt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('stimmungsZeitpunkt', isLessThan: Timestamp.fromDate(end))
        .orderBy('stimmungsZeitpunkt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Stimmung.fromFirestore(d)).toList(),
        );
  }

  Future<Stimmung?> getById(String userId, String id) async {
    final doc = await _collection(userId).doc(id).get();
    if (!doc.exists) return null;
    return Stimmung.fromFirestore(doc);
  }

  Future<void> update(String userId, String id, Stimmung stimmung) async {
    await _collection(userId).doc(id).update(stimmung.toMap());
  }

  Future<void> delete(String userId, String id) async {
    await _collection(userId).doc(id).delete();
  }
}
