import 'package:cedmate/models/enums/bristol_stuhlform.dart';
import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/repositories/stuhlgang_repository.dart';
import 'package:cedmate/services/auth_service.dart';

/// Service-Schicht für Stuhlgang-Einträge.
///
/// Verantwortlichkeiten:
/// - Validierung und Business-Logik
/// - Automatisches Ermitteln der Benutzer-ID aus [AuthService]
/// - Aufruf des [StuhlgangRepository] für CRUD-Operationen
/// - Realtime-Streams und optionale Filterfunktionen
class StuhlgangService {
  final StuhlgangRepository _repo;
  final AuthService _auth;

  StuhlgangService(this._repo, this._auth);

  /// Erstellt einen neuen Stuhlgang-Eintrag (mit Validierung).
  Future<void> erfasseStuhlgang({
    required BristolStuhlform konsistenz,
    required int haeufigkeit,
    String? auffaelligkeiten,
    String? notizen,
  }) async {
    if (haeufigkeit <= 0) {
      throw ArgumentError('Häufigkeit muss größer als 0 sein.');
    }

    final eintrag = Stuhlgang(
      konsistenz: konsistenz,
      haeufigkeit: haeufigkeit,
      auffaelligkeiten: auffaelligkeiten?.trim(),
      notizen: notizen?.trim(),
    );

    await _repo.add(_auth.currentUserId, eintrag);
  }

  /// Streamt alle Stuhlgang-Einträge des aktuell angemeldeten Nutzers.
  Stream<List<Stuhlgang>> ladeAlle() {
    return _repo.getAll(_auth.currentUserId);
  }

  /// Streamt alle Stuhlgang-Einträge des aktuell angemeldeten Nutzers
  /// für einen bestimmten Monat und Jahr.
  Stream<List<Stuhlgang>> ladeFuerMonatJahr(int monat, int jahr) {
    return _repo.getByMonthYear(_auth.currentUserId, monat, jahr);
  }

  /// Löscht einen Stuhlgang-Eintrag anhand seiner ID.
  Future<void> loescheStuhlgang(String id) async {
    await _repo.delete(_auth.currentUserId, id);
  }

  /// Aktualisiert einen bestehenden Stuhlgang-Eintrag (nach Validierung).
  Future<void> aktualisiereStuhlgang(Stuhlgang eintrag) async {
    if (eintrag.id == null) {
      throw ArgumentError('Stuhlgang-ID darf nicht null sein.');
    }
    if (eintrag.haeufigkeit <= 0) {
      throw ArgumentError('Häufigkeit muss größer als 0 sein.');
    }

    await _repo.update(_auth.currentUserId, eintrag.id!, eintrag);
  }

  /// Gibt nur Einträge der letzten [tage] Tage zurück (lokaler Filter).
  Stream<List<Stuhlgang>> ladeLetzteXTage(int tage) {
    final grenze = DateTime.now().subtract(Duration(days: tage));
    return ladeAlle().map(
      (liste) =>
          liste.where((e) => e.eintragZeitpunkt.isAfter(grenze)).toList(),
    );
  }

  /// Filtert Einträge nach Konsistenztyp.
  Stream<List<Stuhlgang>> filterNachKonsistenz(BristolStuhlform form) {
    return ladeAlle().map(
      (liste) => liste.where((e) => e.konsistenz == form).toList(),
    );
  }

  /// Zählt alle Einträge nach Konsistenztypen (für Statistik).
  Future<Map<BristolStuhlform, int>> zaehleNachKonsistenz() async {
    final alle = await ladeAlle().first;
    final ergebnis = <BristolStuhlform, int>{};
    for (final form in BristolStuhlform.values) {
      ergebnis[form] = alle.where((e) => e.konsistenz == form).length;
    }
    return ergebnis;
  }
}
