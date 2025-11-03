import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cedmate/models/stuhlgang.dart';
import 'base_firestore_repository.dart';

/// Repository für Stuhlgang-Einträge.
///
/// Erbt von [BaseFirestoreRepository] und implementiert die
/// Firestore-spezifischen Details (Collection-Pfad + Mapping).
class StuhlgangRepository extends BaseFirestoreRepository<Stuhlgang> {
  StuhlgangRepository({super.firestore});

  @override
  CollectionReference<Map<String, dynamic>> collection(String userId) =>
      firestore.collection('users').doc(userId).collection('stuhlgaenge');

  @override
  Stuhlgang fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Stuhlgang.fromFirestore(doc);

  @override
  Map<String, dynamic> toMap(Stuhlgang stuhlgang) => stuhlgang.toMap();
}
