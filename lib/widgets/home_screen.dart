import 'package:cedmate/models/app_user.dart';
import 'package:cedmate/services/anamnese_service.dart';
import 'package:cedmate/services/symptom_service.dart';
import 'package:cedmate/widgets/CEDColors.dart';
import 'package:cedmate/widgets/anamnese_screen.dart';
import 'package:cedmate/widgets/ausloggen_button.dart';
import 'package:cedmate/widgets/hilfe_fuer_unterwegs.dart';
import 'package:cedmate/widgets/kalender_screen.dart';
import 'package:cedmate/widgets/mahlzeit_eintragen.dart';
import 'package:cedmate/widgets/statistiken.dart';
import 'package:cedmate/widgets/stimmung_notieren.dart';
import 'package:cedmate/widgets/stuhlgang_notieren.dart';
import 'package:cedmate/widgets/symptom_erfassen.dart';

import 'package:cedmate/widgets/ced_layout.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/mahlzeit_service.dart';
import '../services/stimmung_service.dart';
import '../services/stuhlgang_service.dart';
import 'daten_exportieren.dart';

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

  // -------------------------------------------------------------------------
  //  NEW CLEAN TILE WIDGETS
  // -------------------------------------------------------------------------

  Widget _homeTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: color, // use passed color
            borderRadius: BorderRadius.circular(16),
            // no border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: CEDColors.iconPrimary, size: 30),
              const SizedBox(height: 10),
              Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeStatTile({
    required IconData icon,
    required String text,
    required int value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: CEDColors.surfaceDark, // same style as other tiles
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: CEDColors.iconSecondary, size: 30),
              const SizedBox(height: 8),

              Text(
                '$value',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppUser?>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return CEDLayout(
      title: "CEDmate",
      actions: [AusloggenButton(auth: auth, user: user)],
      child: _hatAnamnesedaten
          ? _buildHomeContent(context, user)
          : _buildKeineAnamnese(context),
    );
  }

  // -------------------------------------------------------------------------
  // CONTENT
  // -------------------------------------------------------------------------

  Widget _buildKeineAnamnese(BuildContext context) {
    return Column(
      children: [
        Text(
          'Medizinisches Profil noch nicht ausgefüllt',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _navigiereZurSeite(const AnamneseScreen()),
          child: Text('Jetzt ausfüllen'),
        ),
      ],
    );
  }

  Widget _buildHomeContent(BuildContext context, AppUser? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

        const SizedBox(height: 25),
        Text(
          'Schnell erfassen',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            _homeTile(
              icon: Icons.sick,
              text: 'Symptom erfassen',
              onTap: () => _navigiereZurSeite(SymptomErfassen()),
              color: CEDColors.service_symptom,
            ),
            _homeTile(
              icon: Icons.wc,
              text: 'Stuhlgang notieren',
              onTap: () => _navigiereZurSeite(StuhlgangNotieren()),
              color: CEDColors.service_stuhlgang,
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _homeTile(
              icon: Icons.restaurant_menu,
              text: 'Mahlzeit eintragen',
              onTap: () => _navigiereZurSeite(MahlzeitEintragen()),
              color: CEDColors.service_mahlzeit,
            ),
            _homeTile(
              icon: Icons.mood,
              text: 'Stimmung notieren',
              onTap: () => _navigiereZurSeite(StimmungNotieren()),
              color: CEDColors.service_stimmung,
            ),
          ],
        ),

        const SizedBox(height: 30),
        Text('Heute in Zahlen', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),

        _isLoadingEintraege
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    children: [
                      _homeStatTile(
                        icon: Icons.sick,
                        text: 'Symptome',
                        value: _symptomeHeute,
                        onTap: () => _navigiereZurSeite(
                          KalenderScreen(ausgewaehlteSeite: 0),
                        ),
                      ),
                      _homeStatTile(
                        icon: Icons.wc,
                        text: 'Stuhlgänge',
                        value: _stuhlgaengeHeute,
                        onTap: () => _navigiereZurSeite(
                          KalenderScreen(ausgewaehlteSeite: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _homeStatTile(
                        icon: Icons.restaurant_menu,
                        text: 'Mahlzeiten',
                        value: _mahlzeitenHeute,
                        onTap: () => _navigiereZurSeite(
                          KalenderScreen(ausgewaehlteSeite: 2),
                        ),
                      ),
                      _homeStatTile(
                        icon: Icons.mood,
                        text: 'Stimmungen',
                        value: _stimmungenHeute,
                        onTap: () => _navigiereZurSeite(
                          KalenderScreen(ausgewaehlteSeite: 3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

        const SizedBox(height: 30),

        Text(
          'Hilfe für Unterwegs',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _homeTile(
              icon: Icons.explore,
              text: 'Toiletten finden',
              onTap: () => _navigiereZurSeite(HilfeFuerUnterwegs()),
              color: CEDColors.surfaceDark
            ),
            _homeTile(
              icon: Icons.upload_file,
              text: 'Daten exportieren',
              onTap: () => _navigiereZurSeite(DatenExportieren()),
              color: CEDColors.surfaceDark
            ),
          ],
        ),

        const SizedBox(height: 30),

        Text(
          'Verschaffe dir einen Überblick',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _homeTile(
              icon: Icons.calendar_month,
              text: 'Kalender',
              onTap: () => _navigiereZurSeite(KalenderScreen()),
              color: CEDColors.surfaceDark
            ),
            _homeTile(
              icon: Icons.bar_chart,
              text: 'Statistiken',
              onTap: () => _navigiereZurSeite(Statistiken()),
              color: CEDColors.surfaceDark
            ),
          ],
        ),

        const SizedBox(height: 100),
      ],
    );
  }
}
