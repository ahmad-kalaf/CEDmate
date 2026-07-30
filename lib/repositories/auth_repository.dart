import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

/// Zugriffsschicht für Firebase Authentication und Benutzerprofile.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AppUser? _currentProfile;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<AppUser?> authStateChanges() {
    return _auth.userChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _currentProfile = null;
        return null;
      }

      final profile = await _loadProfile(firebaseUser);
      _currentProfile = profile;
      return profile;
    });
  }

  Stream<bool> signedInChanges() {
    return _auth.authStateChanges().map((user) => user != null);
  }

  AppUser? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _currentProfile = null;
      return null;
    }
    if (_currentProfile?.uid == firebaseUser.uid) {
      return _currentProfile;
    }
    return _fallbackProfile(firebaseUser);
  }

  Future<AppUser> signUpWithUsernameEmail({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedEmail = email.trim();
    final normalizedDisplayName = displayName?.trim();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw StateError('Firebase hat keinen Benutzer zurückgegeben.');
    }

    final profile = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? normalizedEmail,
      username: normalizedUsername,
      displayName: normalizedDisplayName?.isEmpty == true
          ? null
          : normalizedDisplayName,
    );
    final userDocument = _userDocument(firebaseUser.uid);
    var profileWritten = false;

    try {
      await userDocument.set(profile.toMap());
      profileWritten = true;
      await firebaseUser.updateDisplayName(
        profile.displayName ?? profile.username,
      );
      _currentProfile = profile;
      return profile;
    } catch (_) {
      if (profileWritten) {
        try {
          await userDocument.delete();
        } catch (_) {
          // Der ursprüngliche Fehler bleibt maßgeblich.
        }
      }
      try {
        await firebaseUser.delete();
      } catch (_) {
        // Der ursprüngliche Fehler bleibt maßgeblich.
      }
      try {
        await _auth.signOut();
      } catch (_) {
        // Der ursprüngliche Fehler bleibt maßgeblich.
      }
      _currentProfile = null;
      rethrow;
    }
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    var authenticated = false;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      authenticated = true;
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw StateError('Firebase hat keinen Benutzer zurückgegeben.');
      }

      final snapshot = await _userDocument(firebaseUser.uid).get();
      final profile = snapshot.exists
          ? _profileFromData(firebaseUser, snapshot.data()!)
          : _fallbackProfile(firebaseUser);

      if (!snapshot.exists) {
        await _userDocument(firebaseUser.uid).set(profile.toMap());
      }

      _currentProfile = profile;
      return profile;
    } catch (_) {
      if (authenticated) {
        try {
          await _auth.signOut();
          _currentProfile = null;
        } catch (_) {
          // Der ursprüngliche Fehler bleibt maßgeblich.
        }
      }
      rethrow;
    }
  }

  /// Kompatibler Wrapper: Der Parameter enthält jetzt die Login-E-Mail.
  Future<AppUser> signInWithUsername({
    required String username,
    required String password,
  }) {
    return signInWithEmail(email: username, password: password);
  }

  Future<void> sendEmailVerification() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null && !firebaseUser.emailVerified) {
      await firebaseUser.sendEmailVerification();
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Kompatibler Wrapper: Der Parameter enthält jetzt die Login-E-Mail.
  Future<void> sendPasswordResetEmailByUsername(String username) {
    return sendPasswordResetEmail(username);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentProfile = null;
  }

  Future<AppUser?> ladeUser(String uid) async {
    final snapshot = await _userDocument(uid).get();
    if (!snapshot.exists) {
      final firebaseUser = _auth.currentUser;
      return firebaseUser?.uid == uid ? _fallbackProfile(firebaseUser!) : null;
    }

    final firebaseUser = _auth.currentUser;
    if (firebaseUser?.uid == uid) {
      final profile = _profileFromData(firebaseUser!, snapshot.data()!);
      _currentProfile = profile;
      return profile;
    }
    return AppUser.fromMap(uid, snapshot.data()!);
  }

  Future<bool> isEmailVerified() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;
    await firebaseUser.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Stream<bool> emailVerifiedChanges() {
    return _auth.userChanges().map((user) => user?.emailVerified ?? false);
  }

  Future<AppUser> _loadProfile(User firebaseUser) async {
    final snapshot = await _userDocument(firebaseUser.uid).get();
    if (!snapshot.exists) return _fallbackProfile(firebaseUser);
    return _profileFromData(firebaseUser, snapshot.data()!);
  }

  AppUser _profileFromData(User firebaseUser, Map<String, dynamic> data) {
    final fallback = _fallbackProfile(firebaseUser);
    return AppUser.fromMap(firebaseUser.uid, {
      ...fallback.toMap(),
      ...data,
      'email': fallback.email,
    });
  }

  AppUser _fallbackProfile(User firebaseUser) {
    final email = firebaseUser.email ?? '';
    final emailName = email.contains('@') ? email.split('@').first : email;
    return AppUser(
      uid: firebaseUser.uid,
      email: email,
      username: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!.trim()
          : emailName,
      displayName: firebaseUser.displayName,
    );
  }
}
