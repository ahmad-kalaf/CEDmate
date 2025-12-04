import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cedmate/models/enums/diagnose.dart';
import 'package:cedmate/models/enums/gender.dart';

/// Modell für die Anamnese eines Nutzers.
/// Enthält grundlegende medizinische Angaben, die beim Erstellen eines Profils
/// abgefragt werden. Die Klasse ist unveränderlich und Firestore-kompatibel.
class Anamnese {
  /// Geburtsdatum des Nutzers für die spätere Altersberechnung.
  final DateTime geburtsdatum;

  /// Geschlecht des Nutzers als Enum-Wert.
  final Gender gender;

  /// Ärztlich bestätigte oder angegebene Diagnose.
  final Diagnose diagnose;

  /// Liste der Symptome, die der Nutzer typischerweise im Schub erlebt.
  final List<String> symptomeImSchub;

  /// Potenzielle Auslöser eines Schubs laut Nutzerangaben.
  final List<String> schubausloeser;

  /// Weitere Erkrankungen, die zusätzlich bestehen können.
  final List<String> weitereErkrankungen;

  /// Konstruktor zur Initialisierung einer vollständigen Anamnese.
  Anamnese({
    required this.geburtsdatum,
    required this.gender,
    required this.diagnose,
    required this.symptomeImSchub,
    required this.schubausloeser,
    required this.weitereErkrankungen,
  });

  /// Berechnet das Alter dynamisch anhand des Geburtsdatums.
  /// Die Berechnung berücksichtigt noch nicht erreichte Geburtstage im aktuellen Jahr.
  int get alter {
    final now = DateTime.now();
    int years = now.year - geburtsdatum.year;

    // Korrektur, falls der Geburtstag im aktuellen Jahr noch nicht erreicht wurde.
    if (now.month < geburtsdatum.month ||
        (now.month == geburtsdatum.month && now.day < geburtsdatum.day)) {
      years--;
    }
    return years;
  }

  /// Wandelt das Objekt in eine Map um, sodass es in Firestore gespeichert werden kann.
  /// Enums werden als String abgelegt und das Datum als Firestore-Timestamp.
  Map<String, dynamic> toMap() => {
    'geburtsdatum': Timestamp.fromDate(geburtsdatum),
    'gender': gender.name,
    'diagnose': diagnose.name,
    'symptomeImSchub': symptomeImSchub,
    'schubausloeser': schubausloeser,
    'weitereErkrankungen': weitereErkrankungen,
  };

  /// Erzeugt ein neues `Anamnese`-Objekt aus einer Firestore-Map.
  /// Enthält defensive Programmierung gegen ungültige oder unerwartete Werte.
  factory Anamnese.fromMap(Map<String, dynamic> data) {
    return Anamnese(
      geburtsdatum: (data['geburtsdatum'] is Timestamp)
          ? (data['geburtsdatum'] as Timestamp).toDate()
          : DateTime.tryParse(data['geburtsdatum'].toString()) ??
                DateTime(2000, 1, 1),

      // Falls der Enum-Wert nicht gefunden wird, wird ein Standardwert gesetzt.
      gender: Gender.values.firstWhere(
        (g) => g.name == data['gender'],
        orElse: () => Gender.unbekannt,
      ),

      diagnose: Diagnose.values.firstWhere(
        (d) => d.name == data['diagnose'],
        orElse: () => Diagnose.keine,
      ),

      // Leere Listen als Fallback, falls keine Daten vorliegen.
      symptomeImSchub: List<String>.from(data['symptomeImSchub'] ?? const []),
      schubausloeser: List<String>.from(data['schubausloeser'] ?? const []),
      weitereErkrankungen: List<String>.from(
        data['weitereErkrankungen'] ?? const [],
      ),
    );
  }
}
