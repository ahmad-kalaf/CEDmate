# CEDmate Analytics API – Kompakte Entwicklerdokumentation

## 1) Zweck des Projekts
Diese API ist das Analytics-Backend der **CEDmate-App** und läuft in Produktion auf **Render**.
Sie erfüllt zwei Kernaufgaben:
1. **Statistiken erzeugen**: Rohdaten aus Firestore werden in Diagramme (PNG) umgewandelt.
2. **Datenexport als PDF**: Diagramme und Rohdaten werden als PDF zusammengeführt.

Die API liefert dabei öffentliche URLs auf generierte Dateien im `/output`-Verzeichnis.

## 2) Tech-Stack
- **FastAPI** und **Uvicorn** (HTTP-API)
- **Firebase Admin SDK** (Firestore-Zugriff)
- **pandas** (Datenaufbereitung)
- **matplotlib** (Diagramme und PDF-Erzeugung)
- Deployment: **Render** (`render.yaml`)

## 3) Projektstruktur (wichtigste Dateien)
- `api.py`  
  FastAPI-App mit Endpunkten `/analytics` und `/export`, CORS- und Sicherheitsprüfungen.
- `cedmate_analytics.py`  
  Firestore-Zugriff, Daten-Fetching und Diagramm-Generierung pro User.
- `export_pdf.py`  
  Erstellt den PDF-Export (Titelblatt, Diagrammseiten, Rohdatenseiten).
- `render.yaml`  
  Render-Service-Konfiguration (Build/Start).
- `requirements.txt`  
  Python-Abhängigkeiten.
- `output/`  
  Laufzeit-Artefakte (PNG/PDF), über `/output/...` öffentlich abrufbar.

## 4) Datenfluss (End-to-End)
1. Client (CEDmate-App/Web) ruft API mit `user=<firebase_uid>` auf.
2. API prüft Sicherheitsregeln (`x-api-key`, `origin`, `user-agent`).
3. Für den User werden Firestore-Subcollections geladen (`users/<uid>/<subcollection>`).
4. Statistiken werden als Diagramme in `output/` gespeichert.
5. Antwort enthält öffentliche Render-URLs auf die erzeugten Dateien.
6. Beim Export wird zusätzlich eine PDF-Datei in `output/` erzeugt und als URL zurückgegeben.

## 5) Endpunkte
### `GET /`
Healthcheck.

### `GET /analytics?user=<uid>`
Erzeugt Diagramme für:
- `stuhlgaenge`
- `stimmungen`
- `symptoms`
- `mahlzeiten`

Response enthält URL-Felder für die generierten PNGs (oder `null`, wenn keine Daten oder kein Plot möglich).

### `GET /export?user=<uid>`
Erzeugt PDF mit:
- Titelblatt
- vorhandenen Diagrammen
- Rohdatentabellen der Collections (gekürzt auf erste 30 Zeilen pro Collection)

Response enthält `pdf`-URL.

## 6) Sicherheit und Zugriff
Die Endpunkte `/analytics` und `/export` erlauben Requests nur bei erfüllten Regeln:
- gültiger Header `x-api-key`
- Web-Aufrufe nur aus erlaubten Origins (`ALLOWED_ORIGINS`)
- Native Aufrufe via vertrauenswürdiger User-Agents (`TRUSTED_USER_AGENTS`)

Wichtige ENV-Variablen:
- `API_KEY` (Auth-Header-Prüfung)
- `SERVICE_ACCOUNT_PATH` (Pfad zur Firebase `serviceAccount.json`)

## 7) Firestore-Annahmen
Die Logik erwartet Daten unter:
- `users/<uid>/stuhlgaenge`
- `users/<uid>/stimmungen`
- `users/<uid>/symptoms`
- `users/<uid>/mahlzeiten`

Zeit- und Werte-Spalten werden heuristisch erkannt (z. B. `zeit`, `date`, `timestamp`, `wert`, `score`, `level`).
Wenn keine passende Zeit- oder Wertespalte gefunden wird, wird für die Collection kein Plot erzeugt.

## 8) Lokal starten (Onboarding)
1. Python-Umgebung erstellen und Abhängigkeiten installieren:
   - `pip install -r requirements.txt`
2. Firebase Service Account bereitstellen:
   - Standard: `./serviceAccount.json` im Projektordner
   - oder per ENV: `SERVICE_ACCOUNT_PATH=/pfad/zur/serviceAccount.json`
3. Optional API-Key setzen:
   - Linux/macOS: `export API_KEY="<dein_key>"`
   - Windows PowerShell: `$env:API_KEY="<dein_key>"`
4. API starten:
   - `uvicorn api:app --host 0.0.0.0 --port 10000`
5. Testaufruf:
   - `GET http://localhost:10000/analytics?user=<uid>` mit Header `x-api-key`

## 9) Deployment auf Render
Konfiguriert in `render.yaml`:
- Build: `pip install -r requirements.txt`
- Start: `uvicorn api:app --host 0.0.0.0 --port 10000`

Für Produktion müssen auf Render mindestens gesetzt sein:
- `API_KEY`
- Zugriff auf Firebase-Service-Account (als Secret File und passender Pfad)

## 10) Hinweise für neue Entwickler
- `output/` enthält generierte Artefakte und wächst mit der Nutzung.
- Diagramm- und Exportlogik ist funktional getrennt (`cedmate_analytics.py` vs. `export_pdf.py`).
- `export_pdf.py` ruft intern erneut Analytics/Firebase-Daten ab; bei Performancebedarf kann man das künftig bündeln.
- Für neue Statistiktypen: Collection-Fetch und Plot-Funktion ergänzen und in `generate_analytics_for_user` registrieren.
