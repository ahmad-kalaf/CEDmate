# CEDmate

CEDmate ist eine Flutter-Anwendung zur Dokumentation des Alltags mit chronisch-entzündlichen Darmerkrankungen (CED), beispielsweise Morbus Crohn oder Colitis ulcerosa. Symptome, Stuhlgang, Ernährung und Wohlbefinden werden häufig getrennt oder nur unregelmäßig festgehalten. CEDmate bündelt diese Informationen in einem digitalen Tagebuch, damit Einträge leichter wiedergefunden und Veränderungen über die Zeit nachvollzogen werden können.

Die Anwendung richtet sich an Betroffene, die ihre Beobachtungen strukturiert festhalten möchten. Sie stellt keine Diagnosen und ersetzt keine ärztliche Beratung.

## Funktionen

- **SymptomRadar:** Symptome mit Bezeichnung, Intensität, Zeitpunkt, Dauer und optionalen Notizen dokumentieren.
- **Stuhl-Tagebuch:** Stuhlkonsistenz anhand der Bristol-Skala, Häufigkeit, Schmerzen und Auffälligkeiten erfassen.
- **Ess-Tagebuch:** Mahlzeiten, Zutaten, mögliche Unverträglichkeiten und Notizen speichern.
- **Seelen-Log:** Stimmung, Stresslevel und ergänzende Tagebucheinträge festhalten.
- **Anamnese:** Persönliche Angaben zur Erkrankung und zum Krankheitsverlauf hinterlegen.
- **Kalender und Rückblick:** Tagebucheinträge nach Datum und Monat aufrufen.
- **Statistiken und PDF-Export:** Erfasste Daten über eine separate Analytics-API auswerten und als PDF zusammenstellen.
- **Hilfe für unterwegs:** Öffentliche Toiletten in der Umgebung auf einer OpenStreetMap-Karte suchen; zuletzt geladene Toilettendaten werden lokal zwischengespeichert.
- **CED-Wissen:** In Firestore hinterlegte Informationsbeiträge lesen.

Der **MediManager** ist bislang ein UI-Prototyp mit Beispieldaten. Medikamente werden dort noch nicht dauerhaft gespeichert.

## Anwendung ausprobieren

### Im Browser

Für die Webversion ist ein GitHub-Pages-Deployment unter folgender Adresse vorgesehen:

**[CEDmate öffnen](https://ahmad-kalaf.github.io/CEDmate/)**

Der Workflow für das Deployment liegt unter [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) und wird durch Pushes auf den Branch `deploy` ausgelöst. Ob die bereitgestellte Version aktuell erreichbar ist, hängt vom GitHub-Pages-Deployment ab.

So lässt sich der grundlegende Ablauf testen:

1. Konto mit E-Mail-Adresse und Passwort registrieren.
2. Die E-Mail-Adresse über den zugesandten Link bestätigen.
3. Anmelden und die Anamnese ausfüllen.
4. Testeinträge für Symptome, Stuhlgang, Mahlzeiten und Stimmung anlegen.
5. Einträge im Kalender und Rückblick aufrufen.
6. Optional die Toilettenkarte sowie Statistiken und PDF-Export ausprobieren.

Für Tests sollten ausschließlich fiktive Gesundheitsdaten verwendet werden. Die Statistikansicht nutzt derzeit eine feste Demo-Benutzerkennung; weitere Hinweise stehen unter [Bekannte Einschränkungen](#bekannte-einschränkungen).

### Lokal starten

**Voraussetzungen**

- Flutter SDK mit Dart 3.9.2 oder neuer innerhalb des unterstützten SDK-Bereichs (`pubspec.yaml`). Der Deployment-Workflow verwendet Flutter 3.35.7.
- Ein eingerichtetes Flutter-Zielgerät, beispielsweise Chrome oder ein Android-Emulator.
- Firebase Authentication und Cloud Firestore in einem zugänglichen Firebase-Projekt.

```bash
git clone https://github.com/ahmad-kalaf/CEDmate.git
cd CEDmate
flutter pub get
flutter run -d chrome
```

Für ein anderes verfügbares Zielgerät können zunächst `flutter devices` und anschließend `flutter run -d <device-id>` ausgeführt werden.

**Firebase-Konfiguration:** Die Datei [`lib/firebase_options.dart`](lib/firebase_options.dart) enthält bereits die Firebase-Clientkonfiguration des Projekts. Für eine unabhängige lokale Entwicklungsumgebung empfiehlt sich jedoch ein eigenes Firebase-Testprojekt. Dazu in Firebase die E-Mail-/Passwort-Authentifizierung und Cloud Firestore aktivieren, die App mit FlutterFire konfigurieren und die benötigten Zugriffsregeln aus [`firestore.rules`](firestore.rules) für das eigene Projekt einrichten. Ohne funktionierende Firebase-Dienste lassen sich Registrierung und Datenverwaltung nicht vollständig testen.

Statistiken und PDF-Export setzen zusätzlich die separat betriebene [CEDmate Analytics API](https://github.com/ahmad-kalaf/cedmate_analytics_api) voraus. Die derzeitigen Endpunkt-URLs sind in der App fest eingetragen; für eine eigene Backend-Instanz müssen sie angepasst werden.

## Architektur

Die App trennt Darstellung, Anwendungslogik und Datenzugriff:

```text
Flutter-Oberfläche (widgets/)
        |
        v
Services (services/)
        |
        v
Repositories (repositories/)
        |
        v
Firebase Authentication / Cloud Firestore

Statistiken und Export:
Flutter-App --> HTTP --> Analytics API --> Cloud Firestore
                                   |
                                   +--> PNG-Diagramme / PDF
```

- **Widgets:** Screens, Eingabeformulare und wiederverwendbare UI-Komponenten.
- **Services:** Anwendungslogik, Validierung und Zugriff auf die aktuelle Benutzerkennung.
- **Repositories:** Persistenz und Abfragen für die jeweiligen Firestore-Datenbereiche.
- **Models:** Dart-Datenmodelle und Enums für Symptome, Stuhlgang, Mahlzeiten, Stimmung und Anamnese.
- **Provider:** Bereitstellung der Services, Repositories und des Benutzerzustands über `MultiProvider`, `ProxyProvider` und `StreamProvider`.

Beim Start initialisiert [`lib/main.dart`](lib/main.dart) Firebase und registriert die Abhängigkeiten. Das [`AuthGate`](lib/widgets/auth_gate.dart) unterscheidet zwischen nicht angemeldeten, noch nicht verifizierten und verifizierten Benutzern. Die eigentlichen Tagebucheinträge werden von der App direkt in Firestore gespeichert; nur Auswertung und PDF-Erzeugung sind an die Python-API ausgelagert.

### Datenhaltung

Benutzerbezogene Dokumente werden in Firestore unter `users/{uid}` abgelegt. Die wichtigsten Subcollections sind:

| Pfad | Inhalt |
| --- | --- |
| `users/{uid}/anamnesen/anamnese` | Anamnesedaten |
| `users/{uid}/symptoms` | Symptome |
| `users/{uid}/stuhlgaenge` | Stuhlgang |
| `users/{uid}/mahlzeiten` | Mahlzeiten |
| `users/{uid}/stimmungen` | Stimmung und Stress |
| `wissen` | Informationsbeiträge, unabhängig vom Benutzerprofil |

Die enthaltenen Firestore-Regeln erlauben Benutzern den Zugriff auf ihre eigenen Dokumente unter `users/{uid}`. Wissensbeiträge sind lesbar; Schreibzugriff ist dort für Benutzer mit entsprechendem Admin-Claim vorgesehen. Die separat eingesetzte Analytics-API verwendet das Firebase Admin SDK und unterliegt nicht diesen clientseitigen Firestore-Regeln.

## Tech-Stack

| Bereich | Technologie |
| --- | --- |
| Frontend | Flutter, Dart, Material-Widgets |
| State Management | Provider |
| Anmeldung | Firebase Authentication |
| Datenbank | Cloud Firestore |
| Karten und Standort | flutter_map, OpenStreetMap, Overpass API, Geolocator |
| Lokaler Cache | SharedPreferences (Toiletteninformationen) |
| Statistik und Export | Separate Python-/FastAPI-Anwendung |
| Web-Deployment | GitHub Actions, GitHub Pages |

## Projektstruktur

```text
lib/
  main.dart                 # App-Start, Dependency Injection und Routing
  firebase_options.dart     # Firebase-Clientkonfiguration
  models/                   # Datenmodelle und Enums
  repositories/             # Firestore- und Authentifizierungszugriffe
  services/                 # Anwendungslogik
  widgets/
    screens/                # Anwendungsseiten
    forms/                  # Eingabeformulare
    sections/               # Tages- und Monatsansichten
    components/             # Wiederverwendbare Komponenten
    layout/                 # Gemeinsame Layouts
docs/                        # Weiterführende Projektdokumentation
assets/                      # Icons und Schriftart
firestore.rules             # Firestore-Zugriffsregeln
.github/workflows/deploy.yml # Web-Build und GitHub-Pages-Deployment
```

## Bekannte Einschränkungen

- Die Statistikseite in [`lib/widgets/screens/statistiken.dart`](lib/widgets/screens/statistiken.dart) sendet derzeit die feste Benutzerkennung `DemoUser` an die Analytics-API. Sie verwendet damit nicht automatisch die Daten des angemeldeten Kontos. Der PDF-Export verwendet dagegen dessen tatsächliche Firebase-UID.
- Die Analytics-API wird mit einem im Clientcode hinterlegten API-Schlüssel angesprochen. Dieser ist kein ausreichender Schutz für personenbezogene Gesundheitsdaten. Auch die Backend-Zugriffsprüfung und die öffentlich abrufbaren Exportdateien müssen vor einem Einsatz mit echten Patientendaten abgesichert werden.
- Der MediManager arbeitet mit Beispieldaten und bietet noch keine dauerhafte Medikamentenverwaltung.
- Die Analytics-Funktionen hängen von einem separat betriebenen Backend und dessen Erreichbarkeit ab.
- Im Repository ist kein eigenes automatisiertes Testverzeichnis enthalten.

## Weiterführende Dokumentation

- [Entwicklerdokumentation](docs/cedmate_dokumentation.md)
- [Dokumentation der Analytics-Integration](docs/analytics-dokumentation.md)
- [Repository der CEDmate Analytics API](https://github.com/ahmad-kalaf/cedmate_analytics_api)
