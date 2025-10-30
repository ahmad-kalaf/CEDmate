import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/services/auth_service.dart';
import 'package:flutter/material.dart';

class AusloggenButton extends StatelessWidget {
  const AusloggenButton({super.key, required this.auth, required this.user});

  final AuthService auth;
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => SingleChildScrollView(
            child: AlertDialog(
              title: Text('Ausloggen bestätigen'),
              content: Text('Möchtest du dich wirklich abmelden?'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  child: Text('Bestätigen'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Abbebrechen'),
                ),
              ],
            ),
          ),
        );
      },
      icon: Icon(Icons.logout, color: Colors.red, size: 30),
    );
  }
}
