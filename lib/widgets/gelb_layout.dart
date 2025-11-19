import 'package:flutter/material.dart';
import 'package:cedmate/widgets/impressum_credits_screen.dart';
import 'package:cedmate/widgets/profil_screen.dart';
import 'package:cedmate/widgets/stuhlgang_eintraege_fuer_monat.dart';
import 'package:cedmate/widgets/seelen_log_fuer_monat.dart';
import 'package:cedmate/widgets/ess_tagebuch_fuer_monat.dart';
import 'package:cedmate/widgets/symptome_fuer_monat.dart';
import 'package:cedmate/widgets/hilfe_fuer_unterwegs.dart';

import 'CEDColors.dart';

class GelbLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const GelbLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.amberAccent,
        actions: actions,
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
                  border: Border.all(color: CEDColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------
  //   Fester Drawer
  // -------------------------
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amberAccent, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics, size: 40),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CEDmate',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Erfassen. Verstehen. Verbessern.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Einträge
            ListTile(
              title: Text('Mein Profil'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilScreen()),
              ),
            ),
            ListTile(
              title: Text('Symptom-Radar'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SymptomeFuerMonat()),
              ),
            ),
            ListTile(
              title: Text('Stuhl-Tagebuch'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StuhlgangEintraegeFuerMonat(),
                ),
              ),
            ),
            ListTile(
              title: Text('Ess-Tagebuch'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EssTagebuchFuerMonat()),
              ),
            ),
            ListTile(
              title: Text('Seelen-Log'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StimmungFuerMonat()),
              ),
            ),
            ListTile(
              title: Text('Toiletten finden'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HilfeFuerUnterwegs()),
              ),
            ),
            ListTile(
              title: Text('Impressum und Credits'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImpressumCreditsScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
