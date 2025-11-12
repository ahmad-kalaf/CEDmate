import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class Statistiken extends StatefulWidget {
  const Statistiken({super.key});

  @override
  State<Statistiken> createState() => _StatistikenState();
}

class _StatistikenState extends State<Statistiken> {
  bool _isRunning = false;
  String _status = '';
  List<File> _generatedImages = [];

  /// aktueller Firebase-Benutzer (UID)
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Render-API Konfiguration (🧩 Testversion)
  static const String apiUrl =
      'https://cedmate-analytics-api.onrender.com/analytics';
  static const String apiKey = 'CEDmateHAWahmad1#';

  /// Führt die Analyse in der Cloud (Render) aus
  Future<void> _runAnalytics() async {
    final userId = _currentUserId ?? 'DemoUser';

    setState(() {
      _isRunning = true;
      _status = '⏳ Analysen werden in der Cloud erstellt...';
      _generatedImages.clear();
    });

    try {
      final uri = Uri.parse('$apiUrl?user=$userId');
      final res = await http.get(uri, headers: {'x-api-key': apiKey});

      if (res.statusCode != 200) {
        setState(
          () => _status =
              '⚠️ Fehler (${res.statusCode}): ${res.reasonPhrase}\n${res.body}',
        );
        return;
      }

      final data = json.decode(res.body);
      print('API Antwort: ${res.body}');
      setState(() => _status = '✅ Analyse abgeschlossen.');

      final results = Map<String, dynamic>.from(data['results'] ?? {});
      final imgs = await _downloadImages(results);
      setState(() => _generatedImages = imgs);
    } catch (e) {
      setState(() => _status = '⚠️ Netzwerkfehler oder kein Internet: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  /// Lädt Diagramme (PNGs) von Render herunter
  /// Lädt Diagramme (PNGs) von Render herunter
  Future<List<File>> _downloadImages(Map<String, dynamic> results) async {
    final dir = await getTemporaryDirectory();
    List<File> files = [];

    for (final entry in results.entries) {
      final url = entry.value?.toString() ?? '';
      if (url.isEmpty) continue;

      // Wenn bereits vollständige URL, direkt verwenden
      final imgUrl = url.startsWith('http')
          ? url
          : '${apiUrl.replaceAll('/analytics', '')}/$url';

      final fileName = p.basename(imgUrl);
      final file = File('${dir.path}/$fileName');

      print('📥 Lade $imgUrl');

      final res = await http.get(Uri.parse(imgUrl));
      if (res.statusCode == 200) {
        await file.writeAsBytes(res.bodyBytes);
        files.add(file);
      } else {
        print('⚠️ Fehler beim Laden von $imgUrl: ${res.statusCode}');
      }
    }

    print('✅ ${files.length} Diagramme erfolgreich geladen');
    return files;
  }

  /// Speichert ein Diagramm lokal
  Future<void> _saveImage(File file) async {
    final savePath = p.join(Directory.current.path, p.basename(file.path));
    try {
      await file.copy(savePath);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gespeichert unter:\n$savePath')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiken')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  color: _status.contains('❌') || _status.contains('⚠️')
                      ? Colors.red
                      : Colors.grey[800],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _generatedImages.isEmpty
                  ? Center(
                      child: Text(
                        _isRunning
                            ? 'Analysiere Daten... (kann 1-2 Minuten dauern)'
                            : 'Noch keine Diagramme vorhanden.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _generatedImages.length,
                      itemBuilder: (context, index) {
                        final file = _generatedImages[index];
                        final fileName = p.basename(file.path);
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.contain,
                                    height: 300,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _saveImage(file),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Bild speichern'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
