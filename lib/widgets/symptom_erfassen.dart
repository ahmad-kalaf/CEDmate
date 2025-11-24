import 'package:cedmate/services/symptom_service.dart';
import 'package:cedmate/utils/loesche_eintrag.dart';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums/symptom_intensitaet.dart';
import '../models/symptom.dart';
import 'CEDColors.dart';

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
  final List<String> _emotionsSkala = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];
  late final PageController _pageController;
  SymptomIntensitaet _ausgewaehlteGefuehlsIntensitaet =
      SymptomIntensitaet.mittel;

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
    final initialIndex = _intensitaetController.text.isNotEmpty
        ? int.tryParse(_intensitaetController.text)! - 1
        : 4;
    _pageController = PageController(
      initialPage: initialIndex < 0 ? 0 : initialIndex,
      viewportFraction: 0.25,
    );
    _ausgewaehlteGefuehlsIntensitaet = SymptomIntensitaet.values[initialIndex];
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
      child: CEDLayout(
        showDrawer: false,
        title: isEditMode ? 'Symptom bearbeiten' : 'Symptom erfassen',
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                TextFormField(
                  controller: _bezeichnungController,
                  decoration: const InputDecoration(labelText: 'Bezeichnung'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Bitte eingeben' : null,
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CEDColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CEDColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Intensität',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: SymptomIntensitaet.values.length,
                          onPageChanged: (page) {
                            setState(() {
                              _ausgewaehlteGefuehlsIntensitaet =
                                  SymptomIntensitaet.values[page];
                              _intensitaetController.text = (page + 1)
                                  .toString();
                            });
                          },
                          itemBuilder: (context, index) {
                            final emotion = SymptomIntensitaet.values[index];
                            final isSelected =
                                emotion == _ausgewaehlteGefuehlsIntensitaet;

                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                );
                                setState(() {
                                  _ausgewaehlteGefuehlsIntensitaet = emotion;
                                  _intensitaetController.text = (index + 1)
                                      .toString();
                                });
                              },
                              child: AnimatedOpacity(
                                opacity: isSelected ? 1.0 : 0.3,
                                duration: const Duration(milliseconds: 200),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.black,
                                            width: 3,
                                          )
                                        : null,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _emotionsSkala[index],
                                      style: TextStyle(
                                        fontSize: isSelected ? 48 : 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ---------- Beschreibung unten ----------
                      Center(
                        child: Text(
                          _ausgewaehlteGefuehlsIntensitaet.beschreibung,
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Bitte eingeben' : null,
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isEditMode ? 'Aktualisieren' : 'Speichern'),
                  onPressed: _isSaving ? null : _speichereSymptom,
                ),
                if (isEditMode) ...[
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever),
                    label: Text('Löschen'),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final symptomService = context
                                .read<SymptomService>();
                            await deleteEntry(
                              context,
                              titel: 'Eintrag löschen',
                              text:
                                  'Möchtest du diesen Eintrag wirklich löschen? Dieser Vorgang kann nicht rückgängig gemacht werden',
                              deleteAction: () => symptomService.deleteSymptom(
                                widget.symptom!.id!,
                              ),
                            );
                            if (mounted) Navigator.pop(context);
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
