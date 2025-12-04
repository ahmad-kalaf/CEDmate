/// Enum für die diagnostizierten chronisch-entzündlichen Darmerkrankungen.
/// Jeder Wert besitzt ein lesbares Label für die UI-Darstellung.
enum Diagnose {
  /// Diagnose: Colitis Ulcerosa.
  colitisUlcerosa('Colitis Ulcerosa'),

  /// Diagnose: Morbus Crohn.
  morbusCrohn('Morbus Crohn'),

  /// Diagnose: Sonstige Formen chronisch-entzündlicher Darmerkrankungen.
  sonstigeCED('Sonstige CED Formen'),

  /// Keine bekannte oder diagnostizierte CED.
  keine('Keine');

  /// Menschlich lesbare Bezeichnung für UI und Datenanzeige.
  final String label;

  /// Konstruktor zur Verknüpfung eines Enum-Werts mit seinem Label.
  const Diagnose(this.label);
}
