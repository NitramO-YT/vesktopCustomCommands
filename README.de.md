[ ![🇬🇧 English](https://img.shields.io/badge/%F0%9F%87%AC%F0%9F%87%A7-English-blue) ](README.md) [ ![🇫🇷 Français](https://img.shields.io/badge/%F0%9F%87%AB%F0%9F%87%B7-Fran%C3%A7ais-blue) ](README.fr.md) [ ![🇪🇸 Español](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%B8-Espa%C3%B1ol-blue) ](README.es.md) [ ![🇮🇹 Italiano](https://img.shields.io/badge/%F0%9F%87%AE%F0%9F%87%B9-Italiano-blue) ](README.it.md) [ ![🇷🇺 Русский](https://img.shields.io/badge/%F0%9F%87%B7%F0%9F%87%BA-%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-blue) ](README.ru.md) [ ![🇯🇵 日本語](https://img.shields.io/badge/%F0%9F%87%AF%F0%9F%87%B5-%E6%97%A5%E6%9C%AC%E8%AA%9E-blue) ](README.ja.md) [ ![🇨🇳 中文](https://img.shields.io/badge/%F0%9F%87%A8%F0%9F%87%B3-%E4%B8%AD%E6%96%87-blue) ](README.zh.md) [ ![🇰🇷 한국어](https://img.shields.io/badge/%F0%9F%87%B0%F0%9F%87%B7-%ED%95%9C%EA%B5%AD%EC%96%B4-blue) ](README.ko.md)

# Einführung in vesktopCustomCommands (VCC)
VCC ist ein System, mit dem Sie globale Tastenkombinationen zum Stummschalten und Taubschalten zu Vesktop hinzufügen können. Es ist eine Übergangslösung für den Mangel an globalen Tastenkombinationen in Vesktop, bis das Vesktop-Team eine bessere Lösung findet.
Es handelt sich im Grunde um eine Reihe von Skripten (`mute.sh` & `deafen.sh`), die Sie über eine benutzerdefinierte globale Tastenkombination in Ihrem System aufrufen können, um sich in Vesktop stumm zu schalten und taub zu schalten. Diese Aktionen werden in Vesktop ausgelöst, indem ein benutzerdefinierter Javascript-Code in die Vencord-Hauptdatei eingefügt wird.

# Tastenkombinationen-Konfiguration in Ihrem System
Sie müssen eine benutzerdefinierte globale Tastenkombination in Ihrem System konfigurieren, um die Skripte `mute.sh` und `deafen.sh` im Ordner `~/.vesktopCustomCommands/` aufzurufen.
```plaintext
~/.vesktopCustomCommands/mute.sh
```
```plaintext
~/.vesktopCustomCommands/deafen.sh
```

---

# Installation

## Automatische Installation
Führen Sie diesen Befehl in Ihrem Terminal aus und folgen Sie den Anweisungen:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/install.sh)"
```
Hinweis: Wenn bereits eine Konfigurationsdatei unter `~/.vesktopCustomCommands/.config` existiert, behält der Installer diese bei und aktualisiert nur den Eintrag `vencord_path`, falls erforderlich.

### Optional: Automatisches Neupatchen

Während der Installation können Sie ein automatisches Neuropatch-System aktivieren, das regelmäßig überprüft, ob der VCC-Patch noch in der Vencord-Hauptdatei vorhanden ist, und ihn erneut anwendet, wenn er entfernt wurde (z. B. nach einem Update oder Zurücksetzen von Vencord/Vesktop).

- Warum ist es notwendig? Vesktop/Vencord-Updates oder bestimmte Startszenarien können die Hauptdatei in ihren ursprünglichen Zustand zurückversetzen und dabei die VCC-Injektion entfernen. Das automatische Neupatchen stellt sicher, dass Ihre Tastenkombinationen ohne manuelles Eingreifen weiterhin funktionieren.
- Die Einstellungen werden in `~/.vesktopCustomCommands/.config` gespeichert:
  - `auto_repatch="true|false"` (Standard: `false`)
  - `auto_restart="true|false"` (Standard: `false`) – falls aktiviert, wird Vesktop nach einem Neupatch automatisch neu gestartet. Sie können dies später mit den folgenden Befehlen umschalten.
  - `autorepatch_interval="30s|1m|3m"` (Standard: `30s`) – Überprüfungsintervall.
  - Ein Benutzer-`systemd`-Timer läuft im gewählten Intervall, wenn `auto_repatch` aktiviert ist.
  - Um automatisches Neupatchen zu aktivieren:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorepatch.sh)"
  ```
  - Um automatisches Neupatchen zu deaktivieren:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorepatch.sh)"
  ```

  - Um automatischen Neustart zu aktivieren (nach Neupatch):
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorestart.sh)"
  ```
  - Um automatischen Neustart zu deaktivieren:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorestart.sh)"
  ```


Manuelle Konfiguration: Bearbeiten Sie `~/.vesktopCustomCommands/.config` und setzen Sie `auto_repatch` und `auto_restart`. Sie können auch `autorepatch_interval` auf `"30s"`, `"1m"` oder `"3m"` setzen. Wenn Sie es manuell deaktivieren, wird der Timer beim nächsten Installationslauf gestoppt, oder führen Sie das obige Deaktivierungsskript aus.

### Optional: Automatische Aktualisierung

Sie können ein automatisches Aktualisierungssystem aktivieren, das regelmäßig überprüft, ob auf GitHub eine neuere Version verfügbar ist, und die erforderlichen Dateien aktualisiert (benutzerdefinierter Code für Vencord und lokale Skripte wie `mute.sh` und `deafen.sh`).

- Einstellungen in `~/.vesktopCustomCommands/.config`:
  - `auto_update="true|false"` (Standard: `false`)
  - `auto_update_interval` (Standard: `15m`) – der Timer läuft mit `autorepatch_interval`, wenn automatisches Neupatchen aktiviert ist, andernfalls mit `auto_update_interval`, wenn nur automatische Aktualisierung aktiviert ist.
- Um automatische Aktualisierung zu aktivieren:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autoupdate.sh)"
  ```
- Um automatische Aktualisierung zu deaktivieren:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autoupdate.sh)"
  ```

## Manuelle Installation
1. Laden Sie den Ordner `dist` aus dem Repository oder dessen Inhalt herunter.
2. `dist` ist in zwei Teile unterteilt:
    - Der Ordner `vencord` enthält die Dateien, die in die Vencord-Hauptdatei eingefügt werden sollen.
    - Der Ordner `vesktopCustomCommands` enthält die Skripte zum Stummschalten/Taubschalten und die `.config`-Datei.
3. Sie können eine Sicherung Ihrer Vencord-Hauptdatei erstellen (normalerweise unter `~/.config/Vencord/dist/vencordDesktopMain.js`, also `cp ~/.config/Vencord/dist/vencordDesktopMain.js ~/.config/Vencord/dist/vencordDesktopMain.js.bak`) oder nicht. Wenn Sie sie später wiederherstellen möchten, können Sie die Datei löschen und Vesktop starten, um sie neu zu erstellen.
4. Fügen Sie den Inhalt von `vencordDesktopMain_sample.js` in Ihre Vencord-Hauptdatei ein (normalerweise unter `~/.config/Vencord/dist/vencordDesktopMain.js`):
    - Fügen Sie den gesamten Inhalt von `vencordDesktopMain_sample.js` direkt vor der Zeile `//# sourceURL=` am Ende der Datei ein.
5. Erstellen Sie ein Verzeichnis `vesktopCustomCommands` in Ihrem Vencord-Pfad (normalerweise unter `~/.config/Vencord/dist/`) und legen Sie die Datei `customCode.js` dort ab.
6. Erstellen Sie ein Verzeichnis `~/.vesktopCustomCommands` und legen Sie die Dateien `mute.sh` und `deafen.sh` dort ab.
7. Fügen Sie Berechtigungen zu den Skripten `mute.sh` und `deafen.sh` hinzu:
    ```bash
    chmod +x ~/.vesktopCustomCommands/mute.sh
    chmod +x ~/.vesktopCustomCommands/deafen.sh
    ```
8. Legen Sie die `.config`-Datei in `~/.vesktopCustomCommands` ab und aktualisieren Sie die Variable `vencord_path` mit Ihrem Vencord-Pfad, falls erforderlich.
9. Starten Sie Vesktop neu, um die Änderungen anzuwenden.
10. Konfigurieren Sie eine benutzerdefinierte globale Tastenkombination in Ihrem System, um die Skripte `mute.sh` und `deafen.sh` im Ordner `~/.vesktopCustomCommands/` aufzurufen.
    - `mute.sh` um sich stumm zu schalten. `~/.vesktopCustomCommands/mute.sh`
    - `deafen.sh` um sich taub zu schalten. `~/.vesktopCustomCommands/deafen.sh`
11. Genießen Sie Ihre neuen globalen Tastenkombinationen zum Stummschalten und Taubschalten!

---

# Deinstallation

## Automatische Deinstallation

Führen Sie diesen Befehl in Ihrem Terminal aus und folgen Sie den Anweisungen:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/uninstall.sh)"
```
Während der Deinstallation werden Sie gefragt, ob Sie ALLES entfernen möchten, einschließlich Ihrer Einstellungen (`~/.vesktopCustomCommands/.config`).
- Antworten Sie mit "y": Alle Dateien und Einstellungen werden entfernt.
- Antworten Sie mit "n": Nur Programmdateien werden entfernt; Ihre `.config` wird beibehalten.

Wenn Einstellungen entfernt werden, werden auch der automatische Neuropatch-Dienst/Timer und Hilfsskripte entfernt. Wenn Sie die automatische Deinstallation ablehnen, folgen Sie den manuellen Deinstallationsschritten unten (die gleichen Anweisungen werden auch vom Skript ausgegeben).

## Manuelle Deinstallation

1. Entfernen Sie die benutzerdefinierten globalen Tastenkombinationen in Ihrem System, die die Skripte `mute.sh` und `deafen.sh` im Ordner `~/.vesktopCustomCommands/` aufrufen.
2. Entfernen Sie die `.config`-Datei in `~/.vesktopCustomCommands`.
3. Entfernen Sie den Ordner `~/.vesktopCustomCommands`.
4. Entfernen Sie die Datei `customCode.js` in Ihrem Vencord-Pfad `~/.config/Vencord/dist/vesktopCustomCommands/`.
5. Entfernen Sie den Ordner `vesktopCustomCommands` in Ihrem Vencord-Pfad `~/.config/Vencord/dist/`.
6. Entfernen Sie den eingefügten Code in Ihrer Vencord-Hauptdatei (normalerweise unter `~/.config/Vencord/dist/vencordDesktopMain.js`) oder ersetzen Sie sie durch die Sicherung, die Sie erstellt haben, falls vorhanden. (Sie können die Datei auch löschen und Vesktop starten, um sie neu zu erstellen).
7. Starten Sie Vesktop neu, um die Änderungen anzuwenden.

---

# Probleme und Verbesserungen

Wenn Sie Probleme haben oder Verbesserungsvorschläge haben, öffnen Sie bitte ein Issue!

# Beiträge

Ich weiß, dass dieses System nicht perfekt ist und dass ich nicht alle Standards und Semantiken eingehalten habe. Deshalb zähle ich auf diejenigen, die mir helfen möchten, dieses System zu verbessern. Issues und Pull Requests sind offen, und ich bin offen für jede konstruktive Kritik!

---

# Erklärung des Hauptziels dieses Projekts

Ich war ein Benutzer, der an KDE Neon unter X11 gewöhnt war, und mein Discord funktionierte im Allgemeinen gut. Kürzlich bin ich auf KDE Neon unter Wayland umgestiegen und habe festgestellt, dass Discord viele Probleme damit hatte, insbesondere war Bildschirmfreigabe für mich unmöglich. Auf der Suche nach einer Lösung für meine Discord-Probleme entdeckte ich Vesktop und damit Vencord, und ich entdeckte all die Probleme, die es löste, und sogar einige, die ich bereits unter X11 hatte (wie die reine und einfache Abwesenheit der Möglichkeit, Ton während einer Bildschirmfreigabe zu teilen). Ich habe es installiert und alles war perfekt, bis auf ein kleines Detail: der Mangel an Unterstützung für globale Tastaturkürzel. Die einzige Möglichkeit waren die Standard-Discord-Shortcuts (`Ctrl + Shift + M` und `Ctrl + Shift + D`), die nur funktionieren, wenn das Fenster aktiv ist. Also begann ich, nach Shortcuts in Vesktop zu suchen, und ich konnte sehen und lesen, dass das Problem bekannt ist, aber die Lösung noch weit entfernt ist, besonders unter Wayland, das das Leben von Entwicklern zu verkomplizieren scheint, die globale Tastaturkürzel erstellen möchten. Also dachte ich daran, aufzugeben, aber wie jeder gute Entwickler konnte ich mich nicht damit abfinden, also dachte ich über eine Lösung nach und fand eine provisorische, aber robuste Lösung. Ich wollte kein instabiles System, also versuchte ich, mein System so einfach und funktional wie möglich zu gestalten. Ich hätte Vesktop forken und hart arbeiten können, um eine Lösung zu finden oder meine zu integrieren, aber ich habe diese Anmaßung und Zeit nicht mehr, und außerdem denke ich nicht, dass es seriös oder gesund ist, ein alternatives Repository für Leute zu erstellen, die globale Tastaturkürzel in ihrem Vesktop wollen. Also dachte ich, das Ideal wäre, es als Mod oder Add-on zu betrachten, das zum offiziellen hinzugefügt wird, ein bisschen wie Vencord selbst am Ende, dass interessierte Leute es installieren können, wenn sie es auf ihrer Seite benötigen. Das wird ausreichen, bis Vesktop eine Lösung für globale Tastaturkürzel findet!

---

Danke :)



<!-- Made with ❤️ by NitramO -->
