import 'package:cedmate/services/auth_service.dart';

import '../models/symptom.dart';
import '../repositories/symptom_repository.dart';

/// Geschäftslogik + Validierungsschicht.
/// Trennt UI-Logik (Eingabe) von Repository-Zugriff (Firestore).
class SymptomService {
  final SymptomRepository _repository;
  final AuthService _auth;

  SymptomService(this._repository, this._auth);

  /// Symptom hinzufügen (mit Validierung)
  Future<void> addSymptom(Symptom symptom) async {
    _validateSymptom(symptom);
    final userId = _auth.currentUserId;
    await _repository.addSymptom(userId, symptom);
  }

  /// Symptome streamen
  Stream<List<Symptom>> getSymptoms() {
    final userId = _auth.currentUserId;
    return _repository.getSymptoms(userId);
  }

  /// Einzelnes Symptom abrufen
  Future<Symptom> getSymptom(String symptomId) {
    final userId = _auth.currentUserId;
    return _repository.getSymptom(userId, symptomId);
  }

  /// Streamt alle Stuhlgang-Einträge des aktuell angemeldeten Nutzers
  /// für einen bestimmten Monat und Jahr.
  Stream<List<Symptom>> ladeFuerMonatJahr(int monat, int jahr) {
    return _repository.getByMonthYear(_auth.currentUserId, monat, jahr);
  }

  /// Streamt alle Stuhlgang-Einträge des aktuell angemeldeten Nutzers
  /// für ein bestimmtes Datum.
  Stream<List<Symptom>> ladeFuerDatum(DateTime datum) {
    return _repository.getByDate(_auth.currentUserId, datum);
  }

  /// Symptom aktualisieren
  Future<void> updateSymptom(Symptom symptom) async {
    _validateSymptom(symptom);
    final userId = _auth.currentUserId;
    await _repository.updateSymptom(userId, symptom);
  }

  /// Symptom löschen
  Future<void> deleteSymptom(String symptomId) async {
    final userId = _auth.currentUserId;
    await _repository.deleteSymptom(userId, symptomId);
  }

  /// Interne Validierungslogik
  void _validateSymptom(Symptom symptom) {
    if (symptom.bezeichnung.trim().isEmpty) {
      throw ArgumentError('Bezeichnung darf nicht leer sein.');
    }
    if (symptom.intensitaet < 1 || symptom.intensitaet > 10) {
      throw ArgumentError('Intensität muss zwischen 1 und 10 liegen.');
    }
    if (symptom.dauerInMinuten <= 0) {
      throw ArgumentError('Dauer muss positiv sein.');
    }
    if (symptom.startZeit.isAfter(DateTime.now())) {
      throw ArgumentError('Startzeit darf nicht in der Zukunft liegen.');
    }
  }

  /// Anzahl der Symptome für einen Benutzer an einem bestimmten Datum zählen
  Future<int> zaehleFuerDatum(DateTime date) async {
    final userId = _auth.currentUserId;
    return _repository.zaehleSymptomeFuerDatum(userId, date);
  }
}
