import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:cedmate/services/symptom_service.dart';
import 'package:cedmate/widgets/CEDColors.dart';
import 'package:cedmate/widgets/ess_tagebuch_fuer_monat.dart';
import 'package:cedmate/widgets/seelen_log_fuer_monat.dart';
import 'package:cedmate/widgets/stuhlgang_eintraege_fuer_monat.dart';
import 'package:cedmate/widgets/symptome_fuer_datum.dart';
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

import 'package:cedmate/widgets/gelb_layout.dart'; // <--- WICHTIG

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/mahlzeit_service.dart';
import '../services/stimmung_service.dart';
import '../services/stuhlgang_service.dart';
import 'daten_exportieren.dart';
import 'impressum_credits_screen.dart';

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

      final results = await Future.wait<int>([
        symptomService.zaehleFuerDatum(_heutigesDatum),
        stuhlgangService.zaehleFuerDatum(_heutigesDatum),
        mahlzeitService.zaehleFuerDatum(_heutigesDatum),
        stimmungService.zaehleFuerDatum(_heutigesDatum),
      ]);

      if (!mounted) return;

      setState(() {
        _symptomeHeute = results[0];
        _stuhlgaengeHeute = results[1];
        _mahlzeitenHeute = results[2];
        _stimmungenHeute = results[3];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _symptomeHeute = -1;
        _stuhlgaengeHeute = -1;
        _mahlzeitenHeute = -1;
        _stimmungenHeute = -1;
      });
    } finally {
      if (mounted) setState(() => _isLoadingEintraege = false);
    }
  }

  Future<void> _ladeAnamneseDaten() async {
    final anamnese = await anamneseService.ladeAnamnese();
    if (!mounted) return;

    setState(() {
      _hatAnamnesedaten = anamnese != null;
      _isLoading = false;
    });
  }

  Future<void> _navigiereZurSeite<T>(Widget seite) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => seite));
    _aktualisiereAnzahlEintraege();
  }

  // -------------------------------------------------------
  //  THEME-BEREINIGTE Widgets (unverändert)
  // -------------------------------------------------------

  Widget _iconTextKachel(String titel, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: CEDColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Icon(icon, color: Colors.lightBlueAccent),
              ),
              const SizedBox(height: 8),
              Text(
                titel,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: CEDColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Icon(icon, color: Colors.lightBlueAccent),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zahl.toString(),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        titel,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  // -------------------------------------------------------
  //  BUILD → ERSETZT Scaffold durch GelbLayout
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppUser?>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GelbLayout(
      title: "CEDmate",
      actions: [AusloggenButton(auth: auth, user: user)],
      child: _hatAnamnesedaten
          ? _buildHomeContent(context, user)
          : _buildKeineAnamnese(context),
    );
  }

  // -------------------------------------------------------
  //  Sub-Widgets (unverändert)
  // -------------------------------------------------------

  Widget _buildKeineAnamnese(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Medizinisches Profil noch nicht ausgefüllt',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _navigiereZurSeite(const AnamneseScreen()),
          child: Text(
            'Jetzt ausfüllen',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContent(BuildContext context, AppUser? user) {
    return Column(
      children: [
        Text(
          user != null ? 'Hallo ${user.username}' : 'Hallo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '${_wochentage[_heutigesDatum.weekday - 1]}, '
          '${_heutigesDatum.day}.${_heutigesDatum.month}.${_heutigesDatum.year}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Schnell erfassen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        Row(
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
          children: [
            _iconTextKachel(
              'Mahlzeit Eintragen',
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
        const Divider(height: 30, thickness: 3),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Heute in Zahlen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        _isLoadingEintraege
            ? const SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      _iconZahlTextKachel(
                        Icons.sick,
                        'Symptome',
                        _symptomeHeute,
                        () => _navigiereZurSeite(
                          KalenderScreen(ausgewaehlteSeite: 0),
                        ),
                      ),
                      _iconZahlTextKachel(
                        Icons.wc,
                        'Stuhlgänge',
                        _stuhlgaengeHeute,
                        () => _navigiereZurSeite(
                          KalenderScreen(ausgewaehlteSeite: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _iconZahlTextKachel(
                        Icons.restaurant_menu,
                        'Mahlzeiten',
                        _mahlzeitenHeute,
                        () => _navigiereZurSeite(
                          KalenderScreen(ausgewaehlteSeite: 2),
                        ),
                      ),
                      _iconZahlTextKachel(
                        Icons.mood,
                        'Stimmungen',
                        _stimmungenHeute,
                        () => _navigiereZurSeite(
                          KalenderScreen(ausgewaehlteSeite: 3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        const Divider(height: 30, thickness: 3),
        Row(
          children: [
            _iconTextKachel(
              'Toiletten finden',
              Icons.explore,
              () => _navigiereZurSeite(HilfeFuerUnterwegs()),
            ),
            _iconTextKachel(
              'Daten exportieren',
              Icons.upload_file,
              () => _navigiereZurSeite(DatenExportieren()),
            ),
          ],
        ),
        const Divider(height: 30, thickness: 3),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Verschaffe dir einen Überblick',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _iconTextKachel(
              'Kalender',
              Icons.calendar_month,
              () => _navigiereZurSeite(KalenderScreen()),
            ),
            _iconTextKachel(
              'Statistiken',
              Icons.bar_chart,
              () => _navigiereZurSeite(Statistiken()),
            ),
          ],
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCardPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
