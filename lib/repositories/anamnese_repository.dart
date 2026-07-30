import 'package:cloud_firestore/cloud_firestore.dart';

/// Verantwortlich für Firestore-Zugriffe auf Anamnese-Daten.
class AnamneseRepository {
  final FirebaseFirestore _firestore;

  AnamneseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _document(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .collection('anamnesen')
      .doc('anamnese');

  Future<void> speichereAnamnese({
    required String uid,
    required Map<String, dynamic> anamneseDaten,
  }) {
    return _document(uid).set(anamneseDaten, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> ladeAnamnese({required String uid}) async {
    final snapshot = await _document(uid).get();
    return snapshot.data();
  }

  Stream<Map<String, dynamic>?> beobachteAnamnese({required String uid}) {
    return _document(uid).snapshots().map((snapshot) => snapshot.data());
  }
}
