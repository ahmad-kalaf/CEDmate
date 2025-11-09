import 'package:cedmate/models/anamnese.dart';
import 'package:cedmate/models/enums/diagnose.dart';
import 'package:cedmate/models/enums/gender.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/build_list_section.dart';

class AnamneseScreen extends StatefulWidget {
  const AnamneseScreen({super.key});

  @override
  State<AnamneseScreen> createState() => _AnamneseScreenState();
}

class _AnamneseScreenState extends State<AnamneseScreen> {
  bool _isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _geburtsdatumTextController =
      TextEditingController();

  final TextEditingController _symptomeImSchubTextController =
      TextEditingController();
  final TextEditingController _schubausloeserTextController =
      TextEditingController();
  final TextEditingController _weitereErkrankungenTextController =
      TextEditingController();

  final List<String> _symptomeImSchub = [];
  final List<String> _schubausloeser = [];
  final List<String> _weitereErkrankungen = [];

  DateTime? _geburtsdatum;
  Gender? _selectedGender;
  Diagnose? _selectedDiagnose;

  @override
  void initState() {
    super.initState();
    _ladeAnamneseDaten();
  }

  Future<void> _ladeAnamneseDaten() async {
    final anamneseService = context.read<AnamneseService>();

    try {
      final bestehendeAnamnese = await anamneseService.ladeAnamnese();

      if (bestehendeAnamnese != null) {
        setState(() {
          _geburtsdatum = bestehendeAnamnese.geburtsdatum;
          _selectedGender = bestehendeAnamnese.gender;
          _selectedDiagnose = bestehendeAnamnese.diagnose;
          _symptomeImSchub.addAll(bestehendeAnamnese.symptomeImSchub);
          _schubausloeser.addAll(bestehendeAnamnese.schubausloeser);
          _weitereErkrankungen.addAll(bestehendeAnamnese.weitereErkrankungen);

          // Textfeld für Geburtsdatum anzeigen
          _geburtsdatumTextController.text =
              '${_geburtsdatum!.day.toString().padLeft(2, '0')}.'
              '${_geburtsdatum!.month.toString().padLeft(2, '0')}.'
              '${_geburtsdatum!.year}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Daten: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _geburtsdatumTextController.dispose();
    _symptomeImSchubTextController.dispose();
    _schubausloeserTextController.dispose();
    _weitereErkrankungenTextController.dispose();
    super.dispose();
  }

  /// Allgemeine Hilfsfunktion zum Hinzufügen eines Eintrags zu einer Liste
  void _addItem(
    TextEditingController controller,
    List<String> list,
    String fieldName,
  ) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !list.contains(text)) {
      setState(() {
        list.add(text);
        controller.clear();
      });
    }
  }

  /// Entfernt ein Element aus einer Liste
  void _removeItem(List<String> list, String value) {
    setState(() => list.remove(value));
  }

  /// Öffnet den nativen DatePicker (nur Kalender!)
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();

    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.'
          '${date.year}';
    }

    final picked = await showDatePicker(
      context: context,
      locale: const Locale('de', 'DE'),
      initialDate: _geburtsdatum ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      setState(() {
        _geburtsdatum = picked;
        _geburtsdatumTextController.text = formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final anamneseService = context.read<AnamneseService>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medizinisches Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    /// Geburtsdatum
                    TextFormField(
                      controller: _geburtsdatumTextController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Geburtsdatum',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_month),
                      ),
                      onTap: () => _pickDate(context),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Bitte Geburtsdatum auswählen'
                          : null,
                    ),

                    /// Geschlecht
                    DropdownButtonFormField<Gender>(
                      initialValue: _selectedGender,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Geschlecht',
                        border: OutlineInputBorder(),
                      ),
                      items: Gender.values.map((gender) {
                        return DropdownMenuItem<Gender>(
                          value: gender,
                          child: Text(gender.label),
                        );
                      }).toList(),
                      onChanged: (Gender? newGender) {
                        setState(() => _selectedGender = newGender);
                      },
                      validator: (value) =>
                          value == null ? 'Bitte Geschlecht auswählen' : null,
                    ),

                    /// Diagnose
                    DropdownButtonFormField<Diagnose>(
                      initialValue: _selectedDiagnose,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Diagnose',
                        border: OutlineInputBorder(),
                      ),
                      items: Diagnose.values.map((diagnose) {
                        return DropdownMenuItem<Diagnose>(
                          value: diagnose,
                          child: Text(diagnose.label),
                        );
                      }).toList(),
                      onChanged: (Diagnose? newDiagnose) {
                        setState(() => _selectedDiagnose = newDiagnose);
                      },
                      validator: (value) =>
                          value == null ? 'Bitte Diagnose auswählen' : null,
                    ),

                    /// Symptome im Schub
                    buildListSection(
                      title: 'Symptome im Schub',
                      context: context,
                      controller: _symptomeImSchubTextController,
                      items: _symptomeImSchub,
                      onAdd: () => _addItem(
                        _symptomeImSchubTextController,
                        _symptomeImSchub,
                        'Symptome',
                      ),
                      onRemove: (val) => _removeItem(_symptomeImSchub, val),
                    ),

                    /// Schubauslöser
                    buildListSection(
                      title: 'Schubauslöser',
                      context: context,
                      controller: _schubausloeserTextController,
                      items: _schubausloeser,
                      onAdd: () => _addItem(
                        _schubausloeserTextController,
                        _schubausloeser,
                        'Auslöser',
                      ),
                      onRemove: (val) => _removeItem(_schubausloeser, val),
                    ),

                    /// Weitere Erkrankungen
                    buildListSection(
                      title: 'Weitere Erkrankungen',
                      context: context,
                      controller: _weitereErkrankungenTextController,
                      items: _weitereErkrankungen,
                      onAdd: () => _addItem(
                        _weitereErkrankungenTextController,
                        _weitereErkrankungen,
                        'Erkrankung',
                      ),
                      onRemove: (val) => _removeItem(_weitereErkrankungen, val),
                    ),
                    SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final bool? bestaetigt = await showDialog<bool>(
              context: context,
              builder: (context) => SingleChildScrollView(
                child: AlertDialog(
                  title: const Text('Speichern bestätigen'),
                  content: const Text(
                    'Möchten Sie die Anamnese-Daten wirklich speichern?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Abbrechen'),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Ja, speichern'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ),
            );

            if (bestaetigt != true) return; // Nutzer hat abgebrochen
            final anamnese = Anamnese(
              geburtsdatum: _geburtsdatum!,
              gender: _selectedGender!,
              diagnose: _selectedDiagnose!,
              symptomeImSchub: _symptomeImSchub,
              schubausloeser: _schubausloeser,
              weitereErkrankungen: _weitereErkrankungen,
            );

            try {
              await anamneseService.speichereAnamnese(anamnese);

              if (!context.mounted) return;

              // Erfolgsmeldung + automatische Rückkehr
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Daten erfolgreich gespeichert'),
                  duration: Duration(seconds: 2),
                ),
              );

              // kleine Verzögerung, damit Snackbar sichtbar bleibt
              await Future.delayed(const Duration(microseconds: 1200));

              if (!context.mounted) return;
              // Zurück zur Startseite
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            } on AnamneseFailure catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.message)));
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unbekannter Fehler beim Speichern'),
                ),
              );
            }
          }
        },
        label: const Text('Speichern'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
