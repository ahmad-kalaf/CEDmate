import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:cedmate/widgets/anamnese_screen.dart';
import 'package:cedmate/widgets/ausloggen_button.dart';
import 'package:cedmate/widgets/datum_rad.dart';
import 'package:cedmate/widgets/profil_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

/// Beispiel-Home (geschützter Bereich).
/// Hier ist die eigentliche CEDmate-Funktionalität,
/// die man nach dem Login benutzen kann.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService auth;
  late final AnamneseService anamneseService;
  bool _isLoading = true;
  bool _hatAnamnesedaten = false;
  final TextEditingController _datumAuswahlController = TextEditingController();
  DateTime? _ausgewaehtesMonatJahr;

  @override
  void initState() {
    super.initState();
    auth = context.read<AuthService>();
    anamneseService = context.read<AnamneseService>();
    _ladeAnamneseDaten();
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

  Future<void> _ladeAnamneseDaten() async {
    final anamnese = await anamneseService.ladeAnamnese();
    setState(() {
      // hier muss geprüft werden, ob Anamnesedaten vorhanden sind
      if (anamnese != null) {
        _hatAnamnesedaten = true;
      } else {
        _hatAnamnesedaten = false;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppUser?>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                title: const Text('Mein Profil'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('CEDmate'),
        actions: [AusloggenButton(auth: auth, user: user)],
      ),
      body: !_hatAnamnesedaten
          ? SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Medizinisches Profil noch nicht ausgefüllt',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Hier kannst du die Navigation zur Anamnese-Seite hinzufügen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AnamneseScreen(),
                              ),
                            );
                          },
                          child: const Text('Jetzt ausfüllen'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user?.username != null
                                  ? 'Hi, ${user!.username}'
                                  : 'Hi',
                              style: const TextStyle(fontSize: 15),
                            ),
                            Row(
                              children: [
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                  ),
                                  icon: const Icon(Icons.calendar_today),
                                ),

                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),

                        DatumRad(
                          key: ValueKey(
                            '${_ausgewaehtesMonatJahr!.year}-${_ausgewaehtesMonatJahr!.month}',
                          ),
                          year: _ausgewaehtesMonatJahr!.year,
                          month: _ausgewaehtesMonatJahr!.month,
                          initialDay: _ausgewaehtesMonatJahr!.day,
                          onDateSelected: (date) {
                            setState(() {
                              _datumAuswahlController.text =
                                  '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                            });
                          },
                        ),

                        /// aktuelen Datum anzeigen
                        const SizedBox(height: 20),
                        Text(
                          _datumAuswahlController.text.isNotEmpty
                              ? 'Ausgewähltes Datum: ${_datumAuswahlController.text}'
                              : 'Kein Datum ausgewählt',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

      /// Auf heute zurücksetzen, nur sichbar, wenn
      /// nicht aktueller Monat ausgewählt ist
      floatingActionButton:
          (!(_ausgewaehtesMonatJahr != null &&
              _ausgewaehtesMonatJahr!.month == DateTime.now().month &&
              _ausgewaehtesMonatJahr!.year == DateTime.now().year))
          ? ElevatedButton(
              onPressed: () {
                setState(() {
                  _ausgewaehtesMonatJahr = DateTime.now();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Zurück auf heutiges Datum gesetzt'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(40, 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
              child: const Text('Heute'),
            )
          : null,
    );
  }
}
