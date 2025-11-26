import 'dart:async';
import 'dart:convert';
import 'package:cedmate/widgets/ced_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:cedmate/widgets/CEDColors.dart';  

/// Modell einer Toilette (mit Position und Zusatzinformationen)
class Toilette {
  final LatLng position;
  final Map<String, dynamic> merkmale;

  Toilette(this.position, this.merkmale);
}

class HilfeFuerUnterwegs extends StatefulWidget {
  const HilfeFuerUnterwegs({super.key});

  @override
  State<HilfeFuerUnterwegs> createState() => _HilfeFuerUnterwegsState();
}

class _HilfeFuerUnterwegsState extends State<HilfeFuerUnterwegs> {
  LatLng? _aktuellerStandort;
  List<Toilette> _toilettenListe = [];
  bool _ladevorgang = false;
  double _suchradius = 3000; // Startwert in Metern
  final _kartenController = MapController();
  Timer? _warteTimer;
  Toilette? _ausgewaehlteToilette; // aktuell angeklickte Toilette

  @override
  void initState() {
    super.initState();
    _ladeToilettenDaten();
  }

  // Cache speichern
  Future<void> _cacheSpeichern(List<Toilette> toiletten) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = toiletten
        .map(
          (t) => {
            'lat': t.position.latitude,
            'lon': t.position.longitude,
            'merkmale': t.merkmale,
          },
        )
        .toList();
    prefs.setString('toiletten_cache', jsonEncode(liste));
  }

  // Cache laden
  Future<List<Toilette>> _cacheLaden() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('toiletten_cache');
    if (jsonString == null) return [];
    final List daten = jsonDecode(jsonString);
    return daten
        .map(
          (e) => Toilette(
            LatLng(e['lat'], e['lon']),
            Map<String, dynamic>.from(e['merkmale'] ?? {}),
          ),
        )
        .toList();
  }

  // Berechnet den Suchradius anhand des Zoom-Levels der Karte
  double _berechneSuchradius(double zoom) {
    return 1000 * (20 - zoom).clamp(2, 15);
  }

  // Lädt Toilettendaten über die Overpass-API oder aus dem Cache
  Future<void> _ladeToilettenDaten({LatLng? benutzerPosition}) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Standortberechtigung dauerhaft verweigert. Bitte in den Einstellungen aktivieren.',
            ),
          ),
        );
      }
      return;
    }

    if (permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Standortberechtigung erforderlich.')),
        );
      }
      return;
    }

    if (_ladevorgang) return;
    setState(() => _ladevorgang = true);

    try {
      LatLng zentrum;
      if (benutzerPosition != null) {
        zentrum = benutzerPosition;
      } else {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        zentrum = LatLng(position.latitude, position.longitude);
        setState(() => _aktuellerStandort = zentrum);
      }

      // Internetverbindung prüfen
      final verbindung = await Connectivity().checkConnectivity();
      final hatInternet = !verbindung.contains(ConnectivityResult.none);

      if (hatInternet) {
        // Online – Daten von Overpass holen
        final abfrage =
            '''
          [out:json][timeout:25];
          node["amenity"="toilets"](around:${_suchradius.round()},${zentrum.latitude},${zentrum.longitude});
          out body;
        ''';

        final url = Uri.parse('https://overpass-api.de/api/interpreter');
        final antwort = await http.post(url, body: {'data': abfrage});

        if (antwort.statusCode == 200) {
          final daten = jsonDecode(antwort.body);
          final List elemente = daten['elements'];

          final toiletten = elemente
              .where((e) => e['lat'] != null && e['lon'] != null)
              .map(
                (e) => Toilette(
                  LatLng(e['lat'], e['lon']),
                  Map<String, dynamic>.from(e['tags'] ?? {}),
                ),
              )
              .toList();

          setState(() => _toilettenListe = toiletten);
          await _cacheSpeichern(toiletten);
        }
      } else {
        // Offline – Cache laden
        final gespeicherte = await _cacheLaden();
        if (gespeicherte.isNotEmpty) {
          setState(() => _toilettenListe = gespeicherte);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Offline: Zeige gespeicherte Daten'),
              ),
            );
          }
        }
      }
    } catch (fehler) {
      debugPrint('Fehler: $fehler');
    } finally {
      setState(() => _ladevorgang = false);
    }
  }

  // Gibt einen deutschen Text für verschiedene OSM-Tag-Werte zurück
  String _textStatus(String? wert) {
    if (wert == null || wert.isEmpty) return "unbekannt";

    final normalized = wert.toLowerCase().trim();

    switch (normalized) {
      case "yes":
        return "ja";
      case "no":
        return "nein";
      case "public":
        return "öffentlich";
      case "private":
        return "privat";
      case "customers":
        return "nur für Kunden";
      case "permissive":
        return "geduldet";
      case "members":
        return "nur für Mitglieder";
      case "unknown":
        return "unbekannt";
    }

    if (normalized == "free") return "kostenlos";
    if (normalized.startsWith("€") ||
        normalized.contains("cent") ||
        RegExp(r'\d').hasMatch(normalized)) {
      return "Kosten: $wert";
    }

    if (normalized == "limited") return "eingeschränkt barrierefrei";

    if (normalized.contains(":") ||
        normalized.contains("mo") ||
        normalized.contains("tu")) {
      return _formatOpeningHours(wert);
    }

    return wert;
  }

  // Formatiert Öffnungszeiten lesbarer
  String _formatOpeningHours(String rohwert) {
    try {
      String cleaned = rohwert
          .replaceAll(";", ", ")
          .replaceAll("-", "–")
          .replaceAll("Mo", "Mo")
          .replaceAll("Tu", "Di")
          .replaceAll("We", "Mi")
          .replaceAll("Th", "Do")
          .replaceAll("Fr", "Fr")
          .replaceAll("Sa", "Sa")
          .replaceAll("Su", "So");

      cleaned = cleaned.replaceAllMapped(
        RegExp(r'(\d{1,2}):00'),
        (m) => m.group(1)!,
      );
      cleaned = cleaned.replaceAll(":", " ");
      return "$cleaned Uhr";
    } catch (_) {
      return rohwert;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ladevorgang && _toilettenListe.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_aktuellerStandort == null) {
      return const Center(
        child: Text(
          'Standort wird bestimmt...',
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
      );
    }

    return Scaffold(
      drawer: const CEDDrawer(),
      appBar: AppBar(title: Text('Toiletten-Karte')),
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _kartenController,
              options: MapOptions(
                initialCenter: _aktuellerStandort!,
                initialZoom: 15,
                onPositionChanged: (position, nutzerBewegtKarte) {
                  if (nutzerBewegtKarte) {
                    _warteTimer?.cancel();
                    _warteTimer = Timer(const Duration(seconds: 1), () async {
                      final neuesZentrum = position.center;
                      final neuerRadius = _berechneSuchradius(position.zoom);
                      setState(() => _suchradius = neuerRadius);
                      await _ladeToilettenDaten(benutzerPosition: neuesZentrum);
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'app.cedmate',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _aktuellerStandort!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: CEDColors.accent,
                      ),
                    ),
                    ..._toilettenListe.map(
                      (t) => Marker(
                        point: t.position,
                        width: 35,
                        height: 35,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _ausgewaehlteToilette = t);
                          },
                          child: Icon(
                            Icons.wc,
                            color: _ausgewaehlteToilette == t
                                ? Colors.red
                                : Colors.brown,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  alignment: AttributionAlignment.bottomRight,
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
            // Popup unter der Karte
            if (_ausgewaehlteToilette != null)
              Positioned(
                left: 10,
                right: 10,
                bottom: 20,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _ausgewaehlteToilette!.merkmale['name'] ??
                                  'Öffentliche Toilette',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _ausgewaehlteToilette = null),
                            ),
                          ],
                        ),
                        Text(
                          "Kostenpflichtig: ${_textStatus(_ausgewaehlteToilette!.merkmale['fee'])}",
                        ),
                        Text(
                          "Barrierefrei: ${_textStatus(_ausgewaehlteToilette!.merkmale['wheelchair'])}",
                        ),
                        if (_ausgewaehlteToilette!.merkmale['access'] != null)
                          Text(
                            "Zugang: ${_textStatus(_ausgewaehlteToilette!.merkmale['access'])}",
                          ),
                        if (_ausgewaehlteToilette!.merkmale['opening_hours'] !=
                            null)
                          Text(
                            "Öffnungszeiten: ${_ausgewaehlteToilette!.merkmale['opening_hours']}",
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            // Button: Zurück zum aktuellen Standort
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: CEDColors.accent,
                shape: const CircleBorder(),
                tooltip: 'Zum aktuellen Standort',
                onPressed: () async {
                  try {
                    final pos = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.best,
                    );
                    final neuerStandort = LatLng(pos.latitude, pos.longitude);

                    setState(() {
                      _aktuellerStandort = neuerStandort;
                      _suchradius = 2000;
                      _ausgewaehlteToilette = null;
                    });

                    _kartenController.move(neuerStandort, 15);
                    await _ladeToilettenDaten(benutzerPosition: neuerStandort);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fehler beim Bestimmen des Standorts: $e',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Icon(Icons.my_location),
              ),
            ),
            // Ladeindikator
            if (_ladevorgang)
              const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CEDColors.accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
