/// Domänenmodell für einen angemeldeten Benutzer.
/// Repräsentiert die in Firestore gespeicherten Stammdaten eines Users.
/// Wird in Firestore unter `users/{uid}` abgelegt.
class AppUser {
  /// Eindeutige Firebase UID des Nutzers.
  final String uid;

  /// Hinterlegte Login-E-Mail des Nutzers.
  final String email;

  /// Öffentlicher, eindeutiger Benutzername.
  final String username;

  /// Optionaler Anzeigename, der zusätzlich sichtbar sein kann.
  final String? displayName;

  /// Konstruktor zum Erstellen eines unveränderlichen Benutzerobjekts.
  const AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.displayName,
  });

  /// Wandelt das Benutzerobjekt in eine Map um, um es in Firestore zu speichern.
  Map<String, dynamic> toMap() => {
    'email': email,
    'username': username,
    'displayName': displayName,
  };

  /// Erzeugt ein AppUser-Objekt aus einer Map, die aus Firestore geladen wurde.
  /// Die UID wird separat übergeben, da sie nicht in der Map gespeichert ist.
  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String,
      username: data['username'] as String,
      displayName: data['displayName'] as String?,
    );
  }
}
