import 'package:cedmate/models/mahlzeit.dart';
import 'package:cedmate/repositories/mahlzeit_repository.dart';
import 'package:cedmate/services/auth_service.dart';

/// Service-Schicht für Mahlzeiten.
/// - Ermittelt die Benutzer-ID aus [AuthService]
/// - Reicht Aufrufe an [MahlzeitRepository] weiter
class MahlzeitService {
  final MahlzeitRepository _repo;
  final AuthService _auth;

  MahlzeitService(this._repo, this._auth);

  /// Legt eine neue Mahlzeit an.
  Future<String> erfasseMahlzeit(Mahlzeit mahlzeit) {
    return _repo.add(_auth.currentUserId, mahlzeit);
  }

  /// Streamt alle Mahlzeiten des aktuellen Nutzers.
  Stream<List<Mahlzeit>> ladeAlle() {
    return _repo.getAll(_auth.currentUserId);
  }

  /// Streamt alle Mahlzeiten für einen bestimmten Monat/Jahr.
  Stream<List<Mahlzeit>> ladeFuerMonatJahr(int monat, int jahr) {
    return _repo.getByMonthYear(_auth.currentUserId, monat, jahr);
  }

  /// Streamt alle Mahlzeiten für ein bestimmtes Datum.
  Stream<List<Mahlzeit>> ladeFuerDatum(DateTime datum) {
    return _repo.getByDate(_auth.currentUserId, datum);
  }

  /// Holt eine Mahlzeit per Dokument-ID.
  Future<Mahlzeit?> holeMahlzeit(String id) {
    return _repo.getById(_auth.currentUserId, id);
  }

  /// Aktualisiert eine bestehende Mahlzeit (mit ID-Validierung).
  Future<void> aktualisiereMahlzeit(Mahlzeit mahlzeit) async {
    if (mahlzeit.id == null) {
      throw ArgumentError('Mahlzeit-ID darf nicht null sein.');
    }
    await _repo.update(_auth.currentUserId, mahlzeit.id!, mahlzeit);
  }

  /// Löscht eine Mahlzeit per ID.
  Future<void> loescheMahlzeit(String id) {
    return _repo.delete(_auth.currentUserId, id);
  }
}
