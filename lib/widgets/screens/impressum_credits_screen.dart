import 'package:cedmate/widgets/layout/ced_layout.dart';
import 'package:flutter/material.dart';

class ImpressumCreditsScreen extends StatelessWidget {
  const ImpressumCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CEDLayout(
      title: 'Impressum und Credits',
      child: Column(
        children: [
          const Text(
            'Impressum',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'CEDmate ist ein nicht-kommerzielles Studienprojekt '
            'an der Hochschule für Angewandte Wissenschaften Hamburg (HAW Hamburg). '
            'Die App dient ausschließlich zu Forschungs-, Lehr- und Demonstrationszwecken '
            'im Rahmen des Moduls "Digital Health / Health Informatics" (Wintersemester 2025/26).',
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Datenschutz und Haftung',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Diese App erhebt, speichert oder verarbeitet keine personenbezogenen Daten '
            'zu kommerziellen Zwecken. Alle Daten, die über Firebase gespeichert werden, '
            'unterliegen der DSGVO und werden nur im Rahmen des Projekts verwendet. '
            'Für Inhalte externer Links oder von Drittanbietern (z. B. OpenStreetMap) '
            'wird keine Haftung übernommen.',
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Credits und Quellen',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kartendaten: © OpenStreetMap contributors, ODbL 1.0 '
            '(https://www.openstreetmap.org/copyright)\n'
            'Icons: Material Design Icons (Google)\n'
            'Framework: Flutter (Google)\n'
            'Verwendete Pakete: flutter_map, provider, firebase_core, geolocator, '
            'connectivity_plus, http, shared_preferences\n'
            'API: Overpass API für Toilettendaten',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Team und Mitwirkende',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '- Ahmad Kalaf (Frontend, Backend, Firebase, Deployment)\n'
            '- Afrane Kwame Berquin (Backend, GUI, Datenbank)\n'
            '- Miriam Schwarz (Life Sciences, Anforderungen Evaluation)\n'
            '- Aliena Glatzel (Life Sciences, Anforderungen Evaluation)\n'
            '- Larissa Pychlau (Python-Analysen und Statistik)\n'
            '- Benedikt Löhn (Python-Analysen und Statistik)',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Lizenz',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dieses Projekt steht unter der "CEDmate License – Modified MIT" '
            '(Collective Non-Commercial Use Restriction, Version 1.0, Oktober 2025). '
            'Kommerzielle Nutzung, Weitergabe oder Veröffentlichung '
            'nur mit schriftlicher Zustimmung aller genannten Autorinnen und Autoren.',
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 12),
          const SelectableText(
            'Lizenz: https://github.com/ahmad-kalaf/CEDmate/blob/main/LICENSE',
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2025 CEDmate Team\n'
              'Nicht-kommerzielle Anwendung',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
