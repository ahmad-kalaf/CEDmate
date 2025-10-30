# 🩺 CEDmate  
**CEDmate** ist eine mobile App zur Unterstützung von Menschen mit **chronisch-entzündlichen Darmerkrankungen (CED)** wie **Morbus Crohn** oder **Colitis ulcerosa**.  
Die App hilft Betroffenen, Symptome, Ernährung, Psyche und Krankheitsverlauf systematisch zu erfassen und zu verstehen – für ein besseres Leben mit CED.

---

## 🚀 Ziel der App  
CEDmate soll Patient*innen ermöglichen:
- Krankheitsverläufe strukturiert zu dokumentieren 🧾  
- Zusammenhänge zwischen Ernährung, Stress und Symptomen zu erkennen 🍽️  
- Ärzt*innen gezielt mit Daten zu unterstützen 👩‍⚕️  
- Alltagsfunktionen wie Toilettenfinder & Restaurantempfehlungen zu nutzen 🚻  
- Selbstreflexion & Wissen rund um CED zu fördern 🧠  

---

## 🔐 Registrierung & Profil  
- Anmeldung über **E-Mail & Passwort** (Firebase Auth)  
- Erstellung eines **Benutzerprofils** mit anonymisiertem Username  
- Basisfragen zur Profilerstellung:
  - Alter  
  - Geschlecht  
  - Ärztliche Diagnose (*Colitis ulcerosa*, *Morbus Crohn*, *sonstige CED-Formen*, *keine*)  
  - Begleiterkrankungen  

👉 Das Profil kann jederzeit unter **„Mein Profil“** angepasst werden.

---

## 📱 Hauptfunktionen  

### 🟠 1. SymptomRadar  
Dokumentiere akute körperliche Beschwerden (außerhalb des Stuhlgangs).  
**Funktionen:**  
- Symptome wie Bauchschmerzen, Fieber, Gelenkschmerzen, Hautveränderungen  
- Intensitätsskala (1–10)  
- Zeit & Dauer  
- Freitext für zusätzliche Notizen  

📌 **Ziel:** Frühwarnung und Mustererkennung bei Schüben.

---

### 🟤 2. StuhlTagebuch  
Erfasse deine Stuhlkonsistenz objektiv.  
**Funktionen:**  
- Konsistenz nach **Bristol-Stuhlskala (mit Bildern)**  
- Häufigkeit (z. B. 3× täglich)  
- Auffälligkeiten wie Blut, Schleim, Geruch  
- Freitext für ergänzende Hinweise  

📌 **Ziel:** Ärztliche Kommunikation verbessern & Therapieerfolge sichtbar machen.

---

### 🟡 3. EssGefühl (Ernährungstagebuch)  
Verknüpfe Mahlzeiten mit Symptomen und erkenne Auslöser.  
**Funktionen:**  
- Mahlzeiten-Logging mit Zutaten & Freitext  
- Markierung von Unverträglichkeiten (z. B. Laktose, Gluten)  
- Analyse: Symptome 2–4 h nach dem Essen  
- Alert-Funktion: Warnung bei bekannten Auslösern  

📌 **Ziel:** Ernährung und Wohlbefinden gezielt in Einklang bringen.

---

### 🔵 4. SeelenLog (Psychisches Wohlbefinden)  
Erfasse dein mentales und emotionales Befinden.  
**Funktionen:**  
- Stimmung per Emoji- oder Farbskala  
- Stresslevel (1–10)  
- Freitexttagebuch  
- Optional: Tags wie *Angst*, *Wut*, *Freude*  

📌 **Ziel:** Selbstreflexion fördern und psychische Einflüsse auf CED sichtbar machen.

---

## 📅 Kalender & Rückblicke  
- Tages-, Wochen- und Monatsübersichten  
- Filter nach Symptomen, Stimmung oder Ernährung  
- Automatische **Statistik-Generierung**  
- **PDF-Export** für Arztgespräche („ArztAssistent“)

---

## 💊 MediManager  
- Medikamente verwalten (Name, Dosis, Einnahmezeit)  
- Push-Benachrichtigungen zur Erinnerung  
- Verlaufsübersicht der Einnahmen  

---

## 📍 Hilfe für unterwegs  
- **Toilettenfinder:** GPS-gestützt, mit Filtern (Barrierefreiheit etc.)  
- **GastroGuide:** Restaurants mit Community-Bewertungen  
  - Freitextbewertungen (anonym)  
  - Sortier- und Favoritenfunktion  
- *(Geplant)* **QR-Code-Scanner** für Lebensmittel (ähnlich *CodeCheck*)  

---

## 📚 CED-Wissen  
- Artikel, Videos und Checklisten zu Themen wie Ernährung, Bewegung, Psyche  
- Verlinkungen zu Fachgesellschaften (z. B. DCCV)  
- Optional: Community-FAQ oder Antworten von Ärzt*innen  

---

## 💡 Beispiel im Alltag  
> **Mittag:** 🍝 Lasagne mit Käse → (*EssGefühl*: Mahlzeit loggen, enthält Laktose)  
>  
> **2 h später:** 😖 Krämpfe & Durchfall → (*SymptomRadar*: Bauchschmerzen erfassen)  
>  
> **3× Toilette:** 🚽 (*StuhlTagebuch*: Typ 6 + Schleim)  
>  
> **Abends:** 😔 Gestresst & traurig → (*SeelenLog*: Stimmung erfassen)  

---

## 🧩 Technische Umsetzung  
| Komponente | Technologie |
|-------------|-------------|
| **Framework** | Flutter (Dart) |
| **Architektur** | Layer-First (Model → Repository → Service → UI) |
| **State-Management** | Provider |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Zukünftig geplant** | Schnittstelle zu Python/FastAPI für Analysen |

---

## 📁 Projektstruktur

- **lib/**
  - models/
  - repositories/
  - services/
  - utils/
  - widgets/
  - firebase_options.dart
  - main.dart

---

## 🪪 Lizenz

Dieses Projekt steht unter einer **modifizierten MIT-Lizenz**  
mit **nicht-kommerzieller Nutzung** und **Zustimmungspflicht aller Autor*innen**.

Kommerzielle Nutzung, Weitergabe oder Veröffentlichung sind nur mit dem
schriftlichen Einverständnis aller beteiligten Personen erlaubt:

- Ahmad Kalaf  
- Afrane Kwame Berquin  
- Miriam Schwarz  
- Aliena Glatzel  

➡️ Siehe [LICENSE](./LICENSE) für den vollständigen Lizenztext.