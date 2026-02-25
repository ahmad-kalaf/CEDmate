# CEDmate + cedmate_analytics_api

Kompakte Entwicklerdokumentation fuer das Gesamtprojekt (App + Analytics-Backend).

## 1. Ziel dieser Doku

Diese Datei ist fuer neue Entwickler gedacht, die beide Projekte schnell verstehen und lokal starten
wollen:

- `CEDmate` (Flutter-App)
- `cedmate_analytics_api` (Python/FastAPI fuer Statistiken + PDF-Export)

## 2. Zielstruktur im spaeteren ZIP-Paket

```text
CEDmate/                          <- Hauptordner (Gesamtpaket)
  dokumentation.md                <- diese Datei
  CEDmate/                        <- Flutter-Projekt
    lib/
    LICENSE
    pubspec.yaml
    README.md
    ...
  cedmate_analytics_api/          <- Python-API-Projekt
    api.py
    cedmate_analytics.py
    export_pdf.py
    requirements.txt
    render.yaml
    analytics-dokumentation.md
    ...
```

## 3. CEDmate: Ordnerstruktur (App)

Dieses Bild zeigt die Ordnerstruktur des Projekts CEDmate
![CEDmate Ordnerstruktur](cedmate_ordnerstruktur.png)

## 4. Gesamtarchitektur in Kurzform

- Frontend: Flutter-App mit Layer-Aufbau `models -> repositories -> services -> widgets`.
- Datenhaltung: Firebase Auth + Cloud Firestore.
- Externe Dienste:
    - Analytics/PDF-Export via `cedmate_analytics_api` (Render-hosted).
    - Toilettenkarte via Overpass API + OpenStreetMap Tiles.
- UI-State: `provider` (MultiProvider, ProxyProvider, StreamProvider).

---

## 5. CEDmate (Flutter-App)

## 5.1 Tech-Stack

- Flutter/Dart (SDK-Version: `^3.9.2`)
- Firebase Core/Auth/Firestore
- Provider
- Karten/Geodaten: `flutter_map`, `geolocator`, `connectivity_plus`
- Export/Dateien: `http`, `dio`, `open_file`, `url_launcher`
- Kalender: `table_calendar`

## 5.2 Start- und Login-Flow

1. `main.dart` initialisiert Firebase (`DefaultFirebaseOptions.currentPlatform`).
2. `AuthGate` entscheidet per Streams:
    - nicht eingeloggt -> `AuthForm`
    - eingeloggt, aber E-Mail nicht verifiziert -> `VerifiziereEmailScreen`
    - eingeloggt + verifiziert -> `HomeScreen`
3. Registrierung/Login laufen ueber Benutzername + Firebase:
    - Mapping in Firestore-Collection `usernames/{username}`
    - Userprofil in `users/{uid}`

## 5.3 Layer-Verantwortung

- `models/`: Fachobjekte (Symptom, Stuhlgang, Mahlzeit, Stimmung, Anamnese, Wissen)
- `repositories/`: Firestore-Zugriff (CRUD, Query, Streams)
- `services/`: Validierung und Business-Regeln, Zugriff auf aktuelle `uid`
- `widgets/`: Screens, Formulare, Layout, Komponenten

## 5.4 Kernmodule (Fachlich)

- **Anamnese**: medizinisches Profil (Geburtsdatum, Geschlecht, Diagnose, Listenfelder)
- **SymptomRadar**: Intensitaet 1-10, Startzeit, Dauer, Notizen
- **Stuhl-Tagebuch**: Bristol-Typ, Haeufigkeit, Schmerzlevel, Notizen
- **Ess-Tagebuch**: Mahlzeit, Zutaten, Unvertraeglichkeiten, Notizen
- **Seelen-Log**: Stimmung 1-5, Stress 1-10, Notizen, Tags
- **Kalender**: Tagesansicht / Monatsüberblick mit Event-Markern und Filter je Modul
- **Rueckblick**: Monatslisten je Modul mit Monat/Jahr-Filter
- **Statistiken**: Diagramm-Generierung ueber Analytics-API
- **Datenexport**: PDF-Export ueber Analytics-API
- **Hilfe fuer unterwegs**: Toilettenkarte (Overpass + OSM + Offline-Cache)
- **CED Wissen**: Artikel/Video/Checklisten aus Firestore-Collection `wissen`
- **MediManager**: aktuell Prototyp mit Dummy-Daten (keine Persistenz)

## 5.5 Firestore-Datenmodell

Top-Level:

- `usernames/{username}` -> `{ uid, email }`
- `users/{uid}` -> `{ email, username, displayName }`
- `wissen/{docId}` -> Wissensbeitraege (global)

User-Subcollections:

- `users/{uid}/anamnesen/anamnese`
    - `geburtsdatum`, `gender`, `diagnose`, `symptomeImSchub[]`, `schubausloeser[]`,
      `weitereErkrankungen[]`
- `users/{uid}/symptoms/{id}`
    - `bezeichnung`, `intensitaet`, `startZeit`, `dauerInMinuten`, optional `notizen`
- `users/{uid}/stuhlgaenge/{id}`
    - `konsistenz`, `haeufigkeit`, `schmerzLevel`, `eintragZeitpunkt`, optional `notizen`,
      `auffaelligkeiten`
- `users/{uid}/mahlzeiten/{id}`
    - `bezeichnung`, `mahlzeitZeitpunkt`, optional `zutaten[]`, `unvertraeglichkeiten[]`, `notizen`
- `users/{uid}/stimmungen/{id}`
    - `stimmungsLevel`, `stresslevel`, `stimmungsZeitpunkt`, optional `tagebuch`, `tags[]`

## 5.6 Wichtige App-Routen (`main.dart`)

- `/` AuthGate
- `/home`, `/profil`, `/rueckblick`
- `/kalender`, `/statistiken`, `/export`
- `/hilfeUnterwegs`, `/wissen`, `/credits`
- Monatsscreens: `/symptomeMonat`, `/stuhlMonat`, `/essenMonat`, `/stimmungMonat`

## 5.7 Externe Schnittstellen in der App

- Analytics:
    - `GET https://cedmate-analytics-api.onrender.com/analytics?user=<uid>`
    - `GET https://cedmate-analytics-api.onrender.com/export?user=<uid>`
    - Header: `x-api-key`
    - Implementiert in:
        - `lib/widgets/screens/statistiken.dart`
        - `lib/widgets/screens/daten_exportieren.dart`
- Toilettendaten:
    - `POST https://overpass-api.de/api/interpreter`
    - OSM Tile Layer: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
    - Lokaler Cache per `SharedPreferences`

---

## 6. cedmate_analytics_api (FastAPI-Service)

Hinweis: Die ausführliche Dokumentation des Analytic-Backends ist unter
`cedmate_analytics_api/analytics-dokumentation.md` zu finden.

## 6.0 Tech-Stack

- FastAPI + Uvicorn
- Firebase Admin SDK (Firestore-Zugriff)
- pandas (Datenaufbereitung)
- matplotlib (Plots + PDF-Inhalte)
- Deployment: Render (`render.yaml`)

## 6.1 Zweck

- **Statistiken generieren** (Diagramm-PNGs pro User)
- **Datenexport als PDF** (Diagramme + Rohdaten)
- Hosting in Produktion auf **Render**

## 6.2 Erwartete Kern-Dateien

- `api.py` -> FastAPI-App, Endpunkte, Security-Pruefung
- `cedmate_analytics.py` -> Firestore-Datenzugriff + Plot-Logik
- `export_pdf.py` -> PDF-Erstellung
- `requirements.txt` -> Python-Dependencies
- `render.yaml` -> Render Deployment
- `output/` -> generierte PNG/PDF-Artefakte

## 6.3 Endpunkte

- `GET /` -> Healthcheck
- `GET /analytics?user=<uid>` -> erzeugt PNG-Statistiken, Response mit URL-Feldern (typisch unter
  `results`)
- `GET /export?user=<uid>` -> erzeugt PDF, Response enthaelt `pdf`-URL

## 6.4 Sicherheitskonzept

- Header `x-api-key` erforderlich
- Origin-/User-Agent-Pruefungen fuer erlaubte Clients
- Relevante ENV-Variablen:
    - `API_KEY`
    - `SERVICE_ACCOUNT_PATH` (Firebase Service Account)

## 6.5 Firestore-Annahmen der API

Die API liest dieselben Subcollections wie die App:

- `users/<uid>/stuhlgaenge`
- `users/<uid>/stimmungen`
- `users/<uid>/symptoms`
- `users/<uid>/mahlzeiten`

---

## 7. Integration App <-> Analytics API

## 7.1 Aufrufpunkte in CEDmate

- Statistiken-Screen:
    - Request an `/analytics`
    - Liest `results` und zeigt Bild-URLs in der App
- Datenexport-Screen:
    - Request an `/export`
    - Liest `pdf`-URL und oeffnet/speichert Datei

## 7.2 Dateiverarbeitung

- Zentral ueber `DateiHandler`:
    - Web: URL in neuem Browser-Tab
    - Mobile/Desktop: Download in App-Dokumentenordner + `open_file`

## 7.3 Wichtige Betriebsdetails

- API-Key ist aktuell in der App hartkodiert (`statistiken.dart`, `daten_exportieren.dart`).
- Bei lokaler API-Nutzung muessen `apiUrl` + `apiKey` im App-Code angepasst werden.

## 7.4 End-to-End Datenfluss (vereinfacht)

1. User erzeugt Eintraege in CEDmate (Firestore).
2. App ruft Analytics-API mit `user=<uid>` + `x-api-key` auf.
3. API liest Firestore-Subcollections und erzeugt Diagramme/PDF.
4. API liefert Dateilinks zurueck.
5. App zeigt Bilder an oder oeffnet PDF ueber `DateiHandler`.

---

## 8 Kurz-Smoke-Tests

- Demo-App unter https://ahmad-kalaf.github.io/CEDmate/ aufrufen
- Registrieren -> E-Mail verifizieren -> Login -> Home
- ODER Mit Demo-Zugangsdaten anmelden: Benutzername: ahmadkalaf Passwort: Passwort12345#
- Je Modul einen Testeintrag anlegen
- Weitere Funktionen testen ...

---

## 9. Datei-Landkarte fuer Aenderungen

- Authentifizierung:
    - `lib/repositories/auth_repository.dart`
    - `lib/services/auth_service.dart`
    - `lib/widgets/forms/auth_form.dart`
- Firestore-Logik je Modul:
    - `lib/repositories/*_repository.dart`
    - `lib/services/*_service.dart`
- UI je Modul:
    - Eingabe: `lib/widgets/forms/`
    - Tagesansicht: `lib/widgets/sections/*_fuer_datum.dart`
    - Monatsansicht: `lib/widgets/sections/*_fuer_monat.dart`
- Analytics-Integration in der App:
    - `lib/widgets/screens/statistiken.dart`
    - `lib/widgets/screens/daten_exportieren.dart`
    - `lib/widgets/utils/datei_handler.dart`
- Kartenfunktion:
    - `lib/widgets/screens/hilfe_fuer_unterwegs.dart`
- App-Setup/Provider/Routing:
    - `lib/main.dart`

---
