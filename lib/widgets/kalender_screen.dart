import 'package:cedmate/widgets/datum_rad.dart';
import 'package:cedmate/widgets/stuhlgang_eintraege_fuer_datum.dart';
import 'package:cedmate/widgets/symptome_fuer_datum.dart';
import 'package:flutter/material.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  final TextEditingController _datumAuswahlController = TextEditingController();
  DateTime? _ausgewaehtesMonatJahr;

  // 0 -> Symptome, 1 -> Stuhlgang, 2 -> Mahlzeiten, 3 -> Stimmung
  int _ausgewaehlteSeite = 0;

  @override
  void initState() {
    super.initState();
    _ausgewaehtesMonatJahr = DateTime.now();
    _datumAuswahlController.text =
        '${DateTime.now().day} .${DateTime.now().month}.${DateTime.now().year}';
  }

  /// Öffnet den nativen DatePicker (nur Kalender!)
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();

    // Anzeigeformat nur Monat + Jahr
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
        // das exakte Datum merken (nicht nur Monat!)
        _ausgewaehtesMonatJahr = picked;
        _datumAuswahlController.text =
            '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
      });

      // optional: kurze Info
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
        actions: [
          // Monat/Jahr-Auswahl
          ElevatedButton.icon(
            onPressed: () => _pickDate(context),
            label: Text(
              // format tt.mm.jjjj
              _ausgewaehtesMonatJahr != null
                  ? "${_ausgewaehtesMonatJahr!.day.toString().padLeft(2, '0')}.${_ausgewaehtesMonatJahr!.month.toString().padLeft(2, '0')}.${_ausgewaehtesMonatJahr!.year}"
                  : "Monat wählen",
              style: TextStyle(fontSize: 12),
            ),
            icon: const Icon(Icons.calendar_today, size: 12),
          ),
        ],
      ),
      // 👇 nur einmal "body:"
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Oberer Bereich (Datum + Buttons)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.35,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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

                      // Buttons: umbrechend, mit Abständen
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
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // Unterer Bereich: füllt den Rest
              Expanded(
                child: switch (_ausgewaehlteSeite) {
                  0 => SymptomeFuerDatum(filterDatum: _ausgewaehtesMonatJahr!),
                  1 => StuhlgangEintraegeFuerDatum(
                    filterDatum: _ausgewaehtesMonatJahr!,
                  ),
                  _ => const Center(
                    child: Text(
                      'Keine Einträge für diese Seite implementiert.',
                    ),
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // 👉 muss außerhalb von build stehen
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
