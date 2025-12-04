/// Enum zur Repräsentation des Geschlechts eines Nutzers.
/// Jeder Wert hat ein lesbares Label für die UI-Darstellung.
enum Gender {
  /// Männlich.
  mann('Mann'),

  /// Weiblich.
  frau('Frau'),

  /// Divers oder nicht-binär.
  diverse('Diverse'),

  /// Geschlecht unbekannt oder nicht angegeben.
  unbekannt('Unbekannt');

  /// Menschlich lesbares Label für UI-Elemente.
  final String label;

  /// Konstruktor zur Verknüpfung eines Enum-Werts mit seinem Label.
  const Gender(this.label);
}
