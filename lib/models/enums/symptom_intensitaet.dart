enum SymptomIntensitaet {
  sehrLeicht('Sehr leicht'),
  leicht('Leicht'),
  mild('Mild'),
  maessig('Mäßig'),
  mittel('Mittel'),
  deutlich('Deutlich'),
  stark('Stark'),
  sehrStark('Sehr stark'),
  extrem('Extrem'),
  unertraeglich('Unerträglich');

  final String beschreibung;

  const SymptomIntensitaet(this.beschreibung);
}
