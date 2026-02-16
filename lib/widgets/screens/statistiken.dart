import 'dart:convert';

import 'package:cedmate/widgets/layout/ced_layout.dart';
import 'package:cedmate/cedmate_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../utils/datei_handler.dart';

class Statistiken extends StatefulWidget {
  const Statistiken({super.key});

  @override
  State<Statistiken> createState() => _StatistikenState();
}

class _StatistikenState extends State<Statistiken> {
  bool _isRunning = false;
  String _status = '';
  List<String> _imageUrls = [];

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  static const String apiUrl =
      'https://cedmate-analytics-api.onrender.com/analytics';
  static const String apiKey = 'CEDmateHAWahmad1#';

  // -------------------------------------------------------------
  // CLOUD ANALYTICS
  // -------------------------------------------------------------
  Future<void> _runAnalytics() async {
    final userId = _currentUserId ?? 'DemoUser';

    setState(() {
      _isRunning = true;
      _status = '⏳ Analysen werden in der Cloud erstellt...';
      _imageUrls.clear();
    });

    try {
      final uri = Uri.parse('$apiUrl?user=$userId');
      final res = await http.get(uri, headers: {'x-api-key': apiKey});

      if (res.statusCode != 200) {
        setState(() {
          _status =
              '⚠️ Fehler (${res.statusCode}): ${res.reasonPhrase}\n${res.body}';
        });
        return;
      }

      final data = json.decode(res.body);
      final results = Map<String, dynamic>.from(data['results'] ?? {});

      _imageUrls = results.values
          .where((e) => e != null && e.toString().isNotEmpty)
          .map((e) {
            final url = e.toString();
            return url.startsWith('http')
                ? url
                : '${apiUrl.replaceAll('/analytics', '')}/$url';
          })
          .toList();

      setState(() {
        _status = '✅ Analyse abgeschlossen.';
      });
    } catch (e) {
      setState(() {
        _status = '⚠️ Netzwerkfehler: $e';
      });
    } finally {
      setState(() => _isRunning = false);
    }
  }

  // -------------------------------------------------------------
  // EINHEITLICHE BILDANZEIGE (Web + Mobile)
  // -------------------------------------------------------------
  Widget _buildImages() {
    if (_imageUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: Text(
            _isRunning
                ? "Analysiere Daten..."
                : "Noch keine Diagramme vorhanden.",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        final url = _imageUrls[index];
        final aktuelleZeit = DateTime.now()
            .toIso8601String()
            .replaceAll(':', '-')
            .replaceAll('.', '-');
        final fileName = '${aktuelleZeit}_${p.basename(url)}';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Image.network(url, height: 300, fit: BoxFit.contain),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await DateiHandler().dateiOeffnen(
                      url: url,
                      dateiname: fileName,
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Bild speichern'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CEDLayout(
      title: "Statistiken",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _isRunning ? null : _runAnalytics,
            icon: const Icon(Icons.cloud_outlined),
            label: const Text('Statistiken generieren'),
          ),
          const SizedBox(height: 12),
          if (_status.isNotEmpty)
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _status.contains('⚠️')
                    ? Colors.red
                    : CEDColors.textPrimary,
              ),
            ),
          const SizedBox(height: 20),
          _buildImages(),
        ],
      ),
    );
  }
}
