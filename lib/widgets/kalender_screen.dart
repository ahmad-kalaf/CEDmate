import 'dart:async';
import 'package:cedmate/services/symptom_service.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/services/mahlzeit_service.dart';
import 'package:cedmate/services/stimmung_service.dart';

import 'package:cedmate/widgets/ced_drawer.dart';
import 'package:cedmate/widgets/datum_rad.dart';
import 'package:cedmate/widgets/ess_tagebuch_fuer_datum.dart';
import 'package:cedmate/widgets/seelen_log_fuer_datum.dart';
import 'package:cedmate/widgets/stuhlgang_eintraege_fuer_datum.dart';
import 'package:cedmate/widgets/symptome_fuer_datum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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

  late int _ausgewaehlteSeite;

  final Map<String, List<String>> _events = {};

  String _key(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";

  String _monthPrefix(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, "0")}";

  StreamSubscription? _symptomSub;
  StreamSubscription? _stuhlgangSub;
  StreamSubscription? _mahlzeitSub;
  StreamSubscription? _stimmungSub;

  void _updateEvents(
    DateTime month,
    Iterable<MapEntry<DateTime, String>> entries,
  ) {
    setState(() {
      for (var entry in entries) {
        final key = _key(entry.key);
        _events.putIfAbsent(key, () => []);
        if (!_events[key]!.contains(entry.value)) {
          _events[key]!.add(entry.value);
        }
      }
    });
  }

  void _ladeAlleDatenFuerMonat(DateTime month) {
    // Monatseinträge einmal löschen
    final prefix = _monthPrefix(month);
    setState(() {
      _events.removeWhere((k, _) => k.startsWith(prefix));
    });

    _ladeSymptome(month);
    _ladeStuhlgang(month);
    _ladeMahlzeiten(month);
    _ladeStimmungen(month);
  }

  void _ladeSymptome(DateTime month) {
    final s = context.read<SymptomService>();
    _symptomSub?.cancel();

    _symptomSub = s.ladeFuerMonatJahr(month.month, month.year).listen((list) {
      _updateEvents(month, list.map((e) => MapEntry(e.startZeit, "symptom")));
    });
  }

  void _ladeStuhlgang(DateTime month) {
    final s = context.read<StuhlgangService>();
    _stuhlgangSub?.cancel();

    _stuhlgangSub = s.ladeFuerMonatJahr(month.month, month.year).listen((list) {
      _updateEvents(
        month,
        list.map((e) => MapEntry(e.eintragZeitpunkt, "stuhlgang")),
      );
    });
  }

  void _ladeMahlzeiten(DateTime month) {
    final s = context.read<MahlzeitService>();
    _mahlzeitSub?.cancel();

    _mahlzeitSub = s.ladeFuerMonatJahr(month.month, month.year).listen((list) {
      _updateEvents(
        month,
        list.map((e) => MapEntry(e.mahlzeitZeitpunkt, "mahlzeit")),
      );
    });
  }

  void _ladeStimmungen(DateTime month) {
    final s = context.read<StimmungService>();
    _stimmungSub?.cancel();

    _stimmungSub = s
        .ladeStimmungenFuerMonatJahr(month.month, month.year)
        .listen((list) {
          _updateEvents(
            month,
            list.map((e) => MapEntry(e.stimmungsZeitpunkt, "stimmung")),
          );
        });
  }

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _ausgewaehtesMonatJahr = DateTime.now();
    _datumAuswahlController.text =
        "${_ausgewaehtesMonatJahr!.day}.${_ausgewaehtesMonatJahr!.month}.${_ausgewaehtesMonatJahr!.year}";
    _ausgewaehlteSeite = widget.ausgewaehlteSeite;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ladeAlleDatenFuerMonat(_ausgewaehtesMonatJahr!);
    });
  }

  @override
  void dispose() {
    _symptomSub?.cancel();
    _stuhlgangSub?.cancel();
    _mahlzeitSub?.cancel();
    _stimmungSub?.cancel();
    super.dispose();
  }

  Future<DateTime?> showCalendarDialog(
    BuildContext context,
    DateTime initialDate,
  ) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return _CalendarDialog(initialDate: initialDate);
      },
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CEDDrawer(),
      appBar: AppBar(
        title: const Text('Kalender'),
        actionsPadding: EdgeInsets.all(10),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final picked = await showCalendarDialog(
                context,
                _ausgewaehtesMonatJahr!,
              );
              if (picked != null) {
                setState(() {
                  _ausgewaehtesMonatJahr = picked;
                  _datumAuswahlController.text =
                      "${picked.day}.${picked.month}.${picked.year}";
                });
                _ladeAlleDatenFuerMonat(picked);
              }
            },
            icon: const Icon(Icons.calendar_today, size: 14),
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(CEDColors.background),
              side: WidgetStatePropertyAll(
                BorderSide(color: CEDColors.background, width: 3),
              ),
            ),
            label: Text(
              "${_ausgewaehtesMonatJahr!.day.toString().padLeft(2, '0')}.${_ausgewaehtesMonatJahr!.month.toString().padLeft(2, '0')}.${_ausgewaehtesMonatJahr!.year}",
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CEDColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CEDColors.border, width: 1),
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
                    events: _events,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 5,
                    children: [
                      _buildButton('Symptome', 0, CEDColors.eventSymptom),
                      _buildButton('Stuhlgang', 1, CEDColors.eventStuhlgang),
                      _buildButton('Mahlzeiten', 2, CEDColors.eventMahlzeit),
                      _buildButton('Stimmung', 3, CEDColors.eventStimmung),
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
    );
  }

  Widget _buildButton(String label, int index, Color color) {
    return TextButton(
      onPressed: () => setState(() => _ausgewaehlteSeite = index),
      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(color)),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CalendarDialog extends StatefulWidget {
  final DateTime initialDate;

  const _CalendarDialog({required this.initialDate});

  @override
  State<_CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<_CalendarDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  final Map<String, List<String>> _events = {};

  StreamSubscription? _symptomSub;
  StreamSubscription? _stuhlgangSub;
  StreamSubscription? _mahlzeitSub;
  StreamSubscription? _stimmungSub;

  String _key(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";

  String _prefix(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, "0")}";

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;

    _ladeMonat(_focusedDay);
  }

  @override
  void dispose() {
    _symptomSub?.cancel();
    _stuhlgangSub?.cancel();
    _mahlzeitSub?.cancel();
    _stimmungSub?.cancel();
    super.dispose();
  }

  void _ladeMonat(DateTime month) {
    // Alte Events entfernen
    _events.removeWhere((k, _) => k.startsWith(_prefix(month)));

    // Alte Subs canceln
    _symptomSub?.cancel();
    _stuhlgangSub?.cancel();
    _mahlzeitSub?.cancel();
    _stimmungSub?.cancel();

    final ctx = context;

    // --- Symptome ---
    _symptomSub = ctx
        .read<SymptomService>()
        .ladeFuerMonatJahr(month.month, month.year)
        .listen((list) {
          for (var e in list) {
            final k = _key(e.startZeit);
            _events.putIfAbsent(k, () => []);
            if (!_events[k]!.contains("symptom")) {
              _events[k]!.add("symptom");
            }
          }
          setState(() {});
        });

    // --- Stuhlgang ---
    _stuhlgangSub = ctx
        .read<StuhlgangService>()
        .ladeFuerMonatJahr(month.month, month.year)
        .listen((list) {
          for (var e in list) {
            final k = _key(e.eintragZeitpunkt);
            _events.putIfAbsent(k, () => []);
            if (!_events[k]!.contains("stuhlgang")) {
              _events[k]!.add("stuhlgang");
            }
          }
          setState(() {});
        });

    // --- Mahlzeiten ---
    _mahlzeitSub = ctx
        .read<MahlzeitService>()
        .ladeFuerMonatJahr(month.month, month.year)
        .listen((list) {
          for (var e in list) {
            final k = _key(e.mahlzeitZeitpunkt);
            _events.putIfAbsent(k, () => []);
            if (!_events[k]!.contains("mahlzeit")) {
              _events[k]!.add("mahlzeit");
            }
          }
          setState(() {});
        });

    // --- Stimmung ---
    _stimmungSub = ctx
        .read<StimmungService>()
        .ladeStimmungenFuerMonatJahr(month.month, month.year)
        .listen((list) {
          for (var e in list) {
            final k = _key(e.stimmungsZeitpunkt);
            _events.putIfAbsent(k, () => []);
            if (!_events[k]!.contains("stimmung")) {
              _events[k]!.add("stimmung");
            }
          }
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CEDColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(10),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => _key(day) == _key(_selectedDay),

              eventLoader: (day) => _events[_key(day)] ?? [],

              onDaySelected: (d, f) {
                setState(() {
                  _selectedDay = d;
                  _focusedDay = f;
                });
              },

              onPageChanged: (newFocusedDay) {
                _focusedDay = newFocusedDay;
                _ladeMonat(_focusedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: CEDColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: CEDColors.primary,
                  shape: BoxShape.circle,
                ),
              ),

              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(height: 1),
                weekendStyle: TextStyle(height: 1),
              ),

              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((e) {
                        final color = switch (e) {
                          "symptom" => CEDColors.eventSymptom,
                          "stuhlgang" => CEDColors.eventStuhlgang,
                          "mahlzeit" => CEDColors.eventMahlzeit,
                          "stimmung" => CEDColors.eventStimmung,
                          _ => Colors.grey,
                        };
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text("Abbrechen"),
                  onPressed: () => Navigator.pop(context, null),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CEDColors.primary,
                  ),
                  child: const Text("OK"),
                  onPressed: () => Navigator.pop(context, _selectedDay),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
