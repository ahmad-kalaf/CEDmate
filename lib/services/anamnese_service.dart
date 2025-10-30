import 'package:firebase_auth/firebase_auth.dart';
import '../models/anamnese.dart';
import '../repositories/anamnese_repository.dart';

/// Fehlerklasse für lesbare Fehlermeldungen aus der Business-Logik.
class AnamneseFailure implements Exception {
  final String message;
  AnamneseFailure(this.message);
  @override
  String toString() => message;
}

/// Service-Schicht:
/// - Validiert Daten
/// - Wandelt Models ↔ Firestore Maps
/// - Fängt Repository-Fehler ab und wirft eigene Exception
class AnamneseService {
  final AnamneseRepository _repo;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AnamneseService(this._repo);

  // ------------------------------------------------------------
  // 1) Anamnese speichern
  // ------------------------------------------------------------
  Future<void> speichereAnamnese(Anamnese anamnese) async {
    if (anamnese.alter <= 0 || anamnese.alter > 200) {
      throw AnamneseFailure('Bitte ein gültiges Alter eingeben (1–200).');
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) throw AnamneseFailure('Kein Benutzer angemeldet.');

    try {
      await _repo.speichereAnamnese(uid: uid, anamneseDaten: anamnese.toMap());
    } catch (e) {
      throw AnamneseFailure(_mapError(e));
    }
  }

  /// Anamnese einmalig laden
  /// Gibt `null` zurück, wenn keine Anamnese-Daten vorhanden sind.
  Future<Anamnese?> ladeAnamnese() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw AnamneseFailure('Kein Benutzer angemeldet.');

    try {
      final data = await _repo.ladeAnamnese(uid: uid);
      return data != null ? Anamnese.fromMap(data) : null;
    } catch (e) {
      throw AnamneseFailure(_mapError(e));
    }
  }

  /// Anamnese live beobachten
  /// Gibt `null` zurück, wenn keine Anamnese-Daten vorhanden sind.
  Stream<Anamnese?> beobachteAnamnese() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      // Fehler als Stream-Ereignis
      return Stream.error(AnamneseFailure('Kein Benutzer angemeldet.'));
    }

    return _repo.beobachteAnamnese(uid: uid).map((data) {
      if (data == null) return null;
      try {
        return Anamnese.fromMap(data);
      } catch (e) {
        throw AnamneseFailure('Fehler beim Lesen der Anamnese-Daten.');
      }
    });
  }

  /// Private Fehlermapping
  String _mapError(Object e) {
    final s = e.toString();
    if (s.contains('permission-denied')) {
      return 'Keine Berechtigung zum Zugriff auf die Anamnese.';
    }
    if (s.contains('unavailable')) {
      return 'Verbindung zum Server fehlgeschlagen.';
    }
    if (s.contains('network')) {
      return 'Netzwerkfehler. Bitte Internetverbindung prüfen.';
    }
    return 'Unbekannter Fehler beim Zugriff auf die Anamnese.';
  }
}
