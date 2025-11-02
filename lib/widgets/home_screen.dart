import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:cedmate/widgets/anamnese_screen.dart';
import 'package:cedmate/widgets/ausloggen_button.dart';
import 'package:cedmate/widgets/kalender_screen.dart';
import 'package:cedmate/widgets/profil_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

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
  // heutiges Datum TT.MM.JJJJ
  final DateTime _heutigesDatum = DateTime.now();
  final List<String> _wochentage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  void initState() {
    super.initState();
    auth = context.read<AuthService>();
    anamneseService = context.read<AnamneseService>();
    _ladeAnamneseDaten();
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
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.grey),
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
              Icon(icon, size: 30),
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
                        Text('Hallo, ${user?.username}'),
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
                              () {},
                            ),
                            _iconTextKachel(
                              'Stuhlgang notieren',
                              Icons.wc,
                              () {},
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
                              () {},
                            ),
                            _iconTextKachel(
                              'Stimmung notieren',
                              Icons.mood,
                              () {},
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _iconZahlTextKachel(
                              Icons.sick,
                              'Symptome heute',
                              3,
                              () {},
                            ),
                            _iconZahlTextKachel(
                              Icons.wc,
                              'Stuhlgänge',
                              2,
                              () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _iconZahlTextKachel(
                              Icons.restaurant_menu,
                              'Mahlzeiten',
                              3,
                              () {},
                            ),
                            _iconZahlTextKachel(
                              Icons.mood,
                              'Stimmung',
                              2,
                              () {},
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
                                  print("Hilfe für Unterwegs geklickt");
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
                                          'Toiletten & Restaurants in der Nähe',

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
                                  print("Daten exportieren geklickt");
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
                              () {},
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
