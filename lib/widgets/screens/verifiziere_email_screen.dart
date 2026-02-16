import 'package:cedmate/widgets/layout/ced_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../components/ausloggen_button.dart';

class VerifiziereEmailScreen extends StatefulWidget {
  const VerifiziereEmailScreen({super.key});

  @override
  State<VerifiziereEmailScreen> createState() => _VerifiziereEmailScreenState();
}

class _VerifiziereEmailScreenState extends State<VerifiziereEmailScreen> {
  late final AuthService auth;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    auth = context.read<AuthService>();
  }

  Future<void> _checkVerification() async {
    setState(() => _loading = true);
    try {
      final verified = await auth.isEmailVerified(); // ruft intern reload() auf
      if (verified) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'E-Mail noch nicht bestätigt. Bitte Link in der Mail anklicken und erneut prüfen.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Prüfen. Bitte Internetverbindung prüfen.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAuth = auth.currentUser;
    final AppUser? user = context.watch<AppUser?>();

    return StreamBuilder<bool>(
      stream: auth.isEmailVerifiedStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          // Automatisch navigieren, wenn verifiziert
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pushReplacementNamed(context, '/home');
          });
        }
        return CEDLayout(
          title: 'CEDmate',
          child: Center(
            child: Column(
              children: [
                const Text(
                  'Bitte bestätige deine E-Mail-Adresse.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _checkVerification,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Überprüfen'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
