/// Repräsentiert die Bristol-Stuhlformen-Skala (Typ 1 bis 7).
///
/// Quelle: https://de.wikipedia.org/wiki/Bristol-Stuhlformen-Skala
enum BristolStuhlform {
  typ0, // Stuhlgang nicht möglich / kein Stuhlgang
  typ1, // einzelne, harte Klumpen (Verstopfung)
  typ2, // wurstförmig, aber klumpig
  typ3, // wurstförmig mit Rissen
  typ4, // wurstförmig, glatt und weich (normal)
  typ5, // weiche Klümpchen mit klaren Kanten
  typ6, // breiig, unregelmäßig
  typ7, // flüssig, keine festen Bestandteile (Durchfall)
}

/// Beschreibungen der Stuhlformen für UI-Anzeige.
extension BristolBeschreibung on BristolStuhlform {
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

  /// Für Firestore: enum → String (z. B. "typ4")
  String get name => toString().split('.').last;

  /// Für Firestore: String → enum
  static BristolStuhlform fromName(String name) =>
      BristolStuhlform.values.firstWhere(
        (e) => e.name == name,
        orElse: () => BristolStuhlform.typ4, // Standard: normal
      );
}
