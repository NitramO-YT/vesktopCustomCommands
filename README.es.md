[ ![🇬🇧 English](https://img.shields.io/badge/%F0%9F%87%AC%F0%9F%87%A7-English-blue) ](README.md) [ ![🇫🇷 Français](https://img.shields.io/badge/%F0%9F%87%AB%F0%9F%87%B7-Fran%C3%A7ais-blue) ](README.fr.md) [ ![🇩🇪 Deutsch](https://img.shields.io/badge/%F0%9F%87%A9%F0%9F%87%AA-Deutsch-blue) ](README.de.md) [ ![🇮🇹 Italiano](https://img.shields.io/badge/%F0%9F%87%AE%F0%9F%87%B9-Italiano-blue) ](README.it.md) [ ![🇷🇺 Русский](https://img.shields.io/badge/%F0%9F%87%B7%F0%9F%87%BA-%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-blue) ](README.ru.md) [ ![🇯🇵 日本語](https://img.shields.io/badge/%F0%9F%87%AF%F0%9F%87%B5-%E6%97%A5%E6%9C%AC%E8%AA%9E-blue) ](README.ja.md) [ ![🇨🇳 中文](https://img.shields.io/badge/%F0%9F%87%A8%F0%9F%87%B3-%E4%B8%AD%E6%96%87-blue) ](README.zh.md) [ ![🇰🇷 한국어](https://img.shields.io/badge/%F0%9F%87%B0%F0%9F%87%B7-%ED%95%9C%EA%B5%AD%EC%96%B4-blue) ](README.ko.md)

# Introducción a vesktopCustomCommands (VCC)
VCC es un sistema que te permite agregar atajos globales para silenciar el micrófono y ensordecer en Vesktop. Es una solución temporal ante la falta de atajos globales en Vesktop por ahora, hasta que el equipo de Vesktop encuentre una mejor solución.
Básicamente es un conjunto de scripts (`mute.sh` y `deafen.sh`) que puedes llamar desde un atajo global personalizado en tu sistema para silenciarte y ensordecerte en Vesktop, y desencadena estas acciones en Vesktop mediante la inyección de un código Javascript personalizado en el archivo de precarga de Vencord.

# Configuración de atajos en tu sistema
Necesitas configurar un atajo global personalizado en tu sistema para llamar a los scripts `mute.sh` y `deafen.sh` en la carpeta `~/.vesktopCustomCommands/`.
```plaintext
~/.vesktopCustomCommands/mute.sh
```
```plaintext
~/.vesktopCustomCommands/deafen.sh
```

---

# Instalación

## Instalación automática
Ejecuta este comando en tu terminal y sigue las instrucciones:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/install.sh)"
```
Nota: Si ya existe un archivo de configuración en `~/.vesktopCustomCommands/.config`, el instalador lo preserva y solo actualiza la entrada `vencord_path` si es necesario.

### Opcional: Reparcheo automático

Durante la instalación, puedes habilitar un sistema de reparcheo automático que verifica periódicamente si el parche de VCC todavía está presente en el archivo de precarga de Vencord y lo vuelve a aplicar si se ha eliminado (por ejemplo, después de una actualización o reinicio de Vencord/Vesktop).

- ¿Por qué es necesario? Las actualizaciones de Vesktop/Vencord o ciertos escenarios de inicio pueden restaurar el archivo de precarga a su estado original, eliminando la inyección de VCC. El reparcheo automático asegura que tus atajos sigan funcionando sin intervención manual.
- La configuración se almacena en `~/.vesktopCustomCommands/.config`:
  - `auto_repatch="true|false"` (predeterminado: `false`)
  - `auto_restart="true|false"` (predeterminado: `false`) – si está habilitado, Vesktop se reiniciará automáticamente después de un reparcheo. Puedes activarlo/desactivarlo más tarde con los comandos siguientes.
  - `autorepatch_interval="30s|1m|3m"` (predeterminado: `30s`) – intervalo de verificaciones.
  - Un temporizador de `systemd` de usuario se ejecuta en el intervalo elegido cuando `auto_repatch` está habilitado.
  - Para habilitar el reparcheo automático:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorepatch.sh)"
  ```
  - Para deshabilitar el reparcheo automático:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorepatch.sh)"
  ```

  - Para habilitar el reinicio automático (después del reparcheo):
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorestart.sh)"
  ```
  - Para deshabilitar el reinicio automático:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorestart.sh)"
  ```


Configuración manual: edita `~/.vesktopCustomCommands/.config` y establece `auto_repatch` y `auto_restart`. También puedes establecer `autorepatch_interval` en `"30s"`, `"1m"` o `"3m"`. Si lo deshabilitas manualmente, el temporizador se detendrá en la próxima ejecución de instalación, o ejecuta el script de deshabilitación anterior.

### Opcional: Actualización automática

Puedes habilitar un sistema de actualización automática que verifica periódicamente si hay una versión más reciente disponible en GitHub y actualiza los archivos necesarios (código personalizado para Vencord y scripts locales como `mute.sh` y `deafen.sh`).

- Configuración en `~/.vesktopCustomCommands/.config`:
  - `auto_update="true|false"` (predeterminado: `false`)
  - `auto_update_interval` (predeterminado: `15m`) – el temporizador se ejecuta en `autorepatch_interval` si el reparcheo automático está habilitado, de lo contrario en `auto_update_interval` si solo está habilitada la actualización automática.
- Para habilitar la actualización automática:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autoupdate.sh)"
  ```
- Para deshabilitar la actualización automática:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autoupdate.sh)"
  ```

## Instalación manual
1. Descarga la carpeta `dist` del repositorio o su contenido.
2. `dist` está separado en dos partes:
    - La carpeta `vencord` contiene los archivos para inyectar en el archivo de precarga de Vencord.
    - La carpeta `vesktopCustomCommands` contiene los scripts para silenciar/ensordecer y el archivo `.config`.
3. Puedes hacer una copia de seguridad de tu archivo de precarga de Vencord (generalmente ubicado en `~/.config/Vencord/dist/vencordDesktopPreload.js` con `cp ~/.config/Vencord/dist/vencordDesktopPreload.js ~/.config/Vencord/dist/vencordDesktopPreload.js.bak`) o no, si quieres restaurarlo más tarde puedes eliminar el archivo e iniciar Vesktop para recrearlo.
4. Inyecta el contenido de `vencordDesktopPreload_sample.js` en tu archivo de precarga de Vencord (generalmente ubicado en `~/.config/Vencord/dist/vencordDesktopPreload.js`):
    - **MÉTODO UNIVERSAL (funciona con todas las versiones de Vencord):** Inserta el contenido completo de `vencordDesktopPreload_sample.js` justo antes de la línea `//# sourceURL=file:///VencordPreload` al final del archivo.
    - **Alternativa:** Reemplaza el archivo completo con el `vencordDesktopPreload.js` proporcionado (*NO RECOMENDADO, ya que en caso de una actualización de Vesktop, si VCC no se ha actualizado desde entonces, es menos confiable y este archivo puede estar obsoleto*).
5. Crea un directorio `vesktopCustomCommands` en tu ruta de Vencord (generalmente ubicado en `~/.config/Vencord/dist/`) y coloca el archivo `customCode.js` en él.
6. Crea un directorio `~/.vesktopCustomCommands` y coloca los archivos `mute.sh` y `deafen.sh` en él.
7. Agrega permisos a los scripts `mute.sh` y `deafen.sh`:
    ```bash
    chmod +x ~/.vesktopCustomCommands/mute.sh
    chmod +x ~/.vesktopCustomCommands/deafen.sh
    ```
8. Coloca el archivo `.config` en `~/.vesktopCustomCommands` y actualiza la variable `vencord_path` con tu ruta de Vencord si es necesario.
9. Reinicia Vesktop para aplicar los cambios.
10. Configura un atajo global personalizado en tu sistema para llamar a los scripts `mute.sh` y `deafen.sh` en la carpeta `~/.vesktopCustomCommands/`.
    - `mute.sh` para silenciarte. `~/.vesktopCustomCommands/mute.sh`
    - `deafen.sh` para ensordecerte. `~/.vesktopCustomCommands/deafen.sh`
11. ¡Disfruta de tus nuevos atajos globales para silenciarte y ensordecerte!

---

# Desinstalación

## Desinstalación automática

Ejecuta este comando en tu terminal y sigue las instrucciones:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/uninstall.sh)"
```
Durante la desinstalación, se te preguntará si deseas eliminar TODO, incluida tu configuración (`~/.vesktopCustomCommands/.config`).
- Responde "y": se eliminan todos los archivos y configuraciones.
- Responde "n": solo se eliminan los archivos del programa; tu `.config` se conserva.

Si se elimina la configuración, también se eliminan el servicio/temporizador de reparcheo automático y los scripts auxiliares. Si rechazas la desinstalación automática, sigue los pasos de desinstalación manual a continuación (las mismas instrucciones también se muestran mediante el script).

## Desinstalación manual

1. Elimina los atajos globales personalizados en tu sistema que llaman a los scripts `mute.sh` y `deafen.sh` en la carpeta `~/.vesktopCustomCommands/`.
2. Elimina el archivo `.config` en `~/.vesktopCustomCommands`.
3. Elimina la carpeta `~/.vesktopCustomCommands`.
4. Elimina el archivo `customCode.js` en tu ruta de Vencord `~/.config/Vencord/dist/vesktopCustomCommands/`.
5. Elimina la carpeta `vesktopCustomCommands` en tu ruta de Vencord `~/.config/Vencord/dist/`.
6. Elimina el código inyectado en tu archivo de precarga de Vencord (generalmente ubicado en `~/.config/Vencord/dist/vencordDesktopPreload.js`) o reemplázalo con la copia de seguridad que hiciste si la tienes. (También puedes eliminar el archivo e iniciar Vesktop para recrearlo).
7. Reinicia Vesktop para aplicar los cambios.

---

# Problemas y mejoras

Si tienes algún problema o sugerencia de mejora, ¡abre un issue!

# Contribuciones

Sé que este sistema no es perfecto y que no he respetado todos los estándares y semánticas, por eso cuento con aquellos que quieran ayudarme a mejorar este sistema. ¡Los issues y pull requests están abiertos, y estoy abierto a cualquier crítica constructiva!

---

# Explicación del objetivo principal de este proyecto

Yo era un usuario acostumbrado a KDE Neon bajo X11 y mi Discord funcionaba bien en general. Recientemente cambié a KDE Neon bajo Wayland y descubrí que Discord tenía muchos problemas en él, especialmente compartir pantalla era imposible para mí. Buscando resolver mis problemas con Discord, descubrí Vesktop y por extensión Vencord, y descubrí todos los problemas que resolvía e incluso algunos que ya tenía bajo X11 (como la ausencia pura y simple de la posibilidad de compartir sonido durante una transmisión de pantalla). Lo instalé y todo era perfecto, excepto por un pequeño detalle: la falta de soporte para atajos de teclado globales. La única posibilidad eran los atajos predeterminados de Discord (`Ctrl + Shift + M` y `Ctrl + Shift + D`) que solo funcionan si la ventana está activa. Entonces comencé a buscar atajos en Vesktop y pude ver y leer que el problema es conocido pero la solución aún está lejos de encontrarse, especialmente en Wayland que parece complicar la vida de los desarrolladores que buscan hacer atajos de teclado globales. Así que pensé en rendirme, pero como todo buen desarrollador, no pude resignarme, así que pensé en una solución y encontré una solución provisional pero robusta. No quería un sistema inestable, así que intenté hacer mi sistema lo más simple y funcional posible. Podría haber bifurcado Vesktop y trabajado duro para encontrar una solución o integrar la mía, pero ya no tengo esa pretensión ni tiempo, y además no creo que sea serio o saludable crear un repositorio alternativo para las personas que quieren atajos de teclado globales en su Vesktop. Así que pensé que lo ideal era pensar en ello como un mod o un complemento que se agrega sobre el oficial, un poco como Vencord mismo al final, que las personas interesadas puedan instalarlo si lo necesitan de su lado. ¡Eso será suficiente hasta que Vesktop encuentre una solución para los atajos de teclado globales!

---

Gracias :)



<!-- Made with ❤️ by NitramO -->
