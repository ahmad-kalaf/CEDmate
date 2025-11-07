import 'package:cedmate/models/stimmung.dart';
import 'package:cedmate/repositories/stimmung_repository.dart';
import 'package:cedmate/services/auth_service.dart';

class StimmungService {
  final StimmungRepository _repo;
  final AuthService _auth;

  StimmungService(this._repo, this._auth);

  Future<String> erfasseStimmung(Stimmung stimmung) {
    return _repo.add(_auth.currentUserId, stimmung);
  }

  Stream<List<Stimmung>> ladeAlleStimmungen() {
    return _repo.getAll(_auth.currentUserId);
  }

  Stream<List<Stimmung>> ladeStimmungenFuerMonatJahr(int monat, int jahr) {
    return _repo.getByMonthYear(_auth.currentUserId, monat, jahr);
  }

  Stream<List<Stimmung>> ladeStimmungenFuerDatum(DateTime datum) {
    return _repo.getByDate(_auth.currentUserId, datum);
  }

  Future<Stimmung?> holeStimmung(String id) {
    return _repo.getById(_auth.currentUserId, id);
  }

  Future<void> aktualisiereStimmung(Stimmung stimmung) async {
    if (stimmung.id == null) {
      throw ArgumentError('Stimmungs-ID darf nicht null sein.');
    }
    await _repo.update(_auth.currentUserId, stimmung.id!, stimmung);
  }

  Future<void> loescheStimmung(String id) {
    return _repo.delete(_auth.currentUserId, id);
  }
}
