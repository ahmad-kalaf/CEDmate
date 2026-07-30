import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/c_e_d_wissen.dart';

class WissenRepository {
  final FirebaseFirestore _firestore;

  WissenRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _wissen =>
      _firestore.collection('wissen');

  Stream<List<CEDWissen>> getWissen() {
    return _wissen.snapshots().map((snapshot) {
      final entries = snapshot.docs
          .map(
            (document) => CEDWissen.fromMap(document.data(), id: document.id),
          )
          .toList();
      entries.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      return entries;
    });
  }

  Future<void> addWissen(CEDWissen wissen) {
    return _wissen
        .add({
          ...wissen.toFirestore(),
          'createdAt': FieldValue.serverTimestamp(),
        })
        .then((_) {});
  }

  Future<void> deleteWissen(String id) {
    return _wissen.doc(id).delete();
  }
}
