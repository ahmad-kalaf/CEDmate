import 'package:cedmate/widgets/auth_form.dart';
import 'package:cedmate/widgets/verifiziere_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

/// Schaltet zwischen Login-Form, Bestätigungsseite und Home um.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return StreamBuilder<bool>(
      stream: auth.isLoggedInStream(),
      builder: (context, snapshot) {
        // noch keine Info → Ladeindikator
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data ?? false;

        if (!isLoggedIn) {
          // nicht eingeloggt → Login/Registrierung
          return const Scaffold(body: Center(child: AuthForm()));
        }

        final String uid = auth.userStream().map((event) => event!.uid).toString();

        // Wenn eingeloggt, prüfen ob Email verifiziert
        return StreamBuilder<bool>(
          stream: auth.isEmailVerifiedStream(),
          builder: (context, emailSnap) {
            if (!emailSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isVerified = emailSnap.data ?? false;

            if (isVerified) {
              return const HomeScreen();
            } else {
              return const VerifiziereEmailScreen();
            }
          },
        );
      },
    );
  }
}
