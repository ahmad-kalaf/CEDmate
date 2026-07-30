import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

/// Ein einziges Formular für Login + Registrierung.
/// Umschaltbar mit _isLogin: true = Login, false = Registrieren.
/// - Login nutzt E-Mail + Passwort.
/// - Bei der Registrierung wird zusätzlich ein Benutzername gespeichert.
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
      if (_isLogin) {
        await auth.loginWithEmail(email: _email, password: _password);
      } else {
        // REGISTRIERUNG: Benutzername + E-Mail + Passwort (+ optional Anzeige)
        await auth.register(
          username: _username,
          email: _email,
          password: _password,
          displayName: _displayName.isEmpty ? null : _displayName,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrierung erfolgreich.')),
          );
        }
      }
    } catch (e) {
      // Nutzerfreundliche Fehlermeldung anzeigen
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
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
                  // Benutzername ist ausschließlich Teil des Profils.
                  if (!_isLogin)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Benutzername',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Benutzername angeben'
                          : null,
                      onChanged: (v) => _username = v,
                      onSaved: (v) => _username = (v ?? ''),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  // E-Mail ist für Login, Registrierung und Reset erforderlich.
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'E-Mail angeben'
                        : null,
                    onChanged: (v) => _email = v,
                    onSaved: (v) => _email = (v ?? ''),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  // Passwort (immer)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Passwort'),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Passwort angeben';
                      if (!_isLogin && v.length < 8) return 'Mind. 8 Zeichen';
                      return null;
                    },
                    onChanged: (v) => _password = v,
                    onSaved: (v) => _password = (v ?? ''),
                    onFieldSubmitted: (_) => _submit(),
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
                      _username = '';
                      _email = '';
                      _password = '';
                      _displayName = '';
                      _formKey.currentState?.reset();
                    }),
                    child: Text(
                      _isLogin
                          ? 'Neu? Jetzt registrieren'
                          : 'Schon Konto? Anmelden',
                    ),
                  ),

                  // Passwort-Reset: direkt per E-Mail
                  if (_isLogin)
                    TextButton(
                      onPressed: () async {
                        if (_email.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bitte oben E-Mail eingeben.'),
                            ),
                          );
                          return;
                        }
                        try {
                          await auth.sendPasswordReset(_email);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Passwort-Reset-E-Mail wurde gesendet.',
                              ),
                            ),
                          );
                        } on AuthFailure catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.message)));
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
