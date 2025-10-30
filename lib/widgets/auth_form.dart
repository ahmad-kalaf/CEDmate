import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

/// Ein einziges Formular für Login + Registrierung.
/// Umschaltbar mit _isLogin: true = Login, false = Registrieren.
/// - Login nutzt Benutzername + Passwort.
/// - Registrierung benötigt zusätzlich E-Mail (für Firebase Auth).
class AuthForm extends StatefulWidget {
  const AuthForm({super.key});
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _busy = false;
  String _username = '', _email = '', _password = '', _displayName = '';
  String? _error;

  Future<void> _submit() async {
    // Form validieren & Werte übernehmen
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();

    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = context.read<AuthService>();

    try {
      // ignore: unused_local_variable
      AppUser user;
      if (_isLogin) {
        // LOGIN: Benutzername + Passwort
        user = await auth.loginWithUsername(
          username: _username,
          password: _password,
        );
      } else {
        // REGISTRIERUNG: Benutzername + E-Mail + Passwort (+ optional Anzeige)
        user = await auth.register(
          username: _username,
          email: _email,
          password: _password,
          displayName: _displayName.isEmpty ? null : _displayName,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bestätigungs-E-Mail gesendet.')),
          );
        }
      }

      // Weiter zur Home-Seite
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // Nutzerfreundliche Fehlermeldung anzeigen
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Benutzername (immer)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Benutzername',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Benutzername angeben'
                        : null,
                    onChanged: (v) => _username = v,
                    onSaved: (v) => _username = (v ?? ''),
                  ),
                  // E-Mail nur bei Registrierung
                  if (!_isLogin)
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'E-Mail angeben'
                          : null,
                      onChanged: (v) => _email = v,
                      onSaved: (v) => _email = (v ?? ''),
                    ),
                  // Passwort (immer)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Passwort'),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 8) ? 'Mind. 8 Zeichen' : null,
                    onChanged: (v) => _password = v,
                    onSaved: (v) => _password = (v ?? ''),
                  ),
                  // Anzeigename optional bei Registrierung
                  if (!_isLogin)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Anzeigename (optional)',
                      ),
                      onChanged: (v) => _displayName = v.trim(),
                      onSaved: (v) => _displayName = v?.trim() ?? '',
                    ),

                  const SizedBox(height: 12),

                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),

                  const SizedBox(height: 12),

                  _busy
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isLogin ? 'Anmelden' : 'Registrieren'),
                        ),

                  // Umschalten Login/Registrierung
                  TextButton(
                    onPressed: () => setState(() {
                      _isLogin = !_isLogin;
                      _formKey.currentState?.reset();
                    }),
                    child: Text(
                      _isLogin
                          ? 'Neu? Jetzt registrieren'
                          : 'Schon Konto? Anmelden',
                    ),
                  ),

                  // Passwort-Reset: per Benutzername
                  if (_isLogin)
                    TextButton(
                      onPressed: () async {
                        if (_username.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Bitte oben Benutzername eingeben.',
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          await auth.sendPasswordReset(_username);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Passwort-Reset-E-Mail wurde gesendet.',
                                ),
                              ),
                            );
                          }
                        } on AuthFailure catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        }
                      },
                      child: const Text('Passwort vergessen?'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
