import 'package:cloud_firestore/cloud_firestore.dart';

/// Verantwortlich für Firestore-Zugriff auf Anamnese-Daten.
/// - Keine UI-Logik
/// - Keine Validierung (macht der Service)
class AnamneseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Speichert oder überschreibt die Anamnese-Daten eines Benutzers.
  /// Pfad: `users/{uid}/anamnesen/anamnese`
  Future<void> speichereAnamnese({
    required String uid,
    required Map<String, dynamic> anamneseDaten,
  }) async {
    final anamneseRef = _db
        .collection('users')
        .doc(uid)
        .collection('anamnesen')
        .doc('anamnese');

    await anamneseRef.set(anamneseDaten, SetOptions(merge: true));
  }

  /// Lädt die gespeicherten Anamnese-Daten eines Benutzers einmalig.
  /// Gibt `null` zurück, wenn noch keine Daten vorhanden sind.
  Future<Map<String, dynamic>?> ladeAnamnese({required String uid}) async {
    final anamneseRef = _db
        .collection('users')
        .doc(uid)
        .collection('anamnesen')
        .doc('anamnese');

    final snap = await anamneseRef.get();
    return snap.exists ? snap.data() : null;
  }

  /// Beobachtet die Anamnese-Daten eines Benutzers in Echtzeit.
  /// Gibt jedes Mal ein neues Map-Objekt zurück, wenn sich Firestore-Daten ändern.
  /// Gibt `null` aus, wenn das Dokument gelöscht oder nicht vorhanden ist.
  Stream<Map<String, dynamic>?> beobachteAnamnese({required String uid}) {
    final anamneseRef = _db
        .collection('users')
        .doc(uid)
        .collection('anamnesen')
        .doc('anamnese');

    // Firestore liefert Snapshots bei jeder Änderung
    return anamneseRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      } else {
        return null;
      }
    });
  }
}
