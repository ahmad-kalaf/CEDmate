import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override
  String toString() => message;
}

/// Service-Schicht für Authentifizierung:
class AuthService {
  final AuthRepository _repo;
  AuthService(this._repo);

  // ---------- Eingabe-Validierungen ----------
  void _validateUsername(String username) {
    // Richtlinie: 3–20 Zeichen, Buchstaben/Ziffern/Unterstrich, muss mit Buchstabe/Ziffer beginnen
    final ok = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_]{2,19}$').hasMatch(username);
    if (!ok) {
      throw AuthFailure(
        'Ungültiger Benutzername (3–20, nur Buchstaben/Ziffern/Unterstrich).',
      );
    }
  }

  void _validateEmail(String email) {
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) throw AuthFailure('Bitte eine gültige E-Mail eingeben.');
  }

  void _validatePassword(String password) {
    if (password.length < 8) {
      throw AuthFailure('Passwort muss mindestens 8 Zeichen haben.');
    }
  }

  // ---------- Anwendungsfälle ----------

  /// Stream zum Zugriff auf aktuelle Userdaten
  Stream<AppUser?> userStream() {
    return _repo.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }
      return await _repo.ladeUser(user.uid);
    });
  }

  Future<AppUser> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    _validateUsername(username);
    _validateEmail(email);
    _validatePassword(password);

    try {
      final user = await _repo.signUpWithUsernameEmail(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );
      await _repo.sendEmailVerification(); // optional
      return user;
    } catch (e) {
      throw AuthFailure(_mapError(e));
    }
  }

  Future<AppUser> loginWithUsername({
    required String username,
    required String password,
  }) async {
    _validateUsername(username);
    if (password.isEmpty) throw AuthFailure('Passwort darf nicht leer sein.');
    try {
      return await _repo.signInWithUsername(
        username: username,
        password: password,
      );
    } catch (e) {
      throw AuthFailure(_mapError(e));
    }
  }

  Future<void> sendPasswordReset(String username) async {
    _validateUsername(username);

    try {
      await _repo.sendPasswordResetEmailByUsername(username);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw AuthFailure('Ungültige E-Mail-Adresse.');
        case 'user-not-found':
          throw AuthFailure('Kein Benutzer mit diesem Namen gefunden.');
        case 'missing-email':
          throw AuthFailure('E-Mail-Adresse fehlt im Profil.');
        case 'network-request-failed':
          throw AuthFailure('Netzwerkfehler. Bitte Internetverbindung prüfen.');
        default:
          throw AuthFailure(
            'Fehler beim Senden der E-Mail: ${e.message ?? e.code}',
          );
      }
    } catch (_) {
      throw AuthFailure('Unbekannter Fehler beim Passwort-Reset.');
    }
  }

  Future<void> logout() => _repo.signOut();

  /// Praktischer Stream für AuthGate: true = eingeloggt, false = nicht
  Stream<bool> isLoggedInStream() =>
      _repo.authStateChanges().map((u) => u != null);

  // ---------- Fehlermapping (Firebase → deutsche Texte) ----------
  String _mapError(Object e) {
    final s = e.toString();
    if (s.contains('username-taken')) {
      return 'Benutzername ist bereits vergeben.';
    }
    if (s.contains('invalid-email')) return 'Ungültige E-Mail-Adresse.';
    if (s.contains('user-not-found')) return 'Benutzer nicht gefunden.';
    if (s.contains('wrong-password')) return 'Falsches Passwort.';
    if (s.contains('email-already-in-use')) {
      return 'E-Mail wird bereits verwendet.';
    }
    if (s.contains('too-many-requests')) {
      return 'Zu viele Versuche. Bitte später erneut.';
    }
    return 'Anmeldung fehlgeschlagen. Bitte später erneut versuchen.';
  }
}
