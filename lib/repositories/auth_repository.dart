import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

/// GREIFT AUF FIREBASE ZU (Auth + Firestore)
/// - keine UI-Logik, keine Validierung (das macht der Service)
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth SDK
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Firestore SDK

  /// Stream liefert null/nicht-null je nach Login-Status
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// 🔹 Aktuell eingeloggter Benutzer (kann null sein)
  User? get currentUser => _auth.currentUser;

  /// Registrierung:
  /// 1) Username atomar reservieren (Dokument `usernames/{username}` anlegen).
  /// 2) Auth-Account via E-Mail/Passwort anlegen.
  /// 3) Profil unter `users/{uid}` schreiben.
  /// -> Alles in einer Firestore-Transaktion, um Race-Conditions zu vermeiden.
  Future<AppUser> signUpWithUsernameEmail({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    return _db.runTransaction<AppUser>((tx) async {
      final unameRef = _db.collection('usernames').doc(username);

      // Prüfen, ob der Benutzername frei ist (innerhalb der Transaktion)
      final unameSnap = await tx.get(unameRef);
      if (unameSnap.exists) {
        // Wirf speziellen Fehler-String; Service mappt ihn später in User-Text.
        throw FirebaseException(plugin: 'firestore', message: 'username-taken');
      }

      // Firebase Auth Benutzer anlegen
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // Optionalen Anzeigenamen im Auth-Profil setzen (nur kosmetisch)
      if (displayName != null && displayName.isNotEmpty) {
        await cred.user!.updateDisplayName(displayName);
      }

      // Domänenobjekt vorbereiten
      final appUser = AppUser(
        uid: uid,
        email: email,
        username: username,
        displayName: displayName,
      );

      // Firestore: Username-Mapping + Benutzerprofil schreiben (atomar)
      tx.set(unameRef, {'uid': uid, 'email': email});
      tx.set(
        _db.collection('users').doc(uid),
        appUser.toMap(),
        SetOptions(merge: true),
      );

      return appUser;
    });
  }

  /// Login mit Benutzername:
  /// 1) `usernames/{username}` lesen → email/uid ermitteln
  /// 2) Mit E-Mail/Passwort via Firebase Auth einloggen
  /// 3) Profil `users/{uid}` laden (falls neu, minimal anlegen)
  Future<AppUser> signInWithUsername({
    required String username,
    required String password,
  }) async {
    final unameRef = _db.collection('usernames').doc(username);
    final unameSnap = await unameRef.get();
    if (!unameSnap.exists) {
      throw FirebaseException(plugin: 'firestore', message: 'user-not-found');
    }

    final data = unameSnap.data()!;
    final email = (data['email'] as String).trim();

    // Authentifizieren
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    // Profil laden oder minimal erzeugen
    final userDoc = _db.collection('users').doc(uid);
    final userSnap = await userDoc.get();
    if (userSnap.exists) {
      return AppUser.fromMap(uid, userSnap.data()!);
    } else {
      final fallback = AppUser(
        uid: uid,
        email: email,
        username: username,
        displayName: cred.user!.displayName,
      );
      await userDoc.set(fallback.toMap(), SetOptions(merge: true));
      return fallback;
    }
  }

  /// E-Mail mit Verifizierungslink schicken (optional nach Registrierung)
  Future<void> sendEmailVerification() async {
    final u = _auth.currentUser;
    if (u != null && !u.emailVerified) {
      await u.sendEmailVerification();
    }
  }

  /// Passwort-Reset über Benutzername:
  /// - holt E-Mail aus `usernames/{username}` und triggert Reset-Mail
  Future<void> sendPasswordResetEmailByUsername(String username) async {
    final snap = await _db.collection('usernames').doc(username).get();

    if (!snap.exists) {
      // Benutzername unbekannt → explizit Fehler werfen
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Kein Benutzer mit diesem Namen gefunden.',
      );
    }

    final email = (snap.data()?['email'] as String?)?.trim();
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'E-Mail-Adresse im Profil fehlt.',
      );
    }

    // Diese Methode kann selbst FirebaseAuthExceptions werfen (z. B. user-not-found)
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Abmelden
  Future<void> signOut() => _auth.signOut();

  Future<AppUser?> ladeUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) {
      return null;
    }
    return AppUser.fromMap(uid, snap.data()!);
  }
}
