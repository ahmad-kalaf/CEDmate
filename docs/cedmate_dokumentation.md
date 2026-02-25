# CEDmate – Entwicklerdokumentation

## 1. Zweck und Verwendung

Diese Dokumentation dient als kompakter Einstieg für neue Entwickler in das CEDmate-Projekt.

Wichtig für die Weitergabe:
- Das CEDmate-Projekt wird **genau in der aktuellen Form** als ZIP geteilt.
- Es gibt **keine zusätzliche Zielstruktur** oder Umverpackung.
- Die Analytics API wird **separat als eigenes ZIP** geteilt.
- Die zugehörige API-Dokumentation liegt in `docs/analytics-dokumentation.md`.

## 2. Projektüberblick

CEDmate ist eine Flutter-App zur Begleitung von Menschen mit chronisch-entzündlichen Darmerkrankungen (CED).  
Die App kombiniert Erfassung, Verlaufssicht und Exportfunktionen:
- Symptome erfassen
- Stuhlgang dokumentieren
- Mahlzeiten dokumentieren
- Stimmung/Stress dokumentieren
- Kalender und Rückblick
- Statistiken und PDF-Export (über die Analytics API)
- Toilettenkarte für unterwegs
- CED-Wissen

## 3. Ordnerstruktur

![CEDmate Ordnerstruktur](cedmate_ordnerstruktur.png)

## 4. Technischer Aufbau

### 4.1 Schichtenmodell

CEDmate ist in `lib/` klar in Schichten getrennt:
- `models/`  
  Fachmodelle und Enums (z. B. `Symptom`, `Stuhlgang`, `Mahlzeit`, `Stimmung`, `Anamnese`).
- `repositories/`  
  Firestore-Zugriff (CRUD, Streams, Datumsfilter).
- `services/`  
  Business-Logik, Validierung, Auth-Kontext.
- `widgets/`  
  UI-Schicht (Screens, Formulare, Komponenten, Layouts).

### 4.2 App-Start und Auth-Flow

1. `main.dart` initialisiert Firebase.
2. `AuthGate` entscheidet per Stream:
   - nicht eingeloggt -> `AuthForm`
   - eingeloggt, E-Mail noch nicht verifiziert -> `VerifiziereEmailScreen`
   - eingeloggt und verifiziert -> `HomeScreen`
3. Anmeldung erfolgt über Benutzername + Passwort, intern mit Firebase Auth + Firestore-Mapping.

### 4.3 State Management

- `provider` mit `MultiProvider`, `ProxyProvider`, `StreamProvider`
- Services beziehen ihre Repositories über DI
- Nutzerzustand (`AppUser?`) wird global per Stream bereitgestellt

## 5. Kernfunktionen nach Modulen

- **Anamnese**  
  Medizinisches Profil mit Geburtsdatum, Geschlecht, Diagnose und Listenfeldern.
- **SymptomRadar**  
  Erfassung von Bezeichnung, Intensität (1–10), Startzeit, Dauer, Notizen.
- **Stuhl-Tagebuch**  
  Bristol-Typ, Häufigkeit, Schmerzlevel, Notizen/Auffälligkeiten.
- **Ess-Tagebuch**  
  Bezeichnung, Zutaten, Unverträglichkeiten, Notizen.
- **Seelen-Log**  
  Stimmung (1–5), Stresslevel (1–10), Notizen, Tags.
- **Kalender**  
  Tagesbezogene Anzeige mit Event-Markern je Modultyp.
- **Rückblick**  
  Monatslisten mit Monat/Jahr-Filter pro Modul.
- **Statistiken & Datenexport**  
  Serverseitige Auswertung über die Analytics API.
- **Hilfe für unterwegs**  
  Toilettenkarte mit Overpass-API, OSM-Karte und Offline-Cache.
- **CED Wissen**  
  Wissensinhalte aus Firestore (`wissen`).
- **MediManager**  
  Aktuell prototypisch (Dummy-Daten, keine Firestore-Persistenz).

## 6. Datenmodell in Firestore

### 6.1 Top-Level Collections

- `usernames/{username}` -> `{ uid, email }`
- `users/{uid}` -> `{ email, username, displayName }`
- `wissen/{docId}` -> Wissensbeiträge

### 6.2 Nutzerbezogene Subcollections

- `users/{uid}/anamnesen/anamnese`
  - `geburtsdatum`, `gender`, `diagnose`, `symptomeImSchub[]`, `schubausloeser[]`, `weitereErkrankungen[]`
- `users/{uid}/symptoms/{id}`
  - `bezeichnung`, `intensitaet`, `startZeit`, `dauerInMinuten`, optional `notizen`
- `users/{uid}/stuhlgaenge/{id}`
  - `konsistenz`, `haeufigkeit`, `schmerzLevel`, `eintragZeitpunkt`, optional `notizen`, `auffaelligkeiten`
- `users/{uid}/mahlzeiten/{id}`
  - `bezeichnung`, `mahlzeitZeitpunkt`, optional `zutaten[]`, `unvertraeglichkeiten[]`, `notizen`
- `users/{uid}/stimmungen/{id}`
  - `stimmungsLevel`, `stresslevel`, `stimmungsZeitpunkt`, optional `tagebuch`, `tags[]`

## 7. Externe Schnittstellen

### 7.1 Analytics API

Aufruf aus der App:
- `GET https://cedmate-analytics-api.onrender.com/analytics?user=<uid>`
- `GET https://cedmate-analytics-api.onrender.com/export?user=<uid>`
- Header: `x-api-key`

Relevante Dateien in CEDmate:
- `lib/widgets/screens/statistiken.dart`
- `lib/widgets/screens/daten_exportieren.dart`
- `lib/widgets/utils/datei_handler.dart`

### 7.2 Toilettenkarte

- Overpass API: `https://overpass-api.de/api/interpreter`
- OSM Tile Layer: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- Lokaler Cache über `SharedPreferences`

## 8. Lokale Entwicklung

### 8.1 Voraussetzungen

- Flutter SDK (kompatibel zu Dart `^3.9.2`)
- Firebase-Projekt und gültige Konfiguration in `lib/firebase_options.dart`

### 8.2 Start

1. `flutter pub get`
2. `flutter run`

Optional Web:
- `flutter run -d chrome`

## 9. Schnelltest (Smoke Test)

1. Registrierung -> E-Mail verifizieren -> Login
2. Für jedes Kernmodul mindestens einen Eintrag anlegen
3. Kalender und Rückblick prüfen
4. Statistiken ausführen
5. PDF-Export ausführen
6. Toilettenkarte mit Standortfreigabe prüfen

## 10. Wichtige Dateien für Änderungen

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
- App-Setup:
  - `lib/main.dart`

## 11. Bekannte Grenzen

- `MediManager` ist derzeit nur prototypisch.
- API-Key für Analytics ist aktuell im Client-Code hinterlegt.
- Es gibt aktuell kein separates `test/`-Verzeichnis mit automatisierten Tests.

## 12. Weiterführende Dokumente

- Detaillierte App-Beschreibung: `Doku.md`
- Analytics API Doku: `docs/analytics-dokumentation.md`
