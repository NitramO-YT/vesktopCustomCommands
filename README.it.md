[ ![🇬🇧 English](https://img.shields.io/badge/%F0%9F%87%AC%F0%9F%87%A7-English-blue) ](README.md) [ ![🇫🇷 Français](https://img.shields.io/badge/%F0%9F%87%AB%F0%9F%87%B7-Fran%C3%A7ais-blue) ](README.fr.md) [ ![🇪🇸 Español](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%B8-Espa%C3%B1ol-blue) ](README.es.md) [ ![🇩🇪 Deutsch](https://img.shields.io/badge/%F0%9F%87%A9%F0%9F%87%AA-Deutsch-blue) ](README.de.md) [ ![🇷🇺 Русский](https://img.shields.io/badge/%F0%9F%87%B7%F0%9F%87%BA-%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-blue) ](README.ru.md) [ ![🇯🇵 日本語](https://img.shields.io/badge/%F0%9F%87%AF%F0%9F%87%B5-%E6%97%A5%E6%9C%AC%E8%AA%9E-blue) ](README.ja.md) [ ![🇨🇳 中文](https://img.shields.io/badge/%F0%9F%87%A8%F0%9F%87%B3-%E4%B8%AD%E6%96%87-blue) ](README.zh.md) [ ![🇰🇷 한국어](https://img.shields.io/badge/%F0%9F%87%B0%F0%9F%87%B7-%ED%95%9C%EA%B5%AD%EC%96%B4-blue) ](README.ko.md)

# Introduzione a vesktopCustomCommands (VCC)
VCC è un sistema che ti consente di aggiungere scorciatoie globali per disattivare l'audio e silenziare in Vesktop. È una soluzione temporanea alla mancanza di scorciatoie globali in Vesktop per ora, fino a quando il team di Vesktop non troverà una soluzione migliore.
Fondamentalmente è un insieme di script (`mute.sh` e `deafen.sh`) che puoi chiamare da una scorciatoia globale personalizzata nel tuo sistema per silenziare e assordare te stesso in Vesktop, e attiva queste azioni in Vesktop iniettando un codice Javascript personalizzato nel file di precaricamento di Vencord.

# Configurazione delle scorciatoie nel tuo sistema
Devi configurare una scorciatoia globale personalizzata nel tuo sistema per chiamare gli script `mute.sh` e `deafen.sh` nella cartella `~/.vesktopCustomCommands/`.
```plaintext
~/.vesktopCustomCommands/mute.sh
```
```plaintext
~/.vesktopCustomCommands/deafen.sh
```

---

# Installazione

## Installazione automatica
Esegui questo comando nel tuo terminale e segui le istruzioni:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/install.sh)"
```
Nota: Se un file di configurazione esiste già in `~/.vesktopCustomCommands/.config`, l'installatore lo preserva e aggiorna solo la voce `vencord_path` se necessario.

### Opzionale: Ripatch automatico

Durante l'installazione, puoi abilitare un sistema di ripatch automatico che verifica periodicamente se la patch VCC è ancora presente nel file di precaricamento di Vencord e la riapplica se è stata rimossa (ad esempio dopo un aggiornamento o un ripristino di Vencord/Vesktop).

- Perché è necessario? Gli aggiornamenti di Vesktop/Vencord o determinati scenari di avvio possono ripristinare il file di precaricamento al suo stato originale, rimuovendo l'iniezione di VCC. Il ripatch automatico garantisce che le tue scorciatoie continuino a funzionare senza intervento manuale.
- Le impostazioni sono memorizzate in `~/.vesktopCustomCommands/.config`:
  - `auto_repatch="true|false"` (predefinito: `false`)
  - `auto_restart="true|false"` (predefinito: `false`) – se abilitato, Vesktop verrà riavviato automaticamente dopo un ripatch. Puoi attivarlo/disattivarlo successivamente con i comandi seguenti.
  - `autorepatch_interval="30s|1m|3m"` (predefinito: `30s`) – intervallo di controllo.
  - Un timer `systemd` utente viene eseguito nell'intervallo scelto quando `auto_repatch` è abilitato.
  - Per abilitare il ripatch automatico:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorepatch.sh)"
  ```
  - Per disabilitare il ripatch automatico:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorepatch.sh)"
  ```

  - Per abilitare il riavvio automatico (dopo il ripatch):
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorestart.sh)"
  ```
  - Per disabilitare il riavvio automatico:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorestart.sh)"
  ```


Configurazione manuale: modifica `~/.vesktopCustomCommands/.config` e imposta `auto_repatch` e `auto_restart`. Puoi anche impostare `autorepatch_interval` su `"30s"`, `"1m"` o `"3m"`. Se lo disabiliti manualmente, il timer verrà fermato alla prossima esecuzione dell'installazione, oppure esegui lo script di disabilitazione sopra.

### Opzionale: Aggiornamento automatico

Puoi abilitare un sistema di aggiornamento automatico che verifica periodicamente se è disponibile una versione più recente su GitHub e aggiorna i file necessari (codice personalizzato per Vencord e script locali come `mute.sh` e `deafen.sh`).

- Impostazioni in `~/.vesktopCustomCommands/.config`:
  - `auto_update="true|false"` (predefinito: `false`)
  - `auto_update_interval` (predefinito: `15m`) – il timer viene eseguito a `autorepatch_interval` se il ripatch automatico è abilitato, altrimenti a `auto_update_interval` se è abilitato solo l'aggiornamento automatico.
- Per abilitare l'aggiornamento automatico:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autoupdate.sh)"
  ```
- Per disabilitare l'aggiornamento automatico:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autoupdate.sh)"
  ```

## Installazione manuale
1. Scarica la cartella `dist` dal repository o il suo contenuto.
2. `dist` è diviso in due parti:
    - La cartella `vencord` contiene i file da iniettare nel file di precaricamento di Vencord.
    - La cartella `vesktopCustomCommands` contiene gli script per silenziare/assordare e il file `.config`.
3. Puoi fare un backup del tuo file di precaricamento di Vencord (solitamente situato in `~/.config/Vencord/dist/vencordDesktopPreload.js` con `cp ~/.config/Vencord/dist/vencordDesktopPreload.js ~/.config/Vencord/dist/vencordDesktopPreload.js.bak`) oppure no, se vuoi ripristinarlo in seguito puoi eliminare il file e avviare Vesktop per ricrearlo.
4. Inietta il contenuto di `vencordDesktopPreload_sample.js` nel tuo file di precaricamento di Vencord (solitamente situato in `~/.config/Vencord/dist/vencordDesktopPreload.js`). Il metodo di iniezione dipende dalla tua versione di Vencord:
    - **Struttura VECCHIA di Vencord (versione 21e6178 o precedente):** Cerca la riga `document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})` e sostituiscila con `document.addEventListener("DOMContentLoaded",()=>{document.documentElement.appendChild(r);(CONTENUTO DEL FILE DI ESEMPIO DI PRECARICAMENTO QUI)},{once:!0})`, quindi sostituisci `(CONTENUTO DEL FILE DI ESEMPIO DI PRECARICAMENTO QUI)` con il contenuto di `vencordDesktopPreload_sample.js`.
    - **Struttura NUOVA di Vencord (versione c123efd o successiva):** Cerca il testo `getTheme",s.quickCss.getEditorTheme))` e sostituiscilo con `getTheme",s.quickCss.getEditorTheme));if(location.protocol!=="data:"){document.readyState==="complete"?(()=>{(CONTENUTO DEL FILE DI ESEMPIO DI PRECARICAMENTO QUI)})():document.addEventListener("DOMContentLoaded",()=>{(CONTENUTO DEL FILE DI ESEMPIO DI PRECARICAMENTO QUI)},{once:!0})}`, quindi sostituisci `(CONTENUTO DEL FILE DI ESEMPIO DI PRECARICAMENTO QUI)` con il contenuto di `vencordDesktopPreload_sample.js`.
    - **Alternativa:** Sostituisci l'intero file con il `vencordDesktopPreload.js` fornito (*NON RACCOMANDATO, poiché in caso di aggiornamento di Vesktop, se VCC non è stato aggiornato da allora, è meno affidabile e questo file potrebbe essere obsoleto*).
5. Crea una directory `vesktopCustomCommands` nel tuo percorso di Vencord (solitamente situato in `~/.config/Vencord/dist/`) e metti il file `customCode.js` al suo interno.
6. Crea una directory `~/.vesktopCustomCommands` e metti i file `mute.sh` e `deafen.sh` al suo interno.
7. Aggiungi i permessi agli script `mute.sh` e `deafen.sh`:
    ```bash
    chmod +x ~/.vesktopCustomCommands/mute.sh
    chmod +x ~/.vesktopCustomCommands/deafen.sh
    ```
8. Metti il file `.config` in `~/.vesktopCustomCommands` e aggiorna la variabile `vencord_path` con il tuo percorso di Vencord se necessario.
9. Riavvia Vesktop per applicare le modifiche.
10. Configura una scorciatoia globale personalizzata nel tuo sistema per chiamare gli script `mute.sh` e `deafen.sh` nella cartella `~/.vesktopCustomCommands/`.
    - `mute.sh` per silenziare te stesso. `~/.vesktopCustomCommands/mute.sh`
    - `deafen.sh` per assordare te stesso. `~/.vesktopCustomCommands/deafen.sh`
11. Goditi le tue nuove scorciatoie globali per silenziare e assordare te stesso!

---

# Disinstallazione

## Disinstallazione automatica

Esegui questo comando nel tuo terminale e segui le istruzioni:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/uninstall.sh)"
```
Durante la disinstallazione, ti verrà chiesto se desideri rimuovere TUTTO, comprese le tue impostazioni (`~/.vesktopCustomCommands/.config`).
- Rispondi "y": tutti i file e le impostazioni vengono rimossi.
- Rispondi "n": vengono rimossi solo i file del programma; il tuo `.config` viene conservato.

Se le impostazioni vengono rimosse, vengono rimossi anche il servizio/timer di ripatch automatico e gli script ausiliari. Se rifiuti la disinstallazione automatica, segui i passaggi di disinstallazione manuale di seguito (le stesse istruzioni vengono anche visualizzate dallo script).

## Disinstallazione manuale

1. Rimuovi le scorciatoie globali personalizzate nel tuo sistema che chiamano gli script `mute.sh` e `deafen.sh` nella cartella `~/.vesktopCustomCommands/`.
2. Rimuovi il file `.config` in `~/.vesktopCustomCommands`.
3. Rimuovi la cartella `~/.vesktopCustomCommands`.
4. Rimuovi il file `customCode.js` nel tuo percorso di Vencord `~/.config/Vencord/dist/vesktopCustomCommands/`.
5. Rimuovi la cartella `vesktopCustomCommands` nel tuo percorso di Vencord `~/.config/Vencord/dist/`.
6. Rimuovi il codice iniettato nel tuo file di precaricamento di Vencord (solitamente situato in `~/.config/Vencord/dist/vencordDesktopPreload.js`) o sostituiscilo con il backup che hai fatto se ne hai uno. (Puoi anche eliminare il file e avviare Vesktop per ricrearlo).
7. Riavvia Vesktop per applicare le modifiche.

---

# Problemi e miglioramenti

Se hai problemi o suggerimenti per miglioramenti, apri un issue!

# Contributi

So che questo sistema non è perfetto e che non ho rispettato tutti gli standard e le semantiche, ecco perché conto su coloro che vogliono aiutarmi a migliorare questo sistema. Issues e pull request sono aperti, e sono aperto a qualsiasi critica costruttiva!

---

# Spiegazione dell'obiettivo principale di questo progetto

Ero un utente abituato a KDE Neon su X11 e il mio Discord funzionava bene in generale. Di recente sono passato a KDE Neon su Wayland e ho scoperto che Discord aveva molti problemi su di esso, soprattutto la condivisione dello schermo era impossibile per me. Cercando di risolvere i miei problemi con Discord, ho scoperto Vesktop e per estensione Vencord, e ho scoperto tutti i problemi che risolveva e persino alcuni che già avevo su X11 (come la pura e semplice assenza della possibilità di condividere l'audio durante una condivisione dello schermo). L'ho installato e tutto era perfetto, tranne un piccolo dettaglio: la mancanza di supporto per le scorciatoie da tastiera globali. L'unica possibilità erano le scorciatoie predefinite di Discord (`Ctrl + Shift + M` e `Ctrl + Shift + D`) che funzionano solo se la finestra è attiva. Quindi ho iniziato a cercare scorciatoie in Vesktop e ho potuto vedere e leggere che il problema è noto ma la soluzione è ancora lontana dall'essere trovata, soprattutto su Wayland che sembra complicare la vita degli sviluppatori che cercano di creare scorciatoie da tastiera globali. Quindi ho pensato di rinunciare, ma come ogni buon sviluppatore, non potevo rassegnarmi, quindi ho pensato a una soluzione e ho trovato una soluzione provvisoria ma robusta. Non volevo un sistema instabile, quindi ho cercato di rendere il mio sistema il più semplice e funzionale possibile. Avrei potuto forkare Vesktop e lavorare duramente per trovare una soluzione o integrare la mia, ma non ho più questa pretesa e tempo, e inoltre non penso sia serio o sano creare un repository alternativo per le persone che vogliono scorciatoie da tastiera globali nel loro Vesktop. Quindi ho pensato che l'ideale fosse pensarlo come un mod o un addon che si aggiunge a quello ufficiale, un po' come Vencord stesso alla fine, che le persone interessate possano installarlo se ne hanno bisogno dal loro lato. Questo sarà sufficiente finché Vesktop non troverà una soluzione per le scorciatoie da tastiera globali!

---

Grazie :)



<!-- Made with ❤️ by NitramO -->
