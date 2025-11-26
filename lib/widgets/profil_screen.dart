import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/services/auth_service.dart';
import 'package:cedmate/widgets/anamnese_screen.dart';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cedmate/widgets/CEDColors.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final user = context.watch<AppUser?>();
    final userName = user?.username;

    return CEDLayout(
      title: 'Profil',
      child: ListView(
        shrinkWrap: true,
        children: [
          // Benutzername
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 10,
            shadowColor: CEDColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Benutzername: ${userName ?? 'Unbekannt'}',
                    style: TextStyle(color: Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          child: AlertDialog(
                            title: Text('Benutzername ändern'),
                            content: Text(
                              'Um den Benutzernamen zu ändern, schreibe uns bitte eine Nachricht an cedmate.kontakt@gmail.com.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Schließen'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.edit, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // E-Mail-Adresse ändern
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 10,
            shadowColor: CEDColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'E-Mail: ${user?.email ?? 'Unbekannt'}',
                      style: const TextStyle(color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          child: AlertDialog(
                            title: Text('E-Mail ändern'),
                            content: Text(
                              'Um deine E-Mail zu ändern, schreibe uns bitte eine Nachricht an cedmate.kontakt@gmail.com.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Schließen'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.edit, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // passwort zurücksetzen
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 10,
            shadowColor: CEDColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Passwort: ********',
                    style: TextStyle(color: Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (userName == null) {
                        // ausloggen, falls kein benutzername vorhanden
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      }
                      final bool? bestaetigt = await showDialog<bool>(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          child: AlertDialog(
                            title: const Text('Passwort zurücksetzen'),
                            content: const Text(
                              'Möchten Sie Ihr Passwort wirklich zurücksetzen?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Abbrechen'),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Ja'),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (bestaetigt != true) return;
                      auth.sendPasswordReset(userName!);
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          child: AlertDialog(
                            title: Text('Passwort zurücksetzen'),
                            content: Text(
                              'Eine E-Mail zum Zurücksetzen des Passworts wurde an deine registrierte E-Mail-Adresse gesendet.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Schließen'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.lock_reset, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // Medizinisches Profil
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 10,
            shadowColor: CEDColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Medizinisches Profil',
                    style: TextStyle(color: Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (userName == null) {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AnamneseScreen(),
                        ),
                      );
                    },
                    child: Icon(Icons.edit, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
