import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/utils/loesche_eintrag.dart';
import 'package:cedmate/widgets/ced_layout.dart';
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
        final aktualisiert = widget.stuhlgang!.copyWith(
          konsistenz: _ausgewaehlteForm,
          haeufigkeit: haeufigkeit,
          notizen: notizen,
        );

        await service.aktualisiereStuhlgang(aktualisiert);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eintrag aktualisiert.')),
          );
        }
      } else {
        await service.erfasseStuhlgang(
          konsistenz: _ausgewaehlteForm,
          haeufigkeit: haeufigkeit,
          notizen: notizen,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Eintrag gespeichert.')));
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final verlassen = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verlassen bestätigen'),
            content: const Text(
              'Wenn du die Seite verlässt, werden deine Eingaben NICHT gespeichert.',
            ),
            actions: [
              TextButton(
                child: const Text('Abbrechen'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Ja, verlassen'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (verlassen == true && mounted) Navigator.pop(context);
      },
      child: CEDLayout(
        title: isEditMode ? 'Eintrag bearbeiten' : 'Eintrag erfassen',

        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ------------------------------
              // BRISTOL DROPDOWN (styled)
              // ------------------------------
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Typ – Konsistenz",
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BristolStuhlform>(
                    value: _ausgewaehlteForm,
                    isExpanded: true,
                    style: Theme.of(context).textTheme.bodyMedium,
                    dropdownColor: Theme.of(context).cardColor,
                    items: BristolStuhlform.values.map((form) {
                      return DropdownMenuItem(
                        value: form,
                        child: Text(form.beschreibung),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _ausgewaehlteForm = value);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------
              // HÄUFIGKEIT
              // ------------------------------
              TextFormField(
                controller: _haeufigkeitController,
                decoration: const InputDecoration(
                  labelText: 'Häufigkeit pro Tag (min. 1)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final i = int.tryParse(v ?? '');
                  if (i == null || i < 1) {
                    return 'Bitte mindestens 1 eingeben.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ------------------------------
              // NOTIZEN
              // ------------------------------
              TextFormField(
                controller: _notizenController,
                decoration: const InputDecoration(
                  labelText: 'Notizen (optional)',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 26),

              // ------------------------------
              // SPEICHERN BUTTON
              // ------------------------------
              ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isEditMode ? 'Aktualisieren' : 'Speichern'),
                onPressed: _isSaving ? null : _speichereEintrag,
              ),

              // ------------------------------
              // LÖSCHEN BUTTON (nur im Edit-Modus)
              // ------------------------------
              if (isEditMode) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Löschen'),
                  onPressed: () async {
                    final service = context.read<StuhlgangService>();

                    await deleteEntry(
                      context,
                      titel: 'Eintrag löschen',
                      text:
                          'Diesen Eintrag wirklich löschen? Dies kann nicht rückgängig gemacht werden.',
                      deleteAction: () =>
                          service.loescheStuhlgang(widget.stuhlgang!.id!),
                    );

                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
