import 'package:cedmate/widgets/datum_rad.dart';
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
              _ausgewaehtesMonatJahr != null
                  ? "${_ausgewaehtesMonatJahr!.month.toString().padLeft(2, '0')}.${_ausgewaehtesMonatJahr!.year}"
                  : "Monat wählen",
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(40, 40),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // DatumRad: auch Zustand mit dem ausgewählten Datum aktualisieren
                DatumRad(
                  key: ValueKey(
                    '${_ausgewaehtesMonatJahr!.year}-${_ausgewaehtesMonatJahr!.month}-${_ausgewaehtesMonatJahr!.day}',
                  ),
                  year: _ausgewaehtesMonatJahr!.year,
                  month: _ausgewaehtesMonatJahr!.month,
                  initialDay: _ausgewaehtesMonatJahr!.day,
                  onDateSelected: (date) {
                    setState(() {
                      // komplettes Datum merken (Tag/Monat/Jahr)
                      _ausgewaehtesMonatJahr = date;
                      _datumAuswahlController.text =
                          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                    });
                  },
                ),

                /// aktuelen Datum anzeigen
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ein Dropdown für Auswahl zwischen Symptomen, Stuhlgang, Mahlzeit-Einträge und Stimmungs-Einträge
                    const Icon(Icons.menu),
                    const SizedBox(width: 10),
                    // Label für aktuelles ausgewähltes Datum
                    Flexible(
                      child: Text(
                        _datumAuswahlController.text.isNotEmpty
                            ? 'Ausgewählt: ${_datumAuswahlController.text}'
                            : 'Kein Datum ausgewählt',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SymptomeFuerDatum(
              filterDatum: DateTime(
                _ausgewaehtesMonatJahr!.year,
                _ausgewaehtesMonatJahr!.month,
                _ausgewaehtesMonatJahr!.day,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
