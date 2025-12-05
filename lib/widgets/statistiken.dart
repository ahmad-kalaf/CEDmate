import 'dart:convert';
import 'dart:io';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:cedmate/widgets/c_e_d_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Statistiken extends StatefulWidget {
  const Statistiken({super.key});

  @override
  State<Statistiken> createState() => _StatistikenState();
}

class _StatistikenState extends State<Statistiken> {
  bool _isRunning = false;
  String _status = '';

  List<File> _generatedImages = []; // Mobile/Desktop
  List<String> _generatedImageUrls = []; // Web

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
      _generatedImages.clear();
      _generatedImageUrls.clear();
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
      final results = Map<String, dynamic>.from(data['results'] ?? {});

      setState(() => _status = '✅ Analyse abgeschlossen.');

      if (kIsWeb) {
        _generatedImageUrls = results.values
            .where((e) => e != null && e.toString().isNotEmpty)
            .map((e) => e.toString())
            .toList();
        setState(() {});
        return;
      }

      final imgs = await _downloadImages(results);
      setState(() => _generatedImages = imgs);
    } catch (e) {
      setState(() => _status = '⚠️ Netzwerkfehler: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  // -------------------------------------------------------------
  // BILDER LADEN (Mobile/Desktop)
  // -------------------------------------------------------------
  Future<List<File>> _downloadImages(Map<String, dynamic> results) async {
    final dir = await getTemporaryDirectory();
    List<File> files = [];

    for (final entry in results.entries) {
      final url = entry.value?.toString() ?? '';
      if (url.isEmpty) continue;

      final imgUrl = url.startsWith('http')
          ? url
          : '${apiUrl.replaceAll('/analytics', '')}/$url';

      final fileName = p.basename(imgUrl);
      final file = File('${dir.path}/$fileName');

      final response = await http.get(Uri.parse(imgUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        files.add(file);
      }
    }
    return files;
  }

  // -------------------------------------------------------------
  // BILD SPEICHERN (Desktop/Mobile)
  // -------------------------------------------------------------
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

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CEDLayout(title: "Statistiken", child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    return Column(
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

        if (kIsWeb) _buildWebImages(),
        if (!kIsWeb) _buildMobileImages(),
      ],
    );
  }

  // -------------------------------------------------------------
  // WEB-BILDER
  // -------------------------------------------------------------
  Widget _buildWebImages() {
    if (_generatedImageUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: Text(
            _isRunning
                ? "Analysiere Daten... das kann 1–2 Minuten dauern."
                : "Noch keine Diagramme vorhanden.",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _generatedImageUrls.length,
      itemBuilder: (context, index) {
        final url = _generatedImageUrls[index];
        final fileName = p.basename(url);

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
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // MOBILE/DESKTOP-BILDER
  // -------------------------------------------------------------
  Widget _buildMobileImages() {
    if (_generatedImages.isEmpty) {
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
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Image.file(file, height: 300, fit: BoxFit.contain),
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
    );
  }
}
