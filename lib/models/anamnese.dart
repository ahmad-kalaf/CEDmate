import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cedmate/models/enums/diagnose.dart';
import 'package:cedmate/models/enums/gender.dart';

class Anamnese {
  final DateTime geburtsdatum;
  final Gender gender;
  final Diagnose diagnose;
  final List<String> symptomeImSchub;
  final List<String> schubausloeser;
  final List<String> weitereErkrankungen;

  Anamnese({
    required this.geburtsdatum,
    required this.gender,
    required this.diagnose,
    required this.symptomeImSchub,
    required this.schubausloeser,
    required this.weitereErkrankungen,
  });

  /// Altersberechnung dynamisch
  int get alter {
    final now = DateTime.now();
    int years = now.year - geburtsdatum.year;
    if (now.month < geburtsdatum.month ||
        (now.month == geburtsdatum.month && now.day < geburtsdatum.day)) {
      years--;
    }
    return years;
  }

  /// Firestore-Write (→ Map)
  Map<String, dynamic> toMap() => {
    'geburtsdatum': Timestamp.fromDate(geburtsdatum),
    'gender': gender.name, // Enum → String
    'diagnose': diagnose.name,
    'symptomeImSchub': symptomeImSchub,
    'schubausloeser': schubausloeser,
    'weitereErkrankungen': weitereErkrankungen,
  };

  /// Firestore-Read (← Map)
  factory Anamnese.fromMap(Map<String, dynamic> data) {
    return Anamnese(
      geburtsdatum: (data['geburtsdatum'] is Timestamp)
          ? (data['geburtsdatum'] as Timestamp).toDate()
          : DateTime.tryParse(data['geburtsdatum'].toString()) ??
                DateTime(2000, 1, 1),
      gender: Gender.values.firstWhere(
        (g) => g.name == data['gender'],
        orElse: () => Gender.unbekannt,
      ),
      diagnose: Diagnose.values.firstWhere(
        (d) => d.name == data['diagnose'],
        orElse: () => Diagnose.keine,
      ),
      symptomeImSchub: List<String>.from(data['symptomeImSchub'] ?? const []),
      schubausloeser: List<String>.from(data['schubausloeser'] ?? const []),
      weitereErkrankungen: List<String>.from(
        data['weitereErkrankungen'] ?? const [],
      ),
    );
  }
}
