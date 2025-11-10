import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:cedmate/services/symptom_service.dart';
import 'package:cedmate/widgets/ess_tagebuch_fuer_monat.dart';
import 'package:cedmate/widgets/seelen_log_fuer_monat.dart';
import 'package:cedmate/widgets/stuhlgang_eintraege_fuer_monat.dart';
import 'package:cedmate/widgets/symptome_fuer_monat.dart';
import 'package:cedmate/widgets/anamnese_screen.dart';
import 'package:cedmate/widgets/ausloggen_button.dart';
import 'package:cedmate/widgets/hilfe_fuer_unterwegs.dart';
import 'package:cedmate/widgets/kalender_screen.dart';
import 'package:cedmate/widgets/mahlzeit_eintragen.dart';
import 'package:cedmate/widgets/profil_screen.dart';
import 'package:cedmate/widgets/statistiken.dart';
import 'package:cedmate/widgets/stimmung_notieren.dart';
import 'package:cedmate/widgets/stuhlgang_notieren.dart';
import 'package:cedmate/widgets/symptom_erfassen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/mahlzeit_service.dart';
import '../services/stimmung_service.dart';
import '../services/stuhlgang_service.dart';
import 'daten_exportieren.dart';
import 'impressum_credits_screen.dart';

/// Home (geschützter Bereich).
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
  bool _isLoadingEintraege = false;
  int _symptomeHeute = 0;
  int _stuhlgaengeHeute = 0;
  int _mahlzeitenHeute = 0;
  int _stimmungenHeute = 0;

  // heutiges Datum TT.MM.JJJJ
  final DateTime _heutigesDatum = DateTime.now();
  final List<String> _wochentage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  void initState() {
    super.initState();
    auth = context.read<AuthService>();
    anamneseService = context.read<AnamneseService>();
    _ladeAnamneseDaten();
    _aktualisiereAnzahlEintraege();
  }

  Future<void> _aktualisiereAnzahlEintraege() async {
    setState(() => _isLoadingEintraege = true);

    try {
      final symptomService = context.read<SymptomService>();
      final stuhlgangService = context.read<StuhlgangService>();
      final mahlzeitService = context.read<MahlzeitService>();
      final stimmungService = context.read<StimmungService>();

      // Alle Firestore-Abfragen parallel starten
      final results = await Future.wait<int>([
        symptomService.zaehleFuerDatum(_heutigesDatum),
        stuhlgangService.zaehleFuerDatum(_heutigesDatum),
        mahlzeitService.zaehleFuerDatum(_heutigesDatum),
        stimmungService.zaehleFuerDatum(_heutigesDatum),
      ]);

      if (mounted) {
        setState(() {
          _symptomeHeute = results[0];
          _stuhlgaengeHeute = results[1];
          _mahlzeitenHeute = results[2];
          _stimmungenHeute = results[3];
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Fehler beim Aktualisieren der Einträge: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _symptomeHeute = -1;
          _stuhlgaengeHeute = -1;
          _mahlzeitenHeute = -1;
          _stimmungenHeute = -1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Daten konnten nicht geladen werden. Bitte überprüfe deine Internetverbindung.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent.shade200,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Erneut versuchen',
              textColor: Colors.white,
              onPressed: _aktualisiereAnzahlEintraege,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingEintraege = false);
    }
  }

  Future<void> _navigiereZurSeite<T>(Widget seite) async {
    await Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (context) => seite));
    _aktualisiereAnzahlEintraege();
  }

  Future<void> _ladeAnamneseDaten() async {
    final anamnese = await anamneseService.ladeAnamnese();
    setState(() {
      if (anamnese != null) {
        _hatAnamnesedaten = true;
      } else {
        _hatAnamnesedaten = false;
      }
      _isLoading = false;
    });
  }

  Widget _iconZahlTextKachel(
    IconData icon,
    String titel,
    int zahl,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zahl.toString(), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text(titel, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconTextKachel(String titel, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(titel, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
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
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.analytics, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'CEDmate',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Erfassen. Verstehen. Verbessern.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Mein Profil'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilScreen()),
                  );
                },
              ),
              ListTile(
                title: const Text('Symptom-Radar'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SymptomeFuerMonat(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Stuhl-Tagebuch'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StuhlgangEintraegeFuerMonat(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Ess-Tagebuch'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EssTagebuchFuerMonat()),
                  );
                },
              ),
              ListTile(
                title: const Text('Seelen-Log'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StimmungFuerMonat()),
                  );
                },
              ),
              ListTile(
                title: const Text('Impressum und Credits'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ImpressumCreditsScreen(),
                    ),
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
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user != null ? 'Hallo ${user.username}' : 'Hallo'),
                        Text(
                          '${_wochentage[_heutigesDatum.weekday - 1]}, '
                          '${_heutigesDatum.day}.${_heutigesDatum.month}.${_heutigesDatum.year}',
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.flash_on),
                              SizedBox(width: 5),
                              Text('Schnell erfassen'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _iconTextKachel(
                              'Symptom erfassen',
                              Icons.sick,
                              () => _navigiereZurSeite(SymptomErfassen()),
                            ),
                            _iconTextKachel(
                              'Stuhlgang notieren',
                              Icons.wc,
                              () => _navigiereZurSeite(StuhlgangNotieren()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _iconTextKachel(
                              'Mahlzeit Eintagen',
                              Icons.restaurant_menu,
                              () => _navigiereZurSeite(MahlzeitEintragen()),
                            ),
                            _iconTextKachel(
                              'Stimmung notieren',
                              Icons.mood,
                              () => _navigiereZurSeite(StimmungNotieren()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.numbers),
                              SizedBox(width: 5),
                              Text('Heute in Zahlen'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _isLoadingEintraege
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _iconZahlTextKachel(
                                        Icons.sick,
                                        'Symptome heute',
                                        _symptomeHeute,
                                        () => _navigiereZurSeite(
                                          const SymptomeFuerMonat(),
                                        ),
                                      ),
                                      _iconZahlTextKachel(
                                        Icons.wc,
                                        'Stuhlgänge',
                                        _stuhlgaengeHeute,
                                        () => _navigiereZurSeite(
                                          const StuhlgangEintraegeFuerMonat(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _iconZahlTextKachel(
                                        Icons.restaurant_menu,
                                        'Mahlzeiten',
                                        _mahlzeitenHeute,
                                        () => _navigiereZurSeite(
                                          EssTagebuchFuerMonat(),
                                        ),
                                      ),
                                      _iconZahlTextKachel(
                                        Icons.mood,
                                        'Stimmung',
                                        _stimmungenHeute,
                                        () => _navigiereZurSeite(
                                          StimmungFuerMonat(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 160,
                          child: PageView(
                            controller: PageController(viewportFraction: 0.9),
                            padEnds: false,
                            children: [
                              InkWell(
                                splashColor: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  _navigiereZurSeite(HilfeFuerUnterwegs());
                                },
                                child: Card(
                                  elevation: 6,
                                  margin: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.explore),
                                        SizedBox(height: 10),
                                        Text('Hilfe für Unterwegs'),
                                        SizedBox(height: 5),
                                        Text(
                                          'Toiletten in der Nähe',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  _navigiereZurSeite(DatenExportieren());
                                },
                                child: Card(
                                  elevation: 6,
                                  margin: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.upload_file),
                                        SizedBox(height: 10),
                                        Text('Daten exportieren'),
                                        SizedBox(height: 5),
                                        Text(
                                          'Exportiere deine Daten für den Arztbesuch',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.show_chart),
                              SizedBox(width: 5),
                              Text('Verschaffe dir einen Überblick'),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _iconTextKachel(
                              'Kalender',
                              Icons.calendar_month,
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => KalenderScreen(),
                                ),
                              ),
                            ),
                            _iconTextKachel(
                              'Statistiken',
                              Icons.bar_chart,
                              () => _navigiereZurSeite(Statistiken()),
                            ),
                          ],
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
