<!-- [🇫🇷 Lire ce fichier en français](README.fr.md) -->
[ ![🇫🇷 Lire ce fichier en français](https://img.shields.io/badge/%F0%9F%87%AB%F0%9F%87%B7-Lire%20ce%20fichier%20en%20fran%C3%A7ais-blue) ](README.fr.md)

# Introduction to vesktopCustomCommands (VCC)
VCC is a system that allows you to add a mute and deafen global shortcut to Vesktop, it is a workaround to the lack of global shortcuts in Vesktop for now and until a better solution is found by the Vesktop team.
It's basically a set of scripts (`mute.sh` & `deafen.sh`) that you can call from a custom global shortcut in your system to mute and deafen yourself in Vesktop, and it triggers theses actions in Vesktop by injecting a custom Javascript code in the Vencord preload file.

# Shortcuts configuration in your system
You need to configure a custom global shortcut in your system to call the scripts `mute.sh` and `deafen.sh` in `~/.vesktopCustomCommands/` folder.
```plaintext
~/.vesktopCustomCommands/mute.sh
```
```plaintext
~/.vesktopCustomCommands/deafen.sh
```

---

# Installation

## Automatic installation
Run this command in your terminal and follow the instructions:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/install.sh)"
```
Note: If a config file already exists at `~/.vesktopCustomCommands/.config`, the installer preserves it and only updates the `vencord_path` entry if necessary.

### Optional: Automatic repatch

During installation, you can enable an automatic repatch system that periodically checks whether the VCC patch is still present in the Vencord preload file and re-applies it if it has been removed (e.g. after an update or a reset of Vencord/Vesktop).

- Why is it needed? Vesktop/Vencord updates or certain startup scenarios can restore the preload file to its original state, removing the VCC injection. The auto-repatch ensures your shortcuts keep working without manual intervention.
- Settings are stored in `~/.vesktopCustomCommands/.config`:
  - `auto_repatch="true|false"` (default: `false`)
  - `auto_restart="true|false"` (default: `false`) – if enabled, Vesktop will be automatically restarted after a repatch.
  - `autorepatch_interval="30s|1m|3m"` (default: `30s`) – interval of checks.
- A user `systemd` timer runs at the chosen interval when `auto_repatch` is enabled.
- You can toggle it later with:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/src/vesktopCustomCommands/enable_autorepatch.sh)"
  ```
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/src/vesktopCustomCommands/disable_autorepatch.sh)"
  ```

Manual configuration: edit `~/.vesktopCustomCommands/.config` and set `auto_repatch` and `auto_restart`. You can also set `autorepatch_interval` to `"30s"`, `"1m"` or `"3m"`. If you disable it manually, the timer will be stopped on the next install run, or run the disable script above.

### Optional: Automatic update

You can enable an automatic update system that periodically checks if a newer version is available on GitHub and updates the necessary files (custom code for Vencord and local scripts like `mute.sh` and `deafen.sh`).

- Settings in `~/.vesktopCustomCommands/.config`:
  - `auto_update="true|false"` (default: `false`)
  - `auto_update_interval` (default: `15m`) – the timer runs at `autorepatch_interval` if auto-repatch is enabled, otherwise at `auto_update_interval` if only auto-update is enabled.
- Toggle later with:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/src/vesktopCustomCommands/enable_autoupdate.sh)"
  ```
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/src/vesktopCustomCommands/disable_autoupdate.sh)"
  ```

## Manual installation
1. Download the `dist` folder from the repository or its content.
2. `dist` is separated in two parts:
    - `vencord` folder contains the files to inject in the Vencord preload file.
    - `vesktopCustomCommands` folder contains the scripts to mute/deafen and the `.config` file.
3. You can make a backup of your Vencord preload file (usually located in `~/.config/Vencord/dist/vencordDesktopPreload.js` so `cp ~/.config/Vencord/dist/vencordDesktopPreload.js ~/.config/Vencord/dist/vencordDesktopPreload.js.bak`) or not, if you want to restore it later you can delete the file and start Vesktop to recreate it.
4. Either inject the content of `vencordDesktopPreload_sample.js` in your Vencord preload file (usually located in `~/.config/Vencord/dist/vencordDesktopPreload.js`) by replacing the line `document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})` by `document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r);(PRELOAD SAMPLE FILE CONTENT HERE),{once:!0})` and replace `(PRELOAD SAMPLE FILE CONTENT HERE)` by the content of `vencordDesktopPreload_sample.js`, or replace the whole file with the provided `vencordDesktopPreload.js` (*NOT RECOMMENDED, as in the event of a Vesktop update, if VCC has not been updated since then, it is less reliable, and this file may be obsolete*.).
5. Make a dir `vesktopCustomCommands` in your Vencord path (usually located in `~/.config/Vencord/dist/`) and put the file `customCode.js` in it.
6. Make a dir `~/.vesktopCustomCommands` and put the files `mute.sh` and `deafen.sh` in it.
7. Add permissions to the scripts `mute.sh` and `deafen.sh`:
    ```bash
    chmod +x ~/.vesktopCustomCommands/mute.sh
    chmod +x ~/.vesktopCustomCommands/deafen.sh
    ```
8. Put the `.config` file in `~/.vesktopCustomCommands` and update the `vencord_path` variable with your Vencord path if needed.
9. Restart Vesktop to apply the changes.
10. Configure a custom global shortcut in your system to call the scripts `mute.sh` and `deafen.sh` in `~/.vesktopCustomCommands/` folder.
    - `mute.sh` to mute yourself. `~/.vesktopCustomCommands/mute.sh`
    - `deafen.sh` to deafen yourself. `~/.vesktopCustomCommands/deafen.sh`
11. Enjoy your new global shortcuts to mute and deafen yourself!

---

# Uninstallation

## Automatic uninstallation

Run this command in your terminal and follow the instructions:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/uninstall.sh)"
```
During uninstallation, you'll be asked whether you want to remove EVERYTHING, including your settings (`~/.vesktopCustomCommands/.config`).
- Answer "y": all files and settings are removed.
- Answer "n": only program files are removed; your `.config` is preserved.

If settings are removed, the auto-repatch service/timer and helper scripts are also removed.

## Manual uninstallation

1. Remove the custom global shortcuts in your system that call the scripts `mute.sh` and `deafen.sh` in `~/.vesktopCustomCommands/` folder.
2. Remove the `.config` file in `~/.vesktopCustomCommands`.
3. Remove the `~/.vesktopCustomCommands` folder.
4. Remove the `customCode.js` file in your Vencord path `~/.config/Vencord/dist/vesktopCustomCommands/`.
5. Remove the `vesktopCustomCommands` folder in your Vencord path `~/.config/Vencord/dist/`.
6. Remove the injected code in your Vencord preload file (usually located in `~/.config/Vencord/dist/vencordDesktopPreload.js`) or replace it with the backup you made if you did. (You can also delete the file and start Vesktop to recreate it).
7. Restart Vesktop to apply the changes.

---

# Issues and improvements

If you have any issues or improvements to suggest, please open an issue!

# Contributions

I know that this system is not perfect and that I have not respected all the standards and semantics, that's why I'm counting on those who would like to help me improve this system, issues and pull requests are open, and I am open to any constructive criticism!

---

# Explanation of the main goal of this project

I was a user used to KDE Neon under X11 and so my Discord worked well, overall, and recently I switched to KDE Neon under Wayland and I discovered that Discord had a lot of problems on it, especially screen sharing was impossible for me, so looking to solve my problems with Discord, I discovered Vesktop and by extension Vencord, and I discovered all the problems it solved and even some that I already had under X11 (like the pure and simple absence of the possibility to share sound during a screen sharing), I installed it and everything was perfect, except for a small detail, the lack of support for Global Keyboard Shortcuts, the only possibility was the default Discord shortcuts (`Ctrl + Shift + M` and `Ctrl + Shift + D`) which only work if the window is active, so I started looking for shortcuts in Vesktop and I could see and read that the problem is known but the solution is still far from being found, especially on Wayland which seems to complicate the life of developers who are looking to make global keyboard shortcuts, so I thought I would give up on it, but like any good developer, I couldn't resign myself, so I thought of a solution, and I found a makeshift but robust solution, I didn't want an unstable system so I tried to make my system as simple and functional as possible, I could have forked Vesktop and worked hard to find a solution or integrate mine, but already I don't have this pretension and time, and moreover I don't think it's serious or healthy to create an alternative repository for people who want global keyboard shortcuts in their Vesktop, so I thought the ideal was to think of it as a mod or an addon that is added on top of the official one, a bit like Vencord itself in the end, that people interested can install it if they need it on their side. that will be enough until Vesktop finds a solution for global keyboard shortcuts!

---

Thank you :)



<!-- Made with ❤️ by NitramO -->