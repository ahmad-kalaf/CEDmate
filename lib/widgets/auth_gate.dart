import 'package:cedmate/widgets/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

/// Schaltet zwischen Login-Form und Home um – abhängig vom Auth-Status.
/// Nutzt den Stream aus dem Service, damit UI automatisch reagiert.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return StreamBuilder<bool>(
      stream: auth.isLoggedInStream(),
      builder: (context, snap) {
        // noch keine Info → Ladeindikator
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // eingeloggt → Home, sonst → AuthForm
        return snap.data!
            ? const HomeScreen()
            : const Scaffold(body: Center(child: AuthForm()));
      },
    );
  }
}
