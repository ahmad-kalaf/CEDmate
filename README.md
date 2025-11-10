# 🩺 CEDmate

**CEDmate** ist eine mobile App zur Unterstützung von Menschen mit **chronisch-entzündlichen
Darmerkrankungen (CED)** wie **Morbus Crohn** oder **Colitis ulcerosa**.  
Die App hilft Betroffenen, Symptome, Ernährung, Psyche und Krankheitsverlauf systematisch zu
erfassen und zu verstehen – für ein besseres Leben mit CED.

https://ahmad-kalaf.github.io/CEDmate/
⚠️ Hinweis zur Online-Version:
Die auf GitHub Pages bereitgestellte Web-App dient nur zur Demonstration
und ist nicht für den produktiven oder kommerziellen Gebrauch bestimmt.

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
    - Symptome im Schub
    - Schubauslöser
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

Mahlzeiten eintragen.  
**Funktionen:**

- Mahlzeiten-Logging mit Zutaten & Freitext
- Markierung von Unverträglichkeiten (z. B. Laktose, Gluten)

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

## 📍 Hilfe für unterwegs

- **Toilettenfinder:** GPS-gestützt, mit Filtern (Barrierefreiheit etc.)
- **GastroGuide:** Restaurants mit Community-Bewertungen
    - Freitextbewertungen (anonym)
    - Sortier- und Favoritenfunktion
- *(Geplant)* **QR-Code-Scanner** für Lebensmittel (ähnlich *CodeCheck*)

> Kartendaten © OpenStreetMap-Mitwirkende, verwendet unter der ODbL-Lizenz.
> Diese Kartenfunktionen dienen ausschließlich zu Demonstrations- und Lernzwecken.


---

## 📚 CED-Wissen

- Artikel, Videos und Checklisten zu Themen wie Ernährung, Bewegung, Psyche
- Verlinkungen zu Fachgesellschaften (z. B. DCCV)
- Optional: Community-FAQ oder Antworten von Ärzt*innen

---

## 🧩 Technische Umsetzung

| Komponente            | Technologie                                     |
|-----------------------|-------------------------------------------------|
| **Framework**         | Flutter (Dart)                                  |
| **Architektur**       | Layer-First (Model → Repository → Service → UI) |
| **State-Management**  | Provider                                        |
| **Backend**           | Firebase (Auth, Firestore, Storage)             |
| **Zukünftig geplant** | Schnittstelle zu Python/FastAPI für Analysen    |

---

## 📁 Projektstruktur

- **lib/**
    - models/
    - repositories/
    - services/
    - utils/
    - widgets/
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
- Larissa Pychlau
- Benedict Löhn

➡️ Siehe [LICENSE](./LICENSE) für den vollständigen Lizenztext.
