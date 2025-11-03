import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums/bristol_stuhlform.dart';

class StuhlgangNotieren extends StatefulWidget {
  final Stuhlgang? stuhlgang;

  const StuhlgangNotieren({super.key, this.stuhlgang});

  @override
  State<StuhlgangNotieren> createState() => _StuhlgangNotierenState();
}

class _StuhlgangNotierenState extends State<StuhlgangNotieren> {
  final _formKey = GlobalKey<FormState>();
  BristolStuhlform _ausgewaehlteForm = BristolStuhlform.typ4;
  final _haeufigkeitController = TextEditingController();
  final _notizenController = TextEditingController();

  DateTime _eintrageZeitpunkt = DateTime.now();
  bool _isSaving = false;

  bool get isEditMode => widget.stuhlgang != null;

  @override
  void initState() {
    super.initState();
    final s = widget.stuhlgang;
    if (s != null) {
      _ausgewaehlteForm = s.konsistenz;
      _haeufigkeitController.text = s.haeufigkeit.toString();
      _notizenController.text = s.notizen ?? '';
      _eintrageZeitpunkt = s.eintragZeitpunkt;
    }
  }

  @override
  void dispose() {
    _haeufigkeitController.dispose();
    _notizenController.dispose();
    super.dispose();
  }

  Future<void> _speichereEintrag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final service = context.read<StuhlgangService>();
      final haeufigkeit = int.parse(_haeufigkeitController.text.trim());
      final notizen = _notizenController.text.trim().isEmpty
          ? null
          : _notizenController.text.trim();

      if (isEditMode) {
        // 🟡 Vorhandenen Eintrag aktualisieren
        final aktualisierterEintrag = widget.stuhlgang!.copyWith(
          konsistenz: _ausgewaehlteForm,
          haeufigkeit: haeufigkeit,
          notizen: notizen,
        );
        await service.aktualisiereStuhlgang(aktualisierterEintrag);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eintrag aktualisiert.')),
          );
        }
      } else {
        // 🟢 Neuen Eintrag speichern
        await service.erfasseStuhlgang(
          konsistenz: _ausgewaehlteForm,
          haeufigkeit: haeufigkeit,
          notizen: notizen,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eintrag erfolgreich gespeichert.')),
          );
        }
      }

      // Nach erfolgreichem Speichern zurück zur vorherigen Seite
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final bool? verlassenBestaetigt = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Verlassen bestätigen'),
              content: const Text(
                'Wenn du die Seite verlässt, werden deine Eingaben NICHT gespeichert!',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Ja, verlassen'),
                ),
              ],
            ),
          );
          if (verlassenBestaetigt == true && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Eintrag bearbeiten' : 'Eintrag erfassen'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton<BristolStuhlform>(
                        value: _ausgewaehlteForm,
                        items: BristolStuhlform.values.map((form) {
                          return DropdownMenuItem(
                            value: form,
                            child: Text(form.beschreibung),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _ausgewaehlteForm = value!);
                        },
                      ),
                      TextFormField(
                        controller: _haeufigkeitController,
                        decoration: const InputDecoration(
                          labelText: 'Häufigkeit pro Tag (min. 1)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final i = int.tryParse(v ?? '');
                          if (i == null || i < 1) {
                            return 'Wert mindestens 1';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notizenController,
                        decoration: const InputDecoration(
                          labelText: 'Notizen (optional)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(isEditMode ? 'Aktualisieren' : 'Speichern'),
                        onPressed: _isSaving ? null : _speichereEintrag,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
