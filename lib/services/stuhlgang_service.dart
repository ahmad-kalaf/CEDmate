import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/repositories/stuhlgang_repository.dart';
import 'package:cedmate/services/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Service-Schicht für Stuhlgang-Einträge.
///
/// Holt automatisch die aktuelle Benutzer-ID aus dem [AuthService].
/// Kapselt Validierung, Logik und ruft das Repository für Firestore-Zugriffe auf.
class StuhlgangService extends ChangeNotifier {
  final StuhlgangRepository _repo;
  final AuthService _auth;

  StuhlgangService(this._repo, this._auth);

  /// Gibt die aktuelle User-ID zurück oder wirft einen Fehler, wenn niemand eingeloggt ist.
  String get _userId {
    final uid = _auth.currentUserId;
    if (uid == null) {
      throw StateError('Kein Benutzer angemeldet.');
    }
    return uid;
  }

  /// Fügt einen neuen Stuhlgang-Eintrag hinzu (nach Validierung).
  Future<void> erfasseStuhlgang({
    required String konsistenz,
    required int haeufigkeit,
    String? auffaelligkeiten,
    String? notizen,
  }) async {
    // Eingabeprüfung
    if (konsistenz.trim().isEmpty) {
      throw ArgumentError('Bitte gib eine Konsistenz an.');
    }
    if (haeufigkeit <= 0) {
      throw ArgumentError('Häufigkeit muss größer als 0 sein.');
    }

    final eintrag = Stuhlgang(
      konsistenz: konsistenz.trim(),
      haeufigkeit: haeufigkeit,
      auffaelligkeiten: auffaelligkeiten?.trim(),
      notizen: notizen?.trim(),
    );

    await _repo.add(_userId, eintrag);
    notifyListeners();
  }

  /// Streamt alle Stuhlgang-Einträge des aktuell angemeldeten Benutzers.
  Stream<List<Stuhlgang>> ladeAlle() {
    return _repo.getAll(_userId);
  }

  /// Löscht einen Stuhlgang-Eintrag.
  Future<void> loescheStuhlgang(String id) async {
    await _repo.delete(_userId, id);
    notifyListeners();
  }

  /// Aktualisiert einen bestehenden Stuhlgang-Eintrag (nach Validierung).
  Future<void> aktualisiereStuhlgang(Stuhlgang eintrag) async {
    if (eintrag.id == null) {
      throw ArgumentError('Stuhlgang-ID darf nicht null sein.');
    }
    if (eintrag.konsistenz.trim().isEmpty) {
      throw ArgumentError('Konsistenz darf nicht leer sein.');
    }

    await _repo.update(_userId, eintrag.id!, eintrag);
    notifyListeners();
  }

  /// Gibt optional nur die Einträge der letzten X Tage zurück.
  Stream<List<Stuhlgang>> ladeLetzteXTage(int tage) {
    final grenze = DateTime.now().subtract(Duration(days: tage));
    return ladeAlle().map(
      (liste) =>
          liste.where((e) => e.eintragZeitpunkt.isAfter(grenze)).toList(),
    );
  }
}
