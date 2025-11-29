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
    required int schmerzLevel,
    String? auffaelligkeiten,
    String? notizen,
  }) async {
    if (haeufigkeit < 0) {
      throw ArgumentError('Häufigkeit muss mind. 0 sein.');
    }
    if (schmerzLevel < 1 || schmerzLevel > 6) {
      throw ArgumentError('Schmerzlevel muss zwischen 1 und 6 liegen.');
    }

    final eintrag = Stuhlgang(
      konsistenz: konsistenz,
      haeufigkeit: haeufigkeit,
      auffaelligkeiten: auffaelligkeiten?.trim(),
      notizen: notizen?.trim(),
      schmerzLevel: schmerzLevel,
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

  /// Streamt alle Stuhlgang-Einträge des aktuell angemeldeten Nutzers
  //  für ein bestimmtes Datum.
  Stream<List<Stuhlgang>> ladeFuerDatum(DateTime datum) {
    return _repo.getByDate(_auth.currentUserId, datum);
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
    if (eintrag.haeufigkeit < 0) {
      throw ArgumentError('Häufigkeit muss mind. 0 sein.');
    }
    if (eintrag.schmerzLevel < 1 || eintrag.schmerzLevel > 6) {
      throw ArgumentError('Schmerzlevel muss zwischen 1 und 6 liegen.');
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

  /// Anzahl der Stuhlgang-Einträge für einen Benutzer an einem bestimmten Datum zählen
  Future<int> zaehleFuerDatum(DateTime datum) async {
    final uid = _auth.currentUserId;
    return _repo.zaehleEintraegeFuerDatum(uid, datum);
  }
}
