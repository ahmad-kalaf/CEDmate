import 'dart:convert';
import 'dart:io';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:cedmate/widgets/c_e_d_colors.dart';
import 'package:cedmate/models/app_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:cedmate/utils/open_file.dart';

class DatenExportieren extends StatefulWidget {
  const DatenExportieren({super.key});

  @override
  State<DatenExportieren> createState() => _DatenExportierenState();
}

class _DatenExportierenState extends State<DatenExportieren> {
  bool _isLoading = false;
  String _status = "";

  // Deine API-Konfiguration
  static const String apiUrl =
      'https://cedmate-analytics-api.onrender.com/export';
  static const String apiKey = 'CEDmateHAWahmad1#';

  // -------------------------------------------------------------
  //  PDF EXPORT STARTEN
  // -------------------------------------------------------------
  Future<void> _exportPdf(AppUser user) async {
    setState(() {
      _isLoading = true;
      _status = "⏳ PDF wird erstellt...";
    });

    try {
      final uri = Uri.parse("$apiUrl?user=${user.uid}");

      final response = await http.get(uri, headers: {"x-api-key": apiKey});

      if (response.statusCode != 200) {
        setState(() {
          _status =
              "⚠️ Fehler (${response.statusCode}): ${response.reasonPhrase}\n${response.body}";
        });
        return;
      }

      final data = json.decode(response.body);
      final pdfUrl = data["pdf"];

      if (pdfUrl == null) {
        setState(() {
          _status = "⚠️ Server hat kein PDF erzeugt.";
        });
        return;
      }

      // ---------------------------------------------------------
      //  WEB → PDF im neuen Tab öffnen
      // ---------------------------------------------------------
      if (kIsWeb) {
        openPdf(pdfUrl);
        setState(() => _status = "📄 PDF geöffnet.");
        return;
      }

      // ---------------------------------------------------------
      //  MOBILE / DESKTOP → PDF herunterladen
      // ---------------------------------------------------------
      final saved = await _downloadPdf(pdfUrl);
      setState(() {
        _status = "📄 PDF gespeichert unter:\n${saved.path}";
      });
    } catch (e) {
      setState(() {
        _status = "⚠️ Export-Fehler: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // -------------------------------------------------------------
  //  PDF HERUNTERLADEN (Mobile + Desktop)
  // -------------------------------------------------------------
  Future<File> _downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));

    final dir = await getTemporaryDirectory();
    final fileName = p.basename(url);
    final file = File("${dir.path}/$fileName");

    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  // -------------------------------------------------------------
  //  UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppUser?>();

    return CEDLayout(
      title: 'Daten exportieren',
      child: Center(
        child: user == null
            ? const Text("Kein Benutzer angemeldet.")
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Daten für ${user.username} als PDF exportieren",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: CEDColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _exportPdf(user),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("PDF jetzt erstellen"),
                    ),

                    const SizedBox(height: 20),

                    if (_status.isNotEmpty)
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _status.contains("⚠️")
                              ? Colors.red
                              : CEDColors.textPrimary,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
