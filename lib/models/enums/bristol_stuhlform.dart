/// Enum für die Bristol-Stuhlformen-Skala (Typ 0 bis 7).
/// Basiert auf der medizinischen Klassifikation der Stuhlform.
/// Quelle: https://de.wikipedia.org/wiki/Bristol-Stuhlformen-Skala
enum BristolStuhlform {
  /// Kein Stuhlgang möglich oder kein Stuhlgang erfolgt.
  typ0,

  /// Einzelne harte Klumpen, Hinweis auf Verstopfung.
  typ1,

  /// Wurstförmig, jedoch klumpig.
  typ2,

  /// Wurstförmig mit Rissen auf der Oberfläche.
  typ3,

  /// Glatt und weich, gilt als normale Stuhlform.
  typ4,

  /// Weiche Klümpchen mit klaren Rändern.
  typ5,

  /// Breiig, unregelmäßige Konsistenz.
  typ6,

  /// Flüssig, keine festen Bestandteile, Hinweis auf Durchfall.
  typ7,
}

/// Erweiterung zur Bereitstellung zusätzlicher Informationen für die UI
/// und zur Konvertierung zwischen Enum-Wert und Firestore-kompatiblen Strings.
extension BristolBeschreibung on BristolStuhlform {
  /// Liefert eine menschenlesbare Beschreibung zur jeweiligen Stuhlform.
  String get beschreibung {
    switch (this) {
      case BristolStuhlform.typ0:
        return 'Kein Stuhlgang';
      case BristolStuhlform.typ1:
        return 'Harte, getrennte Klumpen';
      case BristolStuhlform.typ2:
        return 'Wurstförmig, aber klumpig';
      case BristolStuhlform.typ3:
        return 'Wurstförmig mit Rissen';
      case BristolStuhlform.typ4:
        return 'Glatt und weich (normal)';
      case BristolStuhlform.typ5:
        return 'Weiche Klümpchen';
      case BristolStuhlform.typ6:
        return 'Breiig';
      case BristolStuhlform.typ7:
        return 'Wässrig, keine festen Bestandteile';
    }
  }

  /// Gibt den Enum-Namen ohne Präfix zurück (z. B. "typ4").
  /// Wird für die Speicherung in Firestore verwendet.
  String get name => toString().split('.').last;

  /// Wandelt einen Firestore-String (z. B. "typ4") zurück in den passenden Enum-Wert.
  /// Fällt im Fehlerfall auf die normale Stuhlform (typ4) zurück.
  static BristolStuhlform fromName(String name) => BristolStuhlform.values
      .firstWhere((e) => e.name == name, orElse: () => BristolStuhlform.typ4);
}
