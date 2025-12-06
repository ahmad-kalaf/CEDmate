import '../models/c_e_d_wissen.dart';
import '../repositories/wissen_repository.dart';

class WissenService {
  final WissenRepository repo;

  WissenService(this.repo);

  /// Streamt alle Wissenseinträge
  Stream<List<CEDWissen>> alleWissen() => repo.getWissen();

  /// Neues Wissen eintragen
  Future<void> neuesWissenEintragen(CEDWissen wissen) async {
    _validate(wissen);
    return repo.addWissen(wissen);
  }

  /// Eintrag löschen
  Future<void> deleteWissen(String id) async {
    return repo.deleteWissen(id);
  }

  /// Validierungslogik
  void _validate(CEDWissen wissen) {
    if (wissen.titel.trim().isEmpty) {
      throw Exception("Titel darf nicht leer sein.");
    }

    if (wissen.beschreibung.trim().isEmpty) {
      throw Exception("Beschreibung darf nicht leer sein.");
    }

    if (wissen.format == WissenFormat.video &&
        (wissen.contentUrl == null || wissen.contentUrl!.isEmpty)) {
      throw Exception("Ein Video benötigt eine URL.");
    }

    if (wissen.format == WissenFormat.artikel &&
        (wissen.contentText == null || wissen.contentText!.isEmpty)) {
      throw Exception("Ein Artikel benötigt Inhaltstext.");
    }
  }
}
