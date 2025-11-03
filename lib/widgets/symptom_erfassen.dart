import 'package:cedmate/services/symptom_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/symptom.dart';

class SymptomErfassen extends StatefulWidget {
  final Symptom? symptom;

  const SymptomErfassen({super.key, this.symptom});

  @override
  State<SymptomErfassen> createState() => _SymptomErfassenState();
}

class _SymptomErfassenState extends State<SymptomErfassen> {
  final _formKey = GlobalKey<FormState>();
  final _bezeichnungController = TextEditingController();
  final _intensitaetController = TextEditingController();
  final _dauerController = TextEditingController();
  final _notizenController = TextEditingController();

  DateTime _startZeit = DateTime.now();
  bool _isSaving = false;

  bool get isEditMode => widget.symptom != null;

  @override
  void initState() {
    super.initState();
    final s = widget.symptom;
    if (s != null) {
      _bezeichnungController.text = s.bezeichnung;
      _intensitaetController.text = s.intensitaet.toString();
      _dauerController.text = s.dauerInMinuten.toString();
      _notizenController.text = s.notizen ?? '';
      _startZeit = s.startZeit;
    }
  }

  @override
  void dispose() {
    _bezeichnungController.dispose();
    _intensitaetController.dispose();
    _dauerController.dispose();
    _notizenController.dispose();
    super.dispose();
  }

  Future<void> _waehleStartzeit() async {
    // Datum auswählen
    final DateTime? gewaehltesDatum = await showDatePicker(
      context: context,
      initialDate: _startZeit,
      firstDate: DateTime(1900),
      lastDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      locale: const Locale('de', 'DE'),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (gewaehltesDatum == null) return;

    // Uhrzeit auswählen
    if (!mounted) return;
    final TimeOfDay? gewaehlteUhrzeit = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startZeit),
    );

    if (gewaehlteUhrzeit == null) return;

    setState(() {
      _startZeit = DateTime(
        gewaehltesDatum.year,
        gewaehltesDatum.month,
        gewaehltesDatum.day,
        gewaehlteUhrzeit.hour,
        gewaehlteUhrzeit.minute,
      );
    });
  }

  Future<void> _speichereSymptom() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final symptom = Symptom(
        id: widget.symptom?.id,
        bezeichnung: _bezeichnungController.text.trim(),
        intensitaet: int.parse(_intensitaetController.text),
        dauerInMinuten: int.parse(_dauerController.text),
        notizen: _notizenController.text.trim().isEmpty
            ? null
            : _notizenController.text,
        startZeit: _startZeit,
      );

      final symptomService = context.read<SymptomService>();
      try {
        if (isEditMode) {
          await symptomService.updateSymptom(symptom);
        } else {
          await symptomService.addSymptom(symptom);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode ? 'Symptom aktualisiert' : 'Symptom gespeichert',
            ),
          ),
        );
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
  }

  @override
  Widget build(BuildContext context) {
    final String datumAnzeige =
        '${_startZeit.day.toString().padLeft(2, '0')}.${_startZeit.month.toString().padLeft(2, '0')}.${_startZeit.year}, '
        '${_startZeit.hour.toString().padLeft(2, '0')}:${_startZeit.minute.toString().padLeft(2, '0')} Uhr';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final bool? verlassenBestaetigt = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Symptom bearbeiten'),
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
          title: Text(isEditMode ? 'Symptom bearbeiten' : 'Symptom erfassen'),
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
                      TextFormField(
                        controller: _bezeichnungController,
                        decoration: const InputDecoration(
                          labelText: 'Bezeichnung',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Bitte eingeben'
                            : null,
                      ),
                      TextFormField(
                        controller: _intensitaetController,
                        decoration: const InputDecoration(
                          labelText: 'Intensität (1–10)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final i = int.tryParse(v ?? '');
                          if (i == null || i < 1 || i > 10) {
                            return 'Wert zwischen 1 und 10';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Startzeit: $datumAnzeige'),
                          IconButton(
                            icon: const Icon(Icons.edit_calendar),
                            tooltip: 'Datum/Uhrzeit wählen',
                            onPressed: _waehleStartzeit,
                          ),
                        ],
                      ),
                      const Divider(),
                      TextFormField(
                        controller: _dauerController,
                        decoration: const InputDecoration(
                          labelText: 'Dauer (in Minuten)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Bitte eingeben'
                            : null,
                      ),
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
                        onPressed: _isSaving ? null : _speichereSymptom,
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
