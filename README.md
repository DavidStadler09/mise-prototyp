# Mise — Betriebs-OS (Prototyp)

Klickbarer High-Fidelity-Prototyp des KI-Betriebspartners für kleine & mittlere Unternehmen
(Beispiel-Zielgruppe: Gastronomie). Enthält den Betriebsleiter (domänenübergreifendes Cockpit)
und den voll ausgebauten Finanz-Agenten.

## Live
https://strong-crisp-52a2d7.netlify.app

## Dateien
- `index.html` — die deploybare App (Einstiegspunkt, wird von Netlify ausgeliefert)
- `Mise-Prototyp.html` — identische Arbeitskopie des Prototyps
- `Finanz-Agent-Feature-Map.html` — Feature-Map / Produktplanung (Orientierung an SevDesk)
- `Finanz-Agent Wireframes.dc.html` — ursprüngliche Wireframes

> Beim Bearbeiten des Prototyps `index.html` und `Mise-Prototyp.html` identisch halten
> (oder nur `index.html` pflegen — das ist die Datei, die live geht).

## Zusammenarbeit über Git

### Einmalige Einrichtung pro Person
1. Git installieren: https://git-scm.com/download/win — enthält den *Git Credential Manager*,
   der den GitHub-Login beim ersten Push automatisch im Browser öffnet.
2. GitHub-Konto anlegen (falls noch keins vorhanden) und vom Repo-Owner als *Collaborator*
   einladen lassen.
3. Repo klonen (URL vom Owner):
   `git clone https://github.com/<owner>/<repo>.git`
4. Eigene Identität setzen:
   `git config user.name "Vorname Name"`
   `git config user.email "deine@email.de"`

### Täglicher Ablauf — auch mit Claude/Cowork
- Vor der Arbeit neuesten Stand holen: `git pull`
- Nach Änderungen: `git add -A` → `git commit -m "Beschreibung"` → `git push`
- In Cowork genügt der Satz: **„Committe und pushe meine Änderungen."** — Claude führt die
  Git-Befehle für dich aus.

### Konflikte vermeiden
- Immer zuerst `git pull`, bevor ihr anfangt.
- Nicht gleichzeitig dieselbe Datei bearbeiten. Für größere Änderungen einen eigenen Branch:
  `git checkout -b feature-xyz` und danach zusammenführen (Merge / Pull Request).

## Auto-Deploy
Ist das Repo in Netlify verbunden, aktualisiert **jeder Push automatisch die Live-Seite**.
