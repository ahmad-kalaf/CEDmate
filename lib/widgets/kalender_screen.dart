import 'package:cedmate/widgets/datum_rad.dart';
import 'package:cedmate/widgets/ess_tagebuch_fuer_datum.dart';
import 'package:cedmate/widgets/seelen_log_fuer_datum.dart';
import 'package:cedmate/widgets/stuhlgang_eintraege_fuer_datum.dart';
import 'package:cedmate/widgets/symptome_fuer_datum.dart';
import 'package:flutter/material.dart';

import 'CEDColors.dart';

class KalenderScreen extends StatefulWidget {
  final int ausgewaehlteSeite;

  const KalenderScreen({super.key, this.ausgewaehlteSeite = 0});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  final TextEditingController _datumAuswahlController = TextEditingController();
  DateTime? _ausgewaehtesMonatJahr;

  // 0 -> Symptome, 1 -> Stuhlgang, 2 -> Mahlzeiten, 3 -> Stimmung
  late int _ausgewaehlteSeite;

  @override
  void initState() {
    super.initState();
    _ausgewaehtesMonatJahr = DateTime.now();
    _datumAuswahlController.text =
        '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}';
    _ausgewaehlteSeite = widget.ausgewaehlteSeite;
  }

  /// Öffnet den nativen DatePicker (nur Kalender!)
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    String formatMonthYear(DateTime date) {
      return '${date.month.toString().padLeft(2, '0')}.${date.year}';
    }

    final picked = await showDatePicker(
      context: context,
      locale: const Locale('de', 'DE'),
      initialDate: _ausgewaehtesMonatJahr ?? now,
      firstDate: DateTime(1900),
      lastDate: now.add(const Duration(days: 365)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() {
        _ausgewaehtesMonatJahr = picked;
        _datumAuswahlController.text =
            '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datum geändert auf ${formatMonthYear(picked)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        actionsPadding: EdgeInsets.all(10),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _pickDate(context),
            icon: const Icon(Icons.calendar_today, size: 14),
            label: Text(
              _ausgewaehtesMonatJahr != null
                  ? "${_ausgewaehtesMonatJahr!.day.toString().padLeft(2, '0')}.${_ausgewaehtesMonatJahr!.month.toString().padLeft(2, '0')}.${_ausgewaehtesMonatJahr!.year}"
                  : "Datum wählen",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CEDColors.gradientStart, CEDColors.gradientend],
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    DatumRad(
                      key: ValueKey(
                        '${_ausgewaehtesMonatJahr!.year}-${_ausgewaehtesMonatJahr!.month}-${_ausgewaehtesMonatJahr!.day}',
                      ),
                      year: _ausgewaehtesMonatJahr!.year,
                      month: _ausgewaehtesMonatJahr!.month,
                      initialDay: _ausgewaehtesMonatJahr!.day,
                      onDateSelected: (date) {
                        setState(() {
                          _ausgewaehtesMonatJahr = date;
                          _datumAuswahlController.text =
                              '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _buildButton('Symptome', 0),
                        _buildButton('Stuhlgang', 1),
                        _buildButton('Mahlzeiten', 2),
                        _buildButton('Stimmung', 3),
                      ],
                    ),
                    const Divider(height: 16),
                    // Hier KEIN Expanded, stattdessen einfach Container
                    Container(
                      alignment: Alignment.center,
                      child: switch (_ausgewaehlteSeite) {
                        0 => SymptomeFuerDatum(
                          filterDatum: _ausgewaehtesMonatJahr!,
                        ),
                        1 => StuhlgangEintraegeFuerDatum(
                          filterDatum: _ausgewaehtesMonatJahr!,
                        ),
                        2 => EssTagebuchFuerDatum(
                          filterDatum: _ausgewaehtesMonatJahr!,
                        ),
                        3 => SeelenLogFuerDatum(
                          filterDatum: _ausgewaehtesMonatJahr!,
                        ),
                        _ => const Text(
                          'Keine Einträge für diese Seite implementiert.',
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, int index) {
    return TextButton(
      onPressed: () => setState(() => _ausgewaehlteSeite = index),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          _ausgewaehlteSeite == index ? Colors.amberAccent : Colors.transparent,
        ),
      ),
      child: Text(label),
    );
  }
}
