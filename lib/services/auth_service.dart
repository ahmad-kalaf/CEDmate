import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

class AuthFailure implements Exception {
  final String message;

  AuthFailure(this.message);

  @override
  String toString() => message;
}

/// Anwendungslogik für E-Mail-/Passwort-Authentifizierung.
class AuthService {
  final AuthRepository _repo;

  AuthService(this._repo);

  void _validateUsername(String username) {
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

  Stream<AppUser?> userStream() => _repo.authStateChanges();

  AppUser? get currentUser => _repo.currentUser;

  String get currentUserId {
    final user = _repo.currentUser;
    if (user == null) {
      throw AuthFailure('Kein Benutzer angemeldet.');
    }
    return user.uid;
  }

  Future<AppUser> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    _validateUsername(username.trim());
    _validateEmail(email.trim());
    _validatePassword(password);

    try {
      final user = await _repo.signUpWithUsernameEmail(
        username: username.trim(),
        email: email.trim(),
        password: password,
        displayName: displayName,
      );
      try {
        await _repo.sendEmailVerification();
      } on FirebaseAuthException {
        // Das Konto ist bereits erstellt; die Verifizierung ist optional.
      }
      return user;
    } catch (error) {
      throw AuthFailure(_mapError(error));
    }
  }

  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _validateEmail(email.trim());
    if (password.isEmpty) {
      throw AuthFailure('Passwort darf nicht leer sein.');
    }

    try {
      return await _repo.signInWithEmail(
        email: email.trim(),
        password: password,
      );
    } catch (error) {
      throw AuthFailure(_mapError(error));
    }
  }

  /// Bestehende API bleibt erhalten; der Wert muss nun eine E-Mail sein.
  Future<AppUser> loginWithUsername({
    required String username,
    required String password,
  }) {
    return loginWithEmail(email: username, password: password);
  }

  /// Sendet den Reset-Link direkt an die angegebene Login-E-Mail.
  Future<void> sendPasswordReset(String email) async {
    _validateEmail(email.trim());
    try {
      await _repo.sendPasswordResetEmail(email.trim());
    } catch (error) {
      throw AuthFailure(_mapError(error));
    }
  }

  Future<void> logout() => _repo.signOut();

  Stream<bool> isLoggedInStream() => _repo.signedInChanges();

  Future<bool> isEmailVerified() => _repo.isEmailVerified();

  Stream<bool> isEmailVerifiedStream() => _repo.emailVerifiedChanges();

  String _mapError(Object error) {
    final code = error is FirebaseAuthException ? error.code : '';
    switch (code) {
      case 'invalid-email':
        return 'Ungültige E-Mail-Adresse.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-Mail oder Passwort ist falsch.';
      case 'email-already-in-use':
        return 'E-Mail wird bereits verwendet.';
      case 'weak-password':
        return 'Das Passwort ist zu schwach.';
      case 'operation-not-allowed':
        return 'E-Mail-/Passwort-Anmeldung ist nicht aktiviert.';
      case 'network-request-failed':
        return 'Netzwerkfehler. Bitte Internetverbindung prüfen.';
      case 'too-many-requests':
        return 'Zu viele Versuche. Bitte später erneut.';
    }

    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'Keine Berechtigung zum Speichern des Benutzerprofils.';
    }
    return 'Anmeldung fehlgeschlagen. Bitte später erneut versuchen.';
  }
}
