import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:cedmate/widgets/anamnese_screen.dart';
import 'package:cedmate/widgets/ausloggen_button.dart';
import 'package:cedmate/widgets/kalender_screen.dart';
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
      // hier muss geprüft werden, ob Anamnesedaten vorhanden sind
      if (anamnese != null) {
        _hatAnamnesedaten = true;
      } else {
        _hatAnamnesedaten = false;
      }
      _isLoading = false;
    });
  }

  Widget _buildKachel(String titel, IconData icon, VoidCallback onTap) {
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
              Icon(icon, size: 30, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                titel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                          child: Text('+ Schnell erfassen'),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKachel('Symptom erfassen', Icons.sick, () {}),
                            _buildKachel('Stuhlgang notieren', Icons.wc, () {}),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKachel(
                              'Mahlzeit Eintagen',
                              Icons.restaurant_menu,
                              () {},
                            ),
                            _buildKachel(
                              'Stimmung notieren',
                              Icons.mood,
                              () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => KalenderScreen(),
                              ),
                            );
                          },
                          label: Text('Zum Kalender'),
                          icon: Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
