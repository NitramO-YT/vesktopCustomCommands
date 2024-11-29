<!-- [🇬🇧 Read this file in English](README.md) -->
[ ![🇬🇧 Read this file in English](https://img.shields.io/badge/%F0%9F%87%AC%F0%9F%87%A7-Read%20this%20file%20in%20English-blue) ](README.md)

# Introduction à vesktopCustomCommands (VCC)

VCC est un système qui vous permet d'ajouter un raccourci global pour couper le son du microphone et rendre sourd sur Vesktop. C'est une solution temporaire pour pallier l'absence de raccourcis globaux dans Vesktop, en attendant que l'équipe Vesktop trouve une meilleure solution. 

Il s'agit essentiellement d'un ensemble de scripts (`mute.sh` & `deafen.sh`) que vous pouvez appeler via un raccourci global personnalisé dans votre système. Ces scripts exécutent les actions correspondantes dans Vesktop en injectant un code Javascript personnalisé dans le fichier de préchargement de Vencord.

# Configuration des raccourcis dans votre système

Vous devez configurer un raccourci global personnalisé dans votre système pour appeler les scripts `mute.sh` et `deafen.sh` situés dans le dossier `~/.vesktopCustomCommands/`.
```plaintext
~/.vesktopCustomCommands/mute.sh
```
```plaintext
~/.vesktopCustomCommands/deafen.sh
```

---

# Installation

## Installation automatique
Exécutez cette commande dans votre terminal et suivez les instructions :
```bash
curl -sL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/main/install.sh | bash
```

## Installation manuelle
1. Téléchargez le dossier `dist` du dépôt ou son contenu.
2. Le dossier `dist` est divisé en deux parties :
    - Le dossier `vencord` contient les fichiers à injecter dans le fichier de préchargement de Vencord.
    - Le dossier `vesktopCustomCommands` contient les scripts pour couper/rendre sourd et le fichier `.config`.
3. Vous pouvez faire une sauvegarde de votre fichier de préchargement Vencord (généralement situé dans `~/.config/Vencord/dist/vencordDesktopPreload.js`) avec :
   ```bash
   cp ~/.config/Vencord/dist/vencordDesktopPreload.js ~/.config/Vencord/dist/vencordDesktopPreload.js.bak
   ```
   Si vous souhaitez restaurer ce fichier plus tard, vous pouvez simplement le supprimer et redémarrer Vesktop pour qu'il soit recréé.
4. Injectez le contenu de `vencordDesktopPreload_sample.js` entre les lignes :
   ```javascript
   document.addEventListener("DOMContentLoaded",()=>{
   ```
   et 
   ```javascript
   document.documentElement.appendChild(r)},{once:!0})
   ```
   dans votre fichier de préchargement Vencord (généralement situé dans `~/.config/Vencord/dist/vencordDesktopPreload.js`) ou remplacez son contenu par celui de `vencordDesktopPreload.js` (*NON RECOMMANDÉ car en cas de mise à jour de Vesktop, si VCC n'a pas été mis à jour depuis, c'est moins fiable et il est possible que ce fichier soit obsolète.*).
5. Créez un dossier `vesktopCustomCommands` dans le chemin de Vencord (généralement situé dans `~/.config/Vencord/dist/`) et placez-y le fichier `customCode.js`.
6. Créez un dossier `~/.vesktopCustomCommands` et placez-y les fichiers `mute.sh` et `deafen.sh`.
7. Ajoutez les permissions nécessaires aux scripts `mute.sh` et `deafen.sh` :
    ```bash
    chmod +x ~/.vesktopCustomCommands/mute.sh
    chmod +x ~/.vesktopCustomCommands/deafen.sh
    ```
8. Placez le fichier `.config` dans `~/.vesktopCustomCommands` et mettez à jour la variable `vencord_path` avec le chemin de Vencord si nécessaire.
9. Redémarrez Vesktop pour appliquer les modifications.
10. Configurez un raccourci global personnalisé dans votre système pour appeler les scripts `mute.sh` et `deafen.sh` dans le dossier `~/.vesktopCustomCommands/`.
    - `mute.sh` pour couper le son du microphone : `~/.vesktopCustomCommands/mute.sh`
    - `deafen.sh` pour rendre sourd : `~/.vesktopCustomCommands/deafen.sh`
11. Profitez de vos nouveaux raccourcis globaux pour couper/rendre sourd !

---

# Désinstallation

## Désinstallation automatique

**PAS DE DÉSINSTALLATEUR AUTOMATIQUE DISPONIBLE POUR LE MOMENT. VEUILLEZ SUIVRE LES ÉTAPES DE DÉSINSTALLATION MANUELLE.**

## Désinstallation manuelle

1. Supprimez les raccourcis globaux personnalisés dans votre système qui appellent les scripts `mute.sh` et `deafen.sh` dans `~/.vesktopCustomCommands/`.
2. Supprimez le fichier `.config` dans `~/.vesktopCustomCommands`.
3. Supprimez le dossier `~/.vesktopCustomCommands`.
4. Supprimez le fichier `customCode.js` dans le chemin de Vencord `~/.config/Vencord/dist/vesktopCustomCommands/`.
5. Supprimez le dossier `vesktopCustomCommands` dans le chemin de Vencord `~/.config/Vencord/dist/`.
6. Supprimez le code injecté dans le fichier de préchargement de Vencord (généralement situé dans `~/.config/Vencord/dist/vencordDesktopPreload.js`) ou remplacez-le par la sauvegarde que vous avez faite.
7. Redémarrez Vesktop pour appliquer les changements.

---

# Problèmes et améliorations

Si vous rencontrez des problèmes ou avez des suggestions d'amélioration, veuillez ouvrir une issue !

# Contributions

Je sais que ce système n'est pas parfait et que je n'ai pas respecté tous les standards et sémantiques. C'est pourquoi je compte sur ceux qui souhaitent m'aider à améliorer ce système. Les issues et pull requests sont ouvertes, et je suis prêt à recevoir toute critique constructive !

---

# Objectif principal de ce projet

J'étais un utilisateur de KDE Neon sous X11, et mon Discord fonctionnait bien globalement. Récemment, je suis passé à KDE Neon sous Wayland et j'ai découvert que Discord avait de nombreux problèmes, notamment l'impossibilité de partager mon écran. En cherchant une solution, j'ai découvert Vesktop et, par extension, Vencord, qui ont résolu ces problèmes et même certains que j'avais déjà sous X11. Cependant, un détail manquait : le support des raccourcis globaux. Après des recherches, j'ai compris que le problème était connu mais loin d'être résolu, surtout sur Wayland. Je ne pouvais pas abandonner, alors j'ai conçu une solution simple et fonctionnelle. Ce projet est une solution temporaire jusqu'à ce que Vesktop trouve une solution officielle.

---

Merci :)



<!-- Fait avec ❤️ par NitramO -->