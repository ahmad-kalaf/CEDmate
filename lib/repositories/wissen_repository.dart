import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/c_e_d_wissen.dart';

class WissenRepository {
  final _wissenRef = FirebaseFirestore.instance.collection('wissen');

  /// Alle Wissensartikel sortiert nach Erstellungszeit streamen
  Stream<List<CEDWissen>> getWissen() {
    return _wissenRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => CEDWissen.fromFirestore(d)).toList(),
        );
  }

  /// Einen Wissenseintrag hinzufügen
  Future<void> addWissen(CEDWissen wissen) async {
    await _wissenRef.add({
      ...wissen.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Einen Eintrag löschen
  Future<void> deleteWissen(String id) async {
    await _wissenRef.doc(id).delete();
  }
}
