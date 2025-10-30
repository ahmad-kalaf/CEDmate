/// Domänenmodell für einen angemeldeten Benutzer.
/// Wird in Firestore unter `users/{uid}` gespeichert.
class AppUser {
  final String uid; // Firebase UID (eindeutig)
  final String email; // Login-E-Mail (intern genutzt)
  final String username; // sichtbarer Benutzername (eindeutig)
  final String? displayName; // optionaler Anzeigename

  const AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.displayName,
  });

  /// Für Firestore-Write
  Map<String, dynamic> toMap() => {
    'email': email,
    'username': username,
    'displayName': displayName,
  };

  /// Für Firestore-Read
  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String,
      username: data['username'] as String,
      displayName: data['displayName'] as String?,
    );
  }
}
