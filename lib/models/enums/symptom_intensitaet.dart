/// Enum zur Beschreibung der Intensität eines Symptoms.
/// Jeder Wert besitzt eine lesbare Beschreibung für UI-Elemente.
enum SymptomIntensitaet {
  /// Sehr leichte Symptomintensität.
  sehrLeicht('Sehr leicht'),

  /// Leichte Symptomintensität.
  leicht('Leicht'),

  /// Milde Symptomintensität.
  mild('Mild'),

  /// Mäßige Symptomintensität.
  maessig('Mäßig'),

  /// Mittlere Symptomintensität.
  mittel('Mittel'),

  /// Deutlich spürbare Symptomintensität.
  deutlich('Deutlich'),

  /// Stark ausgeprägte Symptomintensität.
  stark('Stark'),

  /// Sehr stark ausgeprägte Symptomintensität.
  sehrStark('Sehr stark'),

  /// Extrem ausgeprägte Symptomintensität.
  extrem('Extrem'),

  /// Unerträglich starke Symptomintensität.
  unertraeglich('Unerträglich');

  /// Menschlich lesbare Beschreibung für UI-Anzeige.
  final String beschreibung;

  /// Konstruktor zur Verknüpfung eines Enum-Werts mit seiner Beschreibung.
  const SymptomIntensitaet(this.beschreibung);
}
