#!/bin/bash

# Normalize a path by replacing ~ with $HOME
normalizePath() {
    local input_path="$1"
    if [[ "$input_path" == ~* ]]; then
        echo "${input_path/#\~/$HOME}"
    else
        echo "$input_path"
    fi
}

# Detect Vesktop variant and prepare restart command
detect_vesktop() {
    DETECTED=""
    START_CMD=""
    KILL_CMD=""
    RUNNING="false"

    # Prefer explicit flatpak if present
    if command -v flatpak >/dev/null 2>&1; then
        if flatpak info dev.vencord.Vesktop >/dev/null 2>&1 || flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then
            DETECTED="flatpak"
            FP_BIN="$(command -v flatpak)"
            ARCH="$(uname -m)"
            START_CMD="$FP_BIN run dev.vencord.Vesktop"
            KILL_CMD="$FP_BIN kill dev.vencord.Vesktop || pkill -f dev.vencord.Vesktop || true"
            if flatpak ps 2>/dev/null | grep -q dev.vencord.Vesktop; then RUNNING="true"; fi
            return
        fi
    fi

    # System package (vesktop in PATH)
    if command -v vesktop >/dev/null 2>&1; then
        DETECTED="system"
        START_CMD="vesktop"
        KILL_CMD="pkill -x vesktop || pkill -f vesktop || true"
        if pgrep -x vesktop >/dev/null 2>&1 || pgrep -f '[Vv]esktop' >/dev/null 2>&1; then RUNNING="true"; fi
        return
    fi

    # Fallback: detect a running AppImage/tarball by PID and reuse its path
    PID="$(pgrep -f -n '[Vv]esktop' || true)"
    if [ -n "$PID" ] && [ -r "/proc/$PID/exe" ]; then
        EXE_PATH="$(readlink -f "/proc/$PID/exe" || true)"
        if [ -n "$EXE_PATH" ]; then
            DETECTED="path"
            START_CMD="$EXE_PATH"
            KILL_CMD="kill $PID || true"
            RUNNING="true"
            return
        fi
    fi
}

offer_restart_vesktop() {
    detect_vesktop
    if [ -n "$DETECTED" ]; then
        echo "We detected Vesktop variant: $DETECTED"
        if [ "$RUNNING" = "true" ]; then
            read -p 'Vesktop is running. Do you want us to restart it now? (y/n) ' -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                eval "$KILL_CMD"
                sleep 1
            nohup bash -c "$START_CMD" >/dev/null 2>&1 & disown
                echo 'Vesktop was restarted successfully.'
                return
            else
                echo 'You can restart Vesktop manually to apply the changes.'
                return
            fi
        else
            read -p 'Vesktop is not running. Do you want us to start it now? (y/n) ' -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                nohup bash -c "$START_CMD" >/dev/null 2>&1 & disown
                echo 'Vesktop was started successfully.'
                return
            else
                echo 'You can start Vesktop to apply and see the changes.'
                return
            fi
        fi
    fi
    echo '⚠️ Please (re)start Vesktop to apply the changes'
}

echo "This script will uninstall vesktopCustomCommands (VCC) from your system."
read -p 'Do you want to proceed with the uninstallation? (y/n) ' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "For a manual uninstallation, please follow these steps:" 
    echo "1. Remove the custom global shortcuts in your system that call the scripts 'mute.sh' and 'deafen.sh' in '~/.vesktopCustomCommands/'."
    echo "2. Remove the '.config' file located in '~/.vesktopCustomCommands/'."
    echo "3. Remove the '~/.vesktopCustomCommands' folder."
    echo "4. Remove the 'customCode.js' file from your Vencord path (usually '~/.config/Vencord/dist/vesktopCustomCommands/')."
    echo "5. Remove the 'vesktopCustomCommands' folder from your Vencord path (usually '~/.config/Vencord/dist/')."
    echo "6. Remove the injected code in your Vencord preload file (usually '~/.config/Vencord/dist/vencordDesktopPreload.js') or restore your backup."
    echo "   Tip: you can also delete the preload file and start Vesktop to recreate it automatically."
    echo "7. Restart Vesktop to apply the changes."
    echo "Note: If you had enabled auto-repatch/auto-update, you may also disable the user systemd timer with:"
    echo "   systemctl --user disable --now vcc-autorepatch.timer"
    echo "   systemctl --user disable --now vcc-autorepatch.service"
    exit 0
fi

DEFAULT_VENCORD_PATH="~/.config/Vencord/dist/"
VENCORD_PATH=$DEFAULT_VENCORD_PATH

# Ask for validation of Vencord path
read -p 'Is the path of Vencord for Vesktop "'${VENCORD_PATH}'"? (y/n) ' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    read -p 'Please enter the path of Vencord for Vesktop: ' -i "${VENCORD_PATH}" -e vencordPath
    VENCORD_PATH=$vencordPath
fi

# Check path exists or fallback to default
if [ ! -d "$(normalizePath "$VENCORD_PATH")" ]; then
    echo 'Error: The path "'${VENCORD_PATH}'" does not exist'
    echo 'Trying with the default path "'${DEFAULT_VENCORD_PATH}'"...'
    if [ ! -d "$(normalizePath "$DEFAULT_VENCORD_PATH")" ]; then
        echo "Error: The default path ${DEFAULT_VENCORD_PATH} does not exist"
        exit 1
    else
        echo 'Default path found. Using it.'
        VENCORD_PATH=$DEFAULT_VENCORD_PATH
    fi
fi

# Ensure trailing slash
if [[ "$VENCORD_PATH" != */ ]]; then
    VENCORD_PATH="${VENCORD_PATH}/"
fi

# DESTINATION PATHS
VENCORD_PATH_VCC="${VENCORD_PATH}vesktopCustomCommands/"
VENCORD_PRELOAD_FILE="${VENCORD_PATH}vencordDesktopPreload.js"

VCC_PATH="$HOME/.vesktopCustomCommands/"
VCC_MUTE_PATH="${VCC_PATH}mute.sh"
VCC_DEAFEN_PATH="${VCC_PATH}deafen.sh"
VCC_CONFIG_PATH="${VCC_PATH}.config"

# Ask whether to remove user settings (.config)
echo "You can keep your settings (the .config file) or remove everything."
read -p 'Do you want to remove EVERYTHING including settings? (y/n) ' -n 1 -r
echo
REMOVE_SETTINGS=false
if [[ $REPLY =~ ^[Yy]$ ]]; then
    REMOVE_SETTINGS=true
fi

echo "Starting uninstallation..."

# 1) Revert Vencord preload injection
if [ -f "$(normalizePath "$VENCORD_PRELOAD_FILE")" ]; then
    echo "Processing Vencord preload file..."
    PRELOAD_FILE_NORM="$(normalizePath "$VENCORD_PRELOAD_FILE")"
    if [ -f "${PRELOAD_FILE_NORM}.bak" ]; then
        echo "Found backup. Restoring original preload file from backup..."
        cp -f "${PRELOAD_FILE_NORM}.bak" "$PRELOAD_FILE_NORM"
        if [ $? -eq 0 ]; then
            echo "Preload file restored from backup."
            rm -f "${PRELOAD_FILE_NORM}.bak"
        else
            echo "Warning: Failed to restore from backup. Attempting pattern-based cleanup..."
        fi
    fi

    # Pattern-based cleanup (in case backup restore didn't happen or didn't remove injection)
    # Replace injected variant back to the original listener line
    if grep -q 'document.addEventListener("DOMContentLoaded",()=>{document.documentElement.appendChild(r);' "$PRELOAD_FILE_NORM"; then
        sed -i -E \
            's|document\\.addEventListener\\("DOMContentLoaded",\\(\\)=>\\{document\\.documentElement\\.appendChild\\(r\\);.*\\},\\{once:!0\\}\\)|document.addEventListener("DOMContentLoaded",()=>document.documentElement.appendChild(r),{once:!0})|g' \
            "$PRELOAD_FILE_NORM"
        echo "Removed injected code from preload file."
    fi
fi

# 2) Remove Vencord VCC files
if [ -d "$(normalizePath "$VENCORD_PATH_VCC")" ]; then
    echo "Removing VCC files from Vencord path..."
    rm -f "$(normalizePath "${VENCORD_PATH_VCC}customCode.js")"
    rmdir "$(normalizePath "$VENCORD_PATH_VCC")" 2>/dev/null || true
    # If directory not empty for any reason, force remove
    if [ -d "$(normalizePath "$VENCORD_PATH_VCC")" ]; then
        rm -rf "$(normalizePath "$VENCORD_PATH_VCC")"
    fi
fi

# 3) Remove local scripts and optionally settings
if [ -d "$(normalizePath "$VCC_PATH")" ]; then
    if [ "$REMOVE_SETTINGS" = true ]; then
        echo "Removing local VCC directory and settings..."
        rm -rf "$(normalizePath "$VCC_PATH")"
    else
        echo "Keeping settings (.config). Removing scripts only..."
        rm -f "$(normalizePath "$VCC_MUTE_PATH")" "$(normalizePath "$VCC_DEAFEN_PATH")"
        # Clean directory if it only contains .config
        if [ -d "$(normalizePath "$VCC_PATH")" ]; then
            find "$(normalizePath "$VCC_PATH")" -type f ! -name '.config' -maxdepth 1 -print -quit | grep -q . || true
        fi
    fi
fi

echo 'DONE: The uninstallation was successful!'
offer_restart_vesktop

# Stop and remove auto-repatch service/timer and helper scripts if settings removed
if [ "$REMOVE_SETTINGS" = true ]; then
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user disable --now vcc-autorepatch.timer 2>/dev/null || true
        systemctl --user disable --now vcc-autorepatch.service 2>/dev/null || true
    fi
    rm -f "$HOME/.config/systemd/user/vcc-autorepatch.timer" "$HOME/.config/systemd/user/vcc-autorepatch.service"
    # Nettoyer le lock runtime au cas où
    RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
    rm -f "$RUNTIME_DIR/vcc/VCC_Autorepatch.lock" 2>/dev/null || true
fi

exit 0


