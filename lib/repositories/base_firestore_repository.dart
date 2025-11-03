import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstrakte Basisklasse für Firestore-Repositories.
///
/// Stellt generische CRUD-Operationen bereit, die von konkreten Repositories
/// (z. B. `StuhlgangRepository`, `SymptomRepository`) genutzt werden können.
abstract class BaseFirestoreRepository<T> {
  final FirebaseFirestore firestore;

  BaseFirestoreRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  /// Gibt die Firestore-Collection für den jeweiligen Datentyp zurück.
  CollectionReference<Map<String, dynamic>> collection(String userId);

  /// Wandelt ein Firestore-Dokument in ein Modellobjekt vom Typ [T] um.
  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc);

  /// Fügt ein neues Dokument hinzu und gibt die ID zurück.
  Future<String> add(String userId, T objekt) async {
    final docRef = await collection(userId).add(toMap(objekt));
    return docRef.id;
  }

  /// Gibt einen Stream aller Dokumente der Collection zurück.
  Stream<List<T>> getAll(String userId) {
    return collection(userId)
        .orderBy('eintragZeitpunkt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(fromFirestore).toList());
  }

  /// Holt ein einzelnes Dokument anhand seiner ID.
  Future<T?> getById(String userId, String id) async {
    final doc = await collection(userId).doc(id).get();
    return doc.exists ? fromFirestore(doc) : null;
  }

  /// Aktualisiert ein bestehendes Dokument.
  Future<void> update(String userId, String id, T objekt) async {
    await collection(userId).doc(id).update(toMap(objekt));
  }

  /// Löscht ein Dokument.
  Future<void> delete(String userId, String id) async {
    await collection(userId).doc(id).delete();
  }

  /// Wandelt das Modell in eine Firestore-kompatible Map um.
  Map<String, dynamic> toMap(T objekt);
}
