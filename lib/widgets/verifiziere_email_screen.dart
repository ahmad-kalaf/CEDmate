import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'ausloggen_button.dart';

class VerifiziereEmailScreen extends StatefulWidget {
  const VerifiziereEmailScreen({super.key});

  @override
  State<VerifiziereEmailScreen> createState() => _VerifiziereEmailScreenState();
}

class _VerifiziereEmailScreenState extends State<VerifiziereEmailScreen> {
  late final AuthService auth;

  @override
  void initState() {
    super.initState();
    auth = context.read<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppUser?>();
    return Scaffold(

      appBar: AppBar(title: const Text('CEDmate'),
        actions: [AusloggenButton(auth: auth, user: user)],),
      body: const Center(
        child: Text(
          'Bitte bestätige deine E-Mail-Adresse.\n'
              'Sobald du den Link geklickt hast, starte die App neu.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
